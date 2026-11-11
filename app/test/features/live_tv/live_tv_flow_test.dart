import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/application/live_tv_providers.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/domain/live_tv_repository.dart';
import 'package:tivibuddy/features/live_tv/presentation/channel_widgets.dart';
import 'package:tivibuddy/features/live_tv/presentation/live_player_screen.dart';
import 'package:tivibuddy/features/live_tv/presentation/live_tv_pane.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/player/domain/playback_engine.dart';
import 'package:tivibuddy/features/playlists/domain/playlist.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';

import '../../helpers/fake_credential_store.dart';
import '../../helpers/live_tv_fakes.dart';
import '../../helpers/test_app.dart';

const _access = PlaylistAccess(
  playlistId: 'p1',
  serverUrl: 'http://example.com',
  username: 'anna',
  password: 'pw',
);

void main() {
  late FakeLiveCatalogSource source;
  late FakePlaybackEngine engine;

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
          (ref, channel) => source.fetchNowNext(_access, channel),
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

  setUp(() {
    engine = FakePlaybackEngine();
    source = FakeLiveCatalogSource(
      categories: const [
        LiveCategory(id: 'news', name: 'News', channelCount: 0),
        LiveCategory(id: 'sport', name: 'Sport', channelCount: 0),
      ],
      channels: [
        for (var i = 1; i <= 30; i++)
          testChannel('p1', i, categoryId: i <= 10 ? 'news' : 'sport'),
      ],
    );
  });

  testWidgets('without playlist offers to add one', (tester) async {
    await openLiveTv(tester, withPlaylist: false);

    expect(find.text('No playlist yet'), findsOneWidget);
    expect(find.text('Add playlist'), findsOneWidget);
  });

  testWidgets('loads the catalog and lists categories and channels', (
    tester,
  ) async {
    await openLiveTv(tester);

    expect(find.byType(LiveTvPane), findsOneWidget);
    expect(find.text('All channels'), findsWidgets);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Channel 1'), findsOneWidget);
    expect(source.channelLoads, 1);
  });

  testWidgets('shows a load failure with retry', (tester) async {
    source.failure = CatalogLoadFailure.unreachable;
    await openLiveTv(tester);

    expect(find.text('The provider could not be reached.'), findsOneWidget);

    source.failure = null;
    await tester.tap(find.text('Try again'));
    await settle(tester);
    await settle(tester);
    expect(find.text('Channel 1'), findsOneWidget);
  });

  testWidgets('focusing a category filters the channels', (tester) async {
    await openLiveTv(tester);

    Focus.of(tester.element(find.text('Sport'))).requestFocus();
    await settle(tester);

    expect(find.text('Channel 1'), findsNothing);
    expect(find.text('Channel 11'), findsOneWidget);
  });

  testWidgets('left moves from channels to categories and on to the menu', (
    tester,
  ) async {
    await openLiveTv(tester);
    expect(focusedLabel(), isNot(startsWith('menu.')));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus!.context!;
    expect(
      focused.findAncestorWidgetOfExactType<ChannelRow>(),
      isNull,
      reason: 'focus left the channel list',
    );
    expect(
      find.descendant(
        of: find.byWidget(focused.widget),
        matching: find.text('All channels'),
      ),
      findsOneWidget,
      reason: 'the selected category has focus',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(focusedLabel(), startsWith('menu.'));
  });

  testWidgets('categories keep focus and right enters the first channel', (
    tester,
  ) async {
    await openLiveTv(tester);
    final sport = Focus.of(tester.element(find.text('Sport')));
    sport.requestFocus();
    await settle(tester);

    expect(sport.hasFocus, isTrue, reason: 'new list must not steal focus');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    final focused = FocusManager.instance.primaryFocus!.context!;
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Channel 11'),
          matching: find.byType(ChannelRow),
        ),
        matching: find.byWidget(focused.widget),
      ),
      findsOneWidget,
    );
  });

  testWidgets('player plays the channel, zaps and shows the list', (
    tester,
  ) async {
    await openLiveTv(tester);

    await tester.tap(find.text('Channel 1'));
    await settle(tester);

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

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    expect(find.text('Channels'), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    expect(find.text('Channels'), findsNothing);
    expect(find.byType(LivePlayerScreen), findsOneWidget);

    await pressBack(tester);
    await settle(tester);
    expect(find.byType(LivePlayerScreen), findsNothing);
    expect(engine.disposed, isTrue, reason: 'player resources are released');
  });

  testWidgets('a playback failure is shown and select retries', (tester) async {
    await openLiveTv(tester);
    await tester.tap(find.text('Channel 1'));
    await settle(tester);

    engine.emit(const PlaybackState(status: PlaybackStatus.failed, error: 'x'));
    // The fake engine was created outside the fake async zone, so its events
    // need real asynchronous time to arrive.
    await settle(tester);
    expect(find.text('The channel could not be played.'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    expect(engine.opened, hasLength(2));
  });
}
