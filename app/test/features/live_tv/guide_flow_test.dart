import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/live_tv/application/live_tv_providers.dart';
import 'package:tivibuddy/features/live_tv/data/live_tv_data_providers.dart';
import 'package:tivibuddy/features/live_tv/domain/live_channel.dart';
import 'package:tivibuddy/features/live_tv/presentation/guide_pane.dart';
import 'package:tivibuddy/features/live_tv/presentation/live_player_screen.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
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
      channels: [
        for (var i = 1; i <= 20; i++) testChannel('p1', i, epgChannelId: 'c$i'),
      ],
      programmes: [
        for (var i = 1; i <= 20; i++) ...[
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

  /// Starts the app in live TV, loads the catalog and opens the guide from
  /// the menu.
  Future<void> openGuide(WidgetTester tester) async {
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
            .overrideWithValue(source),
        nowNextProvider.overrideWith((ref, channel) async => NowNext.empty),
        playbackEngineProvider.overrideWith((ref) {
          ref.onDispose(engine.dispose);
          return engine;
        }),
      ],
    );
    await settle(tester);
    await settle(tester);

    await pressBack(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
    await settle(tester);
  }

  /// Texts that scroll because they belong to the focused cell or channel.
  List<String> activeTexts() => [
    for (final widget
        in find
            .byType(MarqueeText)
            .evaluate()
            .map((e) => e.widget as MarqueeText))
      if (widget.active) widget.text,
  ];

  testWidgets('shows the programmes and moves through time and channels', (
    tester,
  ) async {
    await openGuide(tester);

    expect(find.byType(GuideGrid), findsOneWidget);
    expect(source.guideLoads, 1);
    expect(activeTexts(), containsAll(['Channel 1', 'Show A1']));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(activeTexts(), contains('Show B1'));

    // Up and down keep the time position.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(activeTexts(), containsAll(['Channel 2', 'Show B2']));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(activeTexts(), contains('Show A2'));

    // Nothing before the programme running now: left reaches the menu.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(focusedLabel(), 'menu.guide');
  });

  testWidgets('select plays the focused channel', (tester) async {
    await openGuide(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await settle(tester);

    expect(find.byType(LivePlayerScreen), findsOneWidget);
    expect(engine.opened, ['http://stream/1003']);
  });

  testWidgets('up from the first channel reaches the category button', (
    tester,
  ) async {
    await openGuide(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus!.context!.widget;
    expect(
      find.ancestor(
        of: find.byWidget(focused),
        matching: find.byType(GuideGrid),
      ),
      findsOneWidget,
    );
    expect(activeTexts(), contains('All channels'));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(activeTexts(), containsAll(['Channel 1', 'Show A1']));
  });
}
