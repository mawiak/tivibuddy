import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/movies/application/movie_actions.dart';
import 'package:tivibuddy/features/movies/application/movie_catalog_controller.dart';
import 'package:tivibuddy/features/movies/data/movie_data_providers.dart';
import 'package:tivibuddy/features/movies/data/xtream/xtream_movie_parsing.dart';
import 'package:tivibuddy/features/movies/domain/movie.dart';
import 'package:tivibuddy/features/movies/domain/movie_repository.dart';
import 'package:tivibuddy/features/playlists/application/playlist_actions.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/application/profile_actions.dart';
import 'package:tivibuddy/features/profiles/application/profile_providers.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/movie_fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  group('parsing', () {
    test('parseMovie reads string and number values', () {
      final movie = parseMovie(
        {
          'stream_id': '77',
          'name': ' Heat ',
          'stream_icon': 'http://img/heat.jpg',
          'rating': '7.8',
          'added': '1700000000',
          'category_ids': [5],
          'container_extension': 'mkv',
        },
        playlistId: 'p1',
        position: 3,
      )!;

      expect(movie.streamId, 77);
      expect(movie.name, 'Heat');
      expect(movie.position, 3);
      expect(movie.rating, 7.8);
      expect(movie.addedAt, DateTime.utc(2023, 11, 14, 22, 13, 20));
      expect(movie.categoryId, '5');
      expect(movie.containerExtension, 'mkv');
      expect(parseMovie({'name': 'x'}, playlistId: 'p1', position: 0), isNull);
      expect(
        parseMovie(
          {'stream_id': 1, 'rating': '0'},
          playlistId: 'p1',
          position: 0,
        )!.rating,
        isNull,
      );
    });

    test('parseMovieDetails reads info and movie data', () {
      final details = parseMovieDetails({
        'info': {
          'plot': 'A heist.',
          'genre': 'Crime',
          'actors': 'Al Pacino',
          'director': 'Michael Mann',
          'releasedate': '1995-12-15',
          'duration_secs': 10200,
          'backdrop_path': ['http://img/back.jpg'],
          'rating': '7.8',
        },
        'movie_data': {'container_extension': 'mp4'},
      });

      expect(details.plot, 'A heist.');
      expect(details.cast, 'Al Pacino');
      expect(details.year, '1995');
      expect(details.duration, const Duration(minutes: 170));
      expect(details.backdropUrl, 'http://img/back.jpg');
      expect(details.containerExtension, 'mp4');
      expect(parseMovieDetails([]).plot, isNull);
    });
  });

  group('catalog and states', () {
    late AppDatabase db;
    late ProviderContainer container;
    late FakeMovieCatalogSource source;
    late MovieRepository repository;
    late String playlistId;
    late String profileId;

    setUp(() async {
      db = createTestDatabase();
      source = FakeMovieCatalogSource();
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          credentialStoreProvider.overrideWithValue(FakeCredentialStore()),
          movieCatalogSourceProvider(PlaylistType.xtream)
              .overrideWithValue(source),
        ],
      );
      repository = container.read(movieRepositoryProvider);
      final profile = await container
          .read(profileActionsProvider)
          .save(
            name: 'Anna',
            avatar: const PresetAvatar(0),
            pinChange: const PinUnchanged(),
            startAutomatically: false,
          );
      profileId = profile.id;
      container.read(activeProfileIdProvider.notifier).activate(profileId);
      playlistId =
          (await container
                  .read(playlistActionsProvider)
                  .save(
                    profileId: profileId,
                    input: const PlaylistInput(
                      name: 'TV',
                      serverUrl: 'example.com',
                      username: 'anna',
                      password: 'pw',
                    ),
                  ))
              .id;
      source
        ..categories = const [
          MovieCategory(id: 'a', name: 'Action', movieCount: 0),
          MovieCategory(id: 'd', name: 'Drama', movieCount: 0),
        ]
        ..movies = [
          for (var i = 1; i <= 120; i++)
            testMovie(playlistId, i, categoryId: i.isEven ? 'a' : 'd'),
        ];
      await container
          .read(movieCatalogControllerProvider(playlistId).notifier)
          .refresh();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<List<String>> names(VodFilter filter, {int limit = 5}) async => [
      for (final movie in await repository.getMovies(
        playlistId,
        filter,
        profileId: profileId,
        offset: 0,
        limit: limit,
      ))
        movie.name,
    ];

    test('loads categories and movies in provider order', () async {
      final categories = await repository.watchCategories(playlistId).first;
      expect(categories.map((c) => (c.name, c.movieCount)), [
        ('Action', 60),
        ('Drama', 60),
      ]);
      expect(await names(VodFilter.all, limit: 3), [
        'Movie 1',
        'Movie 2',
        'Movie 3',
      ]);
      expect(await names(const VodFilter.category('a'), limit: 2), [
        'Movie 2',
        'Movie 4',
      ]);
      expect(
        await repository
            .watchCount(playlistId, VodFilter.all, profileId: profileId)
            .first,
        120,
      );
    });

    test('sorts by name, rating and date added', () async {
      await repository.upsertMovies([
        Movie(
          playlistId: playlistId,
          streamId: 1,
          name: 'zebra',
          position: 200,
          rating: 9.5,
          addedAt: DateTime.utc(2020),
        ),
        Movie(
          playlistId: playlistId,
          streamId: 2,
          name: 'Aardvark',
          position: 201,
          addedAt: DateTime.utc(2030),
        ),
      ], loadStartedAt: DateTime.now().toUtc());
      Future<String> first(VodSort sort) async => (await repository.getMovies(
        playlistId,
        VodFilter.all,
        profileId: profileId,
        sort: sort,
        offset: 0,
        limit: 1,
      )).single.name;

      expect(await first(VodSort.provider), 'Movie 1');
      expect(await first(VodSort.nameAscending), 'Aardvark');
      expect(await first(VodSort.nameDescending), 'zebra', reason: 'no case');
      expect(await first(VodSort.rating), 'zebra');
      expect(await first(VodSort.added), 'Aardvark');
    });

    test('favorites and continue watching follow the profile state', () async {
      final actions = container.read(movieActionsProvider);
      final movies = source.movies;
      await actions.toggleFavorite(movies[4]);
      await actions.toggleFavorite(movies[9]);
      await actions.savePosition(
        movies[2],
        const Duration(minutes: 30),
        const Duration(minutes: 100),
      );
      // Seconds into a movie do not count as started.
      await actions.savePosition(
        movies[3],
        const Duration(seconds: 20),
        const Duration(minutes: 100),
      );

      expect(
        await names(const VodFilter.list(VodList.favorites)),
        unorderedEquals(['Movie 5', 'Movie 10']),
      );
      expect(await names(const VodFilter.list(VodList.continueWatching)), [
        'Movie 3',
      ]);

      await actions.toggleFavorite(movies[4]);
      expect(await names(const VodFilter.list(VodList.favorites)), [
        'Movie 10',
      ]);
    });

    test(
      'the end of a movie marks it watched and resets the position',
      () async {
        final actions = container.read(movieActionsProvider);
        final movie = source.movies.first;
        await actions.savePosition(
          movie,
          const Duration(minutes: 97),
          const Duration(minutes: 100),
        );

        final state = await repository.getState(
          profileId,
          playlistId,
          movie.streamId,
        );
        expect(state.watched, isTrue);
        expect(state.position, Duration.zero);
        expect(state.canResume, isFalse);
        expect(
          await names(const VodFilter.list(VodList.continueWatching)),
          isEmpty,
        );
      },
    );

    test('deleting the playlist removes catalog and states', () async {
      await container
          .read(movieActionsProvider)
          .toggleFavorite(source.movies.first);
      await container.read(playlistActionsProvider).delete(playlistId);

      expect(await names(VodFilter.all), isEmpty);
      final rows = await db.select(db.movieStates).get();
      expect(rows.single.deleted, isTrue, reason: 'kept for sync');
    });
  });
}
