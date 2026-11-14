import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/core/database/like_pattern.dart';
import 'package:tivibuddy/features/home/application/home_section.dart';
import 'package:tivibuddy/features/home/presentation/home_shell.dart';
import 'package:tivibuddy/features/live_tv/application/live_tv_providers.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/presentation/live_player_screen.dart';
import 'package:tivibuddy/features/movies/application/movie_catalog_controller.dart';
import 'package:tivibuddy/features/movies/application/movie_providers.dart';
import 'package:tivibuddy/features/movies/data/movie_data_providers.dart';
import 'package:tivibuddy/features/movies/domain/movie.dart';
import 'package:tivibuddy/features/movies/presentation/movie_detail_screen.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/search/presentation/search_pane.dart';
import 'package:tivibuddy/features/series/application/series_catalog_controller.dart';
import 'package:tivibuddy/features/series/data/series_data_providers.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/movie_fakes.dart';
import '../../helpers/series_fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  test('likePattern escapes wildcards', () {
    expect(likePattern(' 100% ok_ '), r'%100\% ok\_%');
  });

  late FakePlaybackEngine engine;

  setUp(() => engine = FakePlaybackEngine());

  /// Starts the app with channels, movies and series loaded and opens the
  /// search.
  Future<void> openSearch(WidgetTester tester) async {
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
        liveCatalogSourceProvider(PlaylistType.xtream).overrideWithValue(
          FakeLiveCatalogSource(
            channels: [for (var i = 1; i <= 20; i++) testChannel('p1', i)],
          ),
        ),
        nowNextProvider.overrideWith((ref, channel) async => NowNext.empty),
        movieCatalogSourceProvider(PlaylistType.xtream).overrideWithValue(
          FakeMovieCatalogSource(
            movies: [for (var i = 1; i <= 20; i++) testMovie('p1', i)],
          ),
        ),
        // The real provider caches with timers that outlive a test.
        movieDetailsProvider.overrideWith(
          (ref, movie) async => const MovieDetails(plot: 'Plot'),
        ),
        seriesCatalogSourceProvider(PlaylistType.xtream).overrideWithValue(
          FakeSeriesCatalogSource(
            series: [for (var i = 1; i <= 20; i++) testSeries('p1', i)],
          ),
        ),
        playbackEngineProvider.overrideWith((ref) {
          ref.onDispose(engine.dispose);
          return engine;
        }),
      ],
    );
    await settle(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeShell)),
    );
    await tester.runAsync(() async {
      await container
          .read(movieCatalogControllerProvider('p1').notifier)
          .refresh();
      await container
          .read(seriesCatalogControllerProvider('p1').notifier)
          .refresh();
    });
    container
        .read(selectedHomeSectionProvider.notifier)
        .select(HomeSection.search);
    await settle(tester);
    expect(find.byType(SearchPane), findsOneWidget);
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(EditableText), text);
    await settle(tester);
    await settle(tester);
  }

  testWidgets('finds channels, movies and series case-insensitively', (
    tester,
  ) async {
    await openSearch(tester);
    await search(tester, 'el 1');

    expect(find.text('Channels  (11)'), findsOneWidget);
    expect(find.text('Movies'), findsNothing, reason: 'no movie matches');

    await search(tester, 'MOVIE 1');
    expect(find.text('Movies  (11)'), findsOneWidget);
    await search(tester, 'nothing like this');
    expect(find.text('No results for “nothing like this”.'), findsOneWidget);

    // Movies come first, then series, then channels.
    await search(tester, '10');
    double top(String title) =>
        tester.getTopLeft(find.textContaining('$title  (')).dy;
    expect(top('Movies'), lessThan(top('Series')));
    await tester.scrollUntilVisible(
      find.textContaining('Channels  ('),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SearchPane),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(top('Series'), lessThan(top('Channels')));
    expect(find.text('Channels  (11)'), findsNothing);
  });

  testWidgets('a channel result plays from its place in all channels', (
    tester,
  ) async {
    await openSearch(tester);
    await search(tester, 'Channel 12');
    await tester.tap(find.text('Channel 12').last);
    await settle(tester);

    expect(find.byType(LivePlayerScreen), findsOneWidget);
    expect(engine.opened, ['http://stream/1012']);
  });

  testWidgets('a movie result opens its details', (tester) async {
    await openSearch(tester);
    await search(tester, 'Movie 7');
    await tester.tap(find.text('Movie 7').last);
    await settle(tester);
    expect(find.byType(MovieDetailScreen), findsOneWidget);
  });
}
