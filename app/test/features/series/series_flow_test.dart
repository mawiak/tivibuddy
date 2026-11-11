import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/series/application/series_providers.dart';
import 'package:tivibuddy/features/series/data/series_data_providers.dart';
import 'package:tivibuddy/features/series/presentation/series_detail_screen.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';
import 'package:tivibuddy/features/vod/presentation/vod_player_screen.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/series_fakes.dart';
import '../../helpers/test_app.dart';

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

void main() {
  late FakeSeriesCatalogSource source;
  late FakePlaybackEngine engine;

  setUp(() {
    engine = FakePlaybackEngine();
    source = FakeSeriesCatalogSource(
      series: [for (var i = 1; i <= 12; i++) testSeries('p1', i)],
    );
  });

  /// Starts the app with one playlist and opens the series section.
  Future<void> openSeries(WidgetTester tester) async {
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
        liveCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(FakeLiveCatalogSource()),
        seriesCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(source),
        // The real provider caches with timers that outlive a test.
        seriesDetailsProvider.overrideWith(
          (ref, series) async => testSeriesDetails(),
        ),
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
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    await settle(tester);
    await settle(tester);
    expect(focusedText(), 'All series', reason: 'starts in the categories');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await settle(tester);
  }

  testWidgets('plays the next episode, resumes it and switches seasons', (
    tester,
  ) async {
    await openSeries(tester);
    expect(source.loads, 1);
    expect(focusedText(), 'Series 1');

    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(SeriesDetailScreen), findsOneWidget);
    expect(focusedText(), 'Play S1 E1');
    expect(find.text('S1 E1  Episode 1.1'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(VodPlayerScreen), findsOneWidget);
    expect(engine.opened, ['http://episode/101.mkv']);

    engine
      ..emit(
        const PlaybackState(
          status: PlaybackStatus.playing,
          duration: Duration(minutes: 45),
        ),
      )
      ..emitPosition(const Duration(minutes: 20));
    await settle(tester);
    await pressBack(tester);
    await settle(tester);
    expect(find.text('Resume S1 E1 at 20:00'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.select);
    expect(engine.starts.last, const Duration(minutes: 20));
    await pressBack(tester);
    await settle(tester);

    // Focusing season 2 lists its episodes.
    Focus.of(tester.element(find.text('Season 2'))).requestFocus();
    await settle(tester);
    expect(find.text('S2 E1  Episode 2.1'), findsOneWidget);
    expect(find.text('S1 E1  Episode 1.1'), findsNothing);

    await tester.tap(find.text('S2 E3  Episode 2.3'));
    await settle(tester);
    expect(engine.opened.last, 'http://episode/203.mkv');
    expect(engine.starts.last, isNull);
  });

  testWidgets('favorites show up in their list', (tester) async {
    await openSeries(tester);
    await press(tester, LogicalKeyboardKey.select);
    await tester.tap(find.text('Add to favorites'));
    await settle(tester);
    expect(find.text('Remove from favorites'), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(focusedText(), 'Favorites');
    await press(tester, LogicalKeyboardKey.select);
    expect(focusedText(), 'Series 1');
  });
}
