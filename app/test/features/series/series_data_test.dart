import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/playlists/application/playlist_actions.dart';
import 'package:tivibuddy/features/playlists/data/playlist_data_providers.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/application/profile_actions.dart';
import 'package:tivibuddy/features/profiles/application/profile_providers.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/series/application/series_actions.dart';
import 'package:tivibuddy/features/series/application/series_catalog_controller.dart';
import 'package:tivibuddy/features/series/application/series_providers.dart';
import 'package:tivibuddy/features/series/data/series_data_providers.dart';
import 'package:tivibuddy/features/series/data/xtream/xtream_series_parsing.dart';
import 'package:tivibuddy/features/series/domain/series.dart';
import 'package:tivibuddy/features/series/domain/series_repository.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/series_fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  group('parsing', () {
    test('parseSeries reads the list entry with its details', () {
      final series = parseSeries(
        {
          'series_id': '55',
          'name': ' Dark ',
          'cover': 'http://img/dark.jpg',
          'backdrop_path': ['http://img/back.jpg'],
          'rating': '8.7',
          'category_id': '7',
          'plot': 'Time travel.',
          'genre': 'Drama',
          'releaseDate': '2017-12-01',
        },
        playlistId: 'p1',
        position: 0,
      )!;

      expect(series.seriesId, 55);
      expect(series.name, 'Dark');
      expect(series.backdropUrl, 'http://img/back.jpg');
      expect(series.rating, 8.7);
      expect(series.year, '2017');
      expect(parseSeries({'name': 'x'}, playlistId: 'p1', position: 0), isNull);
    });

    test('parseSeriesDetails reads episodes by season', () {
      final details = parseSeriesDetails({
        'seasons': [
          {'season_number': 2, 'name': 'Second'},
          {'season_number': 9, 'name': 'Without episodes'},
        ],
        'info': {'cast': 'A, B'},
        'episodes': {
          '2': [
            {
              'id': '21',
              'episode_num': 1,
              'title': 'Two one',
              'container_extension': 'mkv',
              'info': {'duration_secs': 2700, 'plot': 'p'},
            },
          ],
          '1': [
            {'id': '12', 'episode_num': '2', 'title': 'One two'},
            {'id': '11', 'episode_num': '1', 'title': 'One one'},
          ],
        },
      });

      expect(details.seasons.map((s) => (s.number, s.name)), [
        (1, null),
        (2, 'Second'),
      ]);
      expect(details.episodes.map((e) => e.id), [11, 12, 21]);
      expect(
        details.episodesOf(2).single.duration,
        const Duration(minutes: 45),
      );
      expect(details.cast, 'A, B');
    });

    test('parseSeriesDetails accepts episodes as one list', () {
      final details = parseSeriesDetails({
        'episodes': [
          {'id': 5, 'season': 3, 'episode_num': 1, 'title': 'x'},
        ],
      });
      expect(details.episodes.single.seasonNumber, 3);
    });
  });

  test('nextEpisode continues where the profile left off', () {
    final episodes = testSeriesDetails().episodes;
    expect(nextEpisode(episodes, SeriesState.initial, const {})?.id, 101);

    const halfWay = EpisodeState(position: Duration(minutes: 20));
    expect(
      nextEpisode(episodes, const SeriesState(lastEpisodeId: 102), const {
        102: halfWay,
      })?.id,
      102,
    );
    expect(
      nextEpisode(episodes, const SeriesState(lastEpisodeId: 103), const {
        103: EpisodeState(watched: true),
      })?.id,
      201,
      reason: 'continues with the next season',
    );
  });

  group('catalog and states', () {
    late AppDatabase db;
    late ProviderContainer container;
    late FakeSeriesCatalogSource source;
    late SeriesRepository repository;
    late String playlistId;
    late String profileId;

    setUp(() async {
      db = createTestDatabase();
      source = FakeSeriesCatalogSource();
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          credentialStoreProvider.overrideWithValue(FakeCredentialStore()),
          seriesCatalogSourceProvider(PlaylistType.xtream)
              .overrideWithValue(source),
        ],
      );
      repository = container.read(seriesRepositoryProvider);
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
          SeriesCategory(id: 'a', name: 'Crime', seriesCount: 0),
        ]
        ..series = [
          for (var i = 1; i <= 10; i++)
            testSeries(playlistId, i, categoryId: 'a'),
        ];
      await container
          .read(seriesCatalogControllerProvider(playlistId).notifier)
          .refresh();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<List<String>> names(VodFilter filter) async => [
      for (final series in await repository.getSeries(
        playlistId,
        filter,
        profileId: profileId,
        offset: 0,
        limit: 5,
      ))
        series.name,
    ];

    test('loads series and keeps the details of the list', () async {
      expect(await names(VodFilter.all), [
        'Series 1',
        'Series 2',
        'Series 3',
        'Series 4',
        'Series 5',
      ]);
      final first = (await repository.getSeries(
        playlistId,
        VodFilter.all,
        profileId: profileId,
        offset: 0,
        limit: 1,
      )).single;
      expect(first.plot, 'Plot of series 1');
    });

    test('episode progress feeds continue watching and resume', () async {
      final actions = container.read(seriesActionsProvider);
      final series = source.series[2];
      final episode = testSeriesDetails().episodes[1];
      await actions.saveEpisodeProgress(
        series,
        episode,
        const Duration(minutes: 20),
        const Duration(minutes: 45),
      );

      expect(await names(const VodFilter.list(VodList.continueWatching)), [
        'Series 3',
      ]);
      final state = await repository.getSeriesState(
        profileId,
        playlistId,
        series.seriesId,
      );
      expect(state.lastEpisodeId, episode.id);
      final episodes = await repository
          .watchEpisodeStates(profileId, playlistId, series.seriesId)
          .first;
      expect(episodes[episode.id]?.canResume, isTrue);

      // The end of the episode marks it watched.
      await actions.saveEpisodeProgress(
        series,
        episode,
        const Duration(minutes: 44),
        const Duration(minutes: 45),
      );
      final after = await repository
          .watchEpisodeStates(profileId, playlistId, series.seriesId)
          .first;
      expect(after[episode.id]?.watched, isTrue);
      expect(after[episode.id]?.position, Duration.zero);
    });

    test('favorites and deleting the playlist', () async {
      final actions = container.read(seriesActionsProvider);
      await actions.toggleFavorite(source.series[4]);
      expect(await names(const VodFilter.list(VodList.favorites)), [
        'Series 5',
      ]);
      await actions.toggleFavorite(source.series[4]);
      expect(await names(const VodFilter.list(VodList.favorites)), isEmpty);

      await actions.toggleFavorite(source.series[4]);
      await container.read(playlistActionsProvider).delete(playlistId);
      expect(await names(VodFilter.all), isEmpty);
      final rows = await db.select(db.seriesStates).get();
      expect(rows.single.deleted, isTrue, reason: 'kept for sync');
    });
  });
}
