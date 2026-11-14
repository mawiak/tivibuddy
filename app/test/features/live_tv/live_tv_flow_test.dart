import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/application/live_tv_providers.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:tivibuddy/features/live_tv/presentation/guide_grid.dart';
import 'package:tivibuddy/features/live_tv/presentation/live_player_screen.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';
import 'package:tivibuddy/shared/widgets/marquee_text.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/test_app.dart';

void main() {
  late FakeLiveCatalogSource source;
  late FakePlaybackEngine engine;

  setUp(() {
    final now = DateTime.now().toUtc();
    engine = FakePlaybackEngine();
    source = FakeLiveCatalogSource(
      categories: const [
        LiveCategory(id: 'news', name: 'News', channelCount: 0),
        LiveCategory(id: 'sport', name: 'Sport', channelCount: 0),
      ],
      channels: [
        for (var i = 1; i <= 30; i++)
          testChannel(
            'p1',
            i,
            categoryId: i <= 10 ? 'news' : 'sport',
            epgChannelId: 'c$i',
          ),
      ],
      programmes: [
        for (var i = 1; i <= 30; i++) ...[
          EpgProgramme(
            channelKey: 'c$i',
            title: 'Show A$i',
            // Starts before the current half hour, the earliest time the
            // guide shows.
            start: now.subtract(const Duration(minutes: 40)),
            end: now.add(const Duration(minutes: 50)),
          ),
          EpgProgramme(
            channelKey: 'c$i',
            title: 'Show B$i',
            start: now.add(const Duration(minutes: 50)),
            end: now.add(const Duration(minutes: 110)),
          ),
        ],
      ],
    );
  });

  /// Starts the app with a profile that has one playlist and opens live TV.
  Future<void> openLiveTv(
    WidgetTester tester, {
    bool withPlaylist = true,
  }) async {
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final anna = await DriftProfileRepository(db)
          .create(name: 'Anna', avatar: const PresetAvatar(0));
      await DriftDeviceSettingsRepository(db).setDefaultProfileId(anna.id);
      if (withPlaylist) {
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
      }
    });
    await pumpFullApp(
      tester,
      database: db,
      credentials: FakeCredentialStore()..passwords['p1'] = 'pw',
      overrides: [
        liveCatalogSourceProvider(PlaylistType.xtream)
            .overrideWithValue(source),
        // The real provider caches with timers that outlive a test.
        nowNextProvider.overrideWith(
          (ref, channel) async => NowNext(
            now: EpgEntry(
              title: 'Show on ${channel.name}',
              start: DateTime.now().toUtc(),
              end: DateTime.now().toUtc().add(const Duration(hours: 1)),
            ),
          ),
        ),
        playbackEngineProvider.overrideWith((ref) {
          ref.onDispose(engine.dispose);
          return engine;
        }),
      ],
    );
    await settle(tester);
    await settle(tester);
  }

  /// Texts that scroll because they belong to the focused element.
  List<String> activeTexts() => [
    for (final widget
        in find
            .byType(MarqueeText)
            .evaluate()
            .map((e) => e.widget as MarqueeText))
      if (widget.active) widget.text,
  ];

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await settle(tester);
  }

  testWidgets('without playlist offers to add one', (tester) async {
    await openLiveTv(tester, withPlaylist: false);

    expect(find.text('No playlist yet'), findsOneWidget);
    expect(find.text('Add playlist'), findsOneWidget);
  });

  testWidgets('loads channels and guide and focuses the programme now', (
    tester,
  ) async {
    await openLiveTv(tester);

    expect(find.byType(GuideGrid), findsOneWidget);
    expect(source.channelLoads, 1);
    expect(source.guideLoads, 1);
    expect(activeTexts(), containsAll(['Channel 1', 'Show A1']));
  });

  testWidgets('shows a load failure with retry', (tester) async {
    source.failure = CatalogLoadFailure.unreachable;
    await openLiveTv(tester);

    expect(find.text('The provider could not be reached.'), findsOneWidget);

    source.failure = null;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    await settle(tester);
    expect(find.byType(GuideGrid), findsOneWidget);
  });

  testWidgets('moves through time and channels', (tester) async {
    await openLiveTv(tester);

    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(activeTexts(), contains('Show B1'));

    // Up and down keep the time position.
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(activeTexts(), containsAll(['Channel 2', 'Show B2']));

    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(activeTexts(), contains('Show A2'));
  });

  testWidgets('left and back open the categories on the selected one', (
    tester,
  ) async {
    await openLiveTv(tester);

    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(activeTexts(), contains('All channels'));
    expect(
      find.text('Channel 1'),
      findsWidgets,
      reason: 'the categories push the guide aside instead of covering it',
    );
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('News'), findsNothing, reason: 'categories close');

    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(activeTexts(), contains('Sport'));
    await press(tester, LogicalKeyboardKey.arrowRight);

    await pressBack(tester);
    await settle(tester);
    expect(activeTexts(), contains('Sport'));

    await pressBack(tester);
    await settle(tester);
    expect(focusedLabel(), 'menu.liveTv');
    expect(find.text('News'), findsNothing, reason: 'categories close');
  });

  testWidgets('a focused category filters and right returns to the guide', (
    tester,
  ) async {
    await openLiveTv(tester);
    await press(tester, LogicalKeyboardKey.arrowLeft);

    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(activeTexts(), contains('Sport'));
    expect(find.text('Channel 1'), findsNothing);

    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('News'), findsNothing, reason: 'categories close');
    expect(activeTexts(), containsAll(['Channel 11', 'Show A11']));
  });

  testWidgets('player zaps and back keeps the channel in the preview', (
    tester,
  ) async {
    await openLiveTv(tester);

    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(LivePlayerScreen), findsOneWidget);
    expect(engine.opened, ['http://stream/1001']);
    expect(find.text('Show on Channel 1'), findsOneWidget);

    // Quick zapping opens only the channel where the user stops.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);
    expect(engine.opened, ['http://stream/1001', 'http://stream/1003']);

    // Up from the first channel wraps to the last one.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await settle(tester);
    expect(engine.opened.last, 'http://stream/1030');

    await press(tester, LogicalKeyboardKey.select);
    expect(find.text('Channels'), findsOneWidget);
    await pressBack(tester);
    await settle(tester);
    expect(find.text('Channels'), findsNothing);
    expect(find.byType(LivePlayerScreen), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    expect(find.byType(LivePlayerScreen), findsNothing);
    expect(engine.disposed, isFalse, reason: 'the preview keeps playing');
    expect(activeTexts(), containsAll(['Channel 30', 'Show A30']));

    // Full screen again without opening the stream again.
    final opened = engine.opened.length;
    await press(tester, LogicalKeyboardKey.select);
    expect(find.byType(LivePlayerScreen), findsOneWidget);
    expect(engine.opened, hasLength(opened));
    await pressBack(tester);
    await settle(tester);

    // Leaving live TV stops playback.
    await pressBack(tester);
    await settle(tester);
    await pressBack(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.select);
    expect(engine.disposed, isTrue, reason: 'player resources are released');
  });

  testWidgets('a playback failure is shown and select retries', (tester) async {
    await openLiveTv(tester);
    await press(tester, LogicalKeyboardKey.select);

    engine.emit(const PlaybackState(status: PlaybackStatus.failed, error: 'x'));
    // The fake engine was created outside the fake async zone, so its events
    // need real asynchronous time to arrive.
    await settle(tester);
    expect(find.text('The channel could not be played.'), findsOneWidget);

    await press(tester, LogicalKeyboardKey.select);
    expect(engine.opened, hasLength(2));
  });

  testWidgets('the menu key opens the options in live tv', (tester) async {
    await openLiveTv(tester);
    await press(tester, LogicalKeyboardKey.select);
    engine.emitTracks(
      const MediaTracks(
        audio: [
          MediaTrack(id: '1', type: MediaTrackType.audio, language: 'deu'),
          MediaTrack(id: '2', type: MediaTrackType.audio, language: 'eng'),
        ],
        selectedAudio: '1',
      ),
    );
    await settle(tester);

    await press(tester, LogicalKeyboardKey.contextMenu);
    expect(find.text('Audio'), findsOneWidget);
    await press(tester, LogicalKeyboardKey.select);
    await press(tester, LogicalKeyboardKey.arrowDown);
    await press(tester, LogicalKeyboardKey.select);
    expect(engine.selections, [(MediaTrackType.audio, '2')]);

    // Up closes the options; down switches channels again.
    await press(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('Audio'), findsNothing);
    final opened = engine.opened.length;
    await press(tester, LogicalKeyboardKey.arrowDown);
    expect(engine.opened.length, opened + 1);
  });
}
