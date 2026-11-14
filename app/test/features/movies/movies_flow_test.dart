import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/movies/application/movie_providers.dart';
import 'package:tivibuddy/features/movies/data/movie_data_providers.dart';
import 'package:tivibuddy/features/movies/domain/movie.dart';
import 'package:tivibuddy/features/movies/presentation/movie_detail_screen.dart';
import 'package:tivibuddy/features/movies/presentation/movie_poster.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/playlists/domain/catalog_access.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';
import 'package:tivibuddy/features/vod/presentation/vod_player_screen.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/movie_fakes.dart';
import '../../helpers/test_app.dart';

const _access = PlaylistAccess(
  playlistId: 'p1',
  serverUrl: 'http://example.com',
  username: 'anna',
  password: 'pw',
);

/// First text inside the focused element.
String? focusedText() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  final texts = find
      .descendant(
        of: find.byWidget(context.widget),
        matching: find.byType(Text),
      )
      .evaluate();
  return texts.isEmpty ? null : (texts.first.widget as Text).data;
}

/// Names of the movies in the grid.
List<String?> posterNames() => [
  for (final element in find.byType(MoviePoster).evaluate())
    (element.widget as MoviePoster).movie?.name,
];

void main() {
  late FakeMovieCatalogSource source;
  late FakePlaybackEngine engine;

  setUp(() {
    engine = FakePlaybackEngine();
    source = FakeMovieCatalogSource(
      categories: const [
        MovieCategory(id: 'a', name: 'Action', movieCount: 0),
        MovieCategory(id: 'd', name: 'Drama', movieCount: 0),
      ],
      movies: [
        for (var i = 1; i <= 40; i++)
          testMovie('p1', i, categoryId: i.isEven ? 'a' : 'd'),
      ],
    );
  });

  /// Starts the app with one playlist and opens the movies section.
  Future<void> openMovies(WidgetTester tester) async {
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final anna = await DriftProfileRepository(db)
          .create(name: 'Anna', avatar: const PresetAvatar(0));
      await DriftDeviceSettingsRepository(db).setDefaultProfileId(anna.id);
      await db
          .into(db.playlists)
          .insert(
            PlaylistsCompanion.insert(
              id: 'p1',
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
              profileId: anna.id,
              type: PlaylistType.xtream,
              name: 'TV',
              serverUrl: 'http://example.com',
              username: 'anna',
            ),
          );
    });
    await pumpFullApp(
      tester,
      database: db,
      credentials: FakeCredentialStore()..passwords['p1'] = 'pw',
      overrides: [
        // Live TV opens first; an empty catalog keeps it quiet.
        liveCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(FakeLiveCatalogSource()),
        movieCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(source),
        // The real provider caches with timers that outlive a test.
        movieDetailsProvider.overrideWith(
          (ref, movie) => source.fetchDetails(_access, movie),
        ),
        // Every player screen gets a new engine, like in the app.
        playbackEngineProvider.overrideWith((ref) {
          final created = FakePlaybackEngine()
            ..opened.addAll(engine.opened)
            ..starts.addAll(engine.starts);
          engine = created;
          ref.onDispose(created.dispose);
          return created;
        }),
      ],
    );
    await settle(tester);
    await pressBack(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    await settle(tester);
    await settle(tester);
    // Select on the menu entry starts in the categories, once they loaded.
    expect(focusedText(), 'All movies');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await settle(tester);
  }

  testWidgets('categories open with left and back and close with select', (
    tester,
  ) async {
    await openMovies(tester);

    expect(source.loads, 1);
    expect(focusedText(), 'Movie 1');
    expect(find.text('Action'), findsNothing, reason: 'categories hidden');

    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(focusedText(), 'All movies', reason: 'opens on the selected one');

    // Moving through the categories switches the grid.
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'Action');
    expect(posterNames(), isNot(contains('Movie 1')));
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'Drama');
    await press(tester, LogicalKeyboardKey.arrowUp);
    await press(tester, LogicalKeyboardKey.arrowUp);
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedText(), 'Favorites');
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'Action');

    await press(tester, LogicalKeyboardKey.select);
    expect(find.text('Drama'), findsNothing, reason: 'categories close');
    expect(focusedText(), 'Movie 2');

    await pressBack(tester);
    await settle(tester);
    expect(focusedText(), 'Action');
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(focusedText(), 'Movie 2');

    await pressBack(tester);
    await settle(tester);
    await pressBack(tester);
    await settle(tester);
    expect(focusedLabel(), 'menu.movies');
  });

  testWidgets('plays a movie, resumes it and keeps favorites', (tester) async {
    await openMovies(tester);

    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(MovieDetailScreen), findsOneWidget);
    expect(find.text('Plot of Movie 1'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(VodPlayerScreen), findsOneWidget);
    expect(engine.opened, ['http://movie/2001.mp4']);
    expect(engine.starts, [null]);

    engine
      ..emit(
        const PlaybackState(
          status: PlaybackStatus.playing,
          duration: Duration(minutes: 100),
        ),
      )
      ..emitPosition(const Duration(minutes: 42));
    await settle(tester);
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(engine.position, const Duration(minutes: 42, seconds: 10));

    await pressBack(tester);
    await settle(tester);
    expect(find.byType(VodPlayerScreen), findsNothing);
    expect(find.text('Resume at 42:10'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.select);
    expect(engine.starts.last, const Duration(minutes: 42, seconds: 10));
    await pressBack(tester);
    await settle(tester);

    await tester.tap(find.text('Add to favorites'));
    await settle(tester);
    expect(find.text('Remove from favorites'), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedText(), 'Favorites');
    expect(posterNames(), ['Movie 1']);

    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedText(), 'Continue watching');
    expect(posterNames(), ['Movie 1']);
  });

  testWidgets('the end of a movie marks it watched', (tester) async {
    await openMovies(tester);
    await press(tester, LogicalKeyboardKey.select);
    await press(tester, LogicalKeyboardKey.select);

    engine
      ..emitPosition(const Duration(minutes: 99))
      ..emit(
        const PlaybackState(
          status: PlaybackStatus.ended,
          duration: Duration(minutes: 100),
        ),
      );
    await settle(tester);
    await settle(tester);

    expect(find.byType(VodPlayerScreen), findsNothing);
    expect(find.text('Mark as not watched'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('down twice opens the options to choose the audio track', (
    tester,
  ) async {
    await openMovies(tester);
    await press(tester, LogicalKeyboardKey.select);
    await press(tester, LogicalKeyboardKey.select);
    engine.emitTracks(
      const MediaTracks(
        audio: [
          MediaTrack(
            id: '1',
            type: MediaTrackType.audio,
            language: 'ger',
            channels: 6,
          ),
          MediaTrack(
            id: '2',
            type: MediaTrackType.audio,
            language: 'eng',
            channels: 2,
          ),
        ],
        subtitle: [
          MediaTrack(id: '3', type: MediaTrackType.subtitle, language: 'de'),
        ],
        selectedAudio: '1',
      ),
    );
    await settle(tester);

    // The info bar shows when the player starts; down again opens the
    // options.
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('German, 5.1 surround sound'), findsWidgets);
    expect(find.text('Off'), findsWidgets, reason: 'subtitles off');

    await press(tester, LogicalKeyboardKey.select);
    expect(find.text('Audio tracks'), findsOneWidget);
    expect(focusedText(), 'German, 5.1 surround sound');
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'English, Stereo');
    await press(tester, LogicalKeyboardKey.select);
    expect(engine.selections, [(MediaTrackType.audio, '2')]);
    expect(find.text('Audio tracks'), findsNothing, reason: 'panel closes');
    expect(find.text('English, Stereo'), findsWidgets);

    // Subtitles can be switched on.
    await press(tester, LogicalKeyboardKey.arrowRight);
    await press(tester, LogicalKeyboardKey.select);
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'German');
    await press(tester, LogicalKeyboardKey.select);
    expect(engine.selections.last, (MediaTrackType.subtitle, '3'));

    await pressBack(tester);
    await settle(tester);
    expect(find.text('Audio'), findsNothing, reason: 'options close');
    expect(find.byType(VodPlayerScreen), findsOneWidget);
    await pressBack(tester);
    await settle(tester);
    expect(find.byType(VodPlayerScreen), findsNothing);
  });

  testWidgets('the menu key sorts the grid', (tester) async {
    await openMovies(tester);
    expect(posterNames().first, 'Movie 1');

    await press(tester, LogicalKeyboardKey.contextMenu);
    expect(find.text('Name Z–A'), findsOneWidget);
    await tester.tap(find.text('Name Z–A'));
    await settle(tester);
    await settle(tester);

    expect(posterNames().first, 'Movie 9', reason: 'names sort as text');
    expect(find.text('Name Z–A'), findsOneWidget, reason: 'on the button');
  });

  testWidgets('up from the first row sorts the opened category only', (
    tester,
  ) async {
    await openMovies(tester);
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedText(), 'Playlist order', reason: 'sort button focused');

    await press(tester, LogicalKeyboardKey.select);
    await tester.tap(find.text('Name Z–A'));
    await settle(tester);
    await settle(tester);
    expect(posterNames().first, 'Movie 9');
    expect(focusedText(), 'Movie 9', reason: 'the sorted list starts over');

    // Another category keeps its own order.
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(focusedText(), 'Action');
    expect(posterNames().first, 'Movie 2');
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(posterNames().first, 'Movie 9', reason: 'all movies kept Z–A');
  });
}
