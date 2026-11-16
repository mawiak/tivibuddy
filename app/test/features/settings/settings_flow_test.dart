import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/about/presentation/about_screen.dart';
import 'package:tivibuddy/features/home/application/home_section.dart';
import 'package:tivibuddy/features/player/application/player_settings_providers.dart';
import 'package:tivibuddy/features/player/data/audio_output_capabilities.dart';
import 'package:tivibuddy/features/player/data/player_providers.dart';
import 'package:tivibuddy/features/player/domain/player_settings.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';
import 'package:tivibuddy/features/settings/data/settings_data_providers.dart';

import '../../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  Future<void> openSettings(WidgetTester tester) async {
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final profiles = DriftProfileRepository(db);
      final anna = await profiles.create(
        name: 'Anna',
        avatar: const PresetAvatar(0),
      );
      await profiles.create(name: 'Ben', avatar: const PresetAvatar(1));
      await DriftDeviceSettingsRepository(db).setDefaultProfileId(anna.id);
    });
    container = await pumpFullApp(
      tester,
      database: db,
      overrides: [
        audioOutputCapabilitiesProvider.overrideWithValue(
          const _FakeCapabilities(),
        ),
      ],
    );
    container
        .read(selectedHomeSectionProvider.notifier)
        .select(HomeSection.settings);
    await settle(tester);
  }

  testWidgets('shows profile, device and general sections', (tester) async {
    await openSettings(tester);

    expect(find.text('Profile Anna'), findsOneWidget);
    expect(find.text('This device'), findsOneWidget);
    expect(find.text('Device language'), findsOneWidget);
    expect(find.text('Anna'), findsWidgets, reason: 'start profile');
  });

  testWidgets('changing the language translates the app', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Language'));
    await settle(tester);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Deutsch'));
    await settle(tester);

    expect(find.text('Einstellungen'), findsWidgets);
    expect(find.text('Sprache'), findsOneWidget);

    await tester.tap(find.text('Sprache'));
    await settle(tester);
    await tester.tap(find.text('Gerätesprache'));
    await settle(tester);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('start profile can be changed and cleared', (tester) async {
    await openSettings(tester);
    final settings = container.read(deviceSettingsRepositoryProvider);

    await tester.tap(find.text('Start profile'));
    await settle(tester);
    // The focused option scrolls as marquee in the wide test font, which
    // duplicates its text.
    await tester.tap(find.text('Show profile selection').first);
    await settle(tester);

    expect(await tester.runAsync(settings.getDefaultProfileId), isNull);
    expect(find.text('Show profile selection'), findsWidgets);
  });

  testWidgets('resetting device settings asks first', (tester) async {
    await openSettings(tester);
    final settings = container.read(deviceSettingsRepositoryProvider);
    await tester.scrollUntilVisible(find.text('Reset device settings'), 100);
    await tester.ensureVisible(find.text('Reset device settings'));
    await settle(tester);

    await tester.tap(find.text('Reset device settings'));
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(await tester.runAsync(settings.getDefaultProfileId), isNotNull);

    await tester.tap(find.text('Reset device settings'));
    await settle(tester);
    await tester.tap(find.text('Reset'));
    await settle(tester);
    expect(await tester.runAsync(settings.getDefaultProfileId), isNull);
  });

  testWidgets('player decoder and audio passthrough can be changed', (
    tester,
  ) async {
    await openSettings(tester);
    await tester.scrollUntilVisible(find.text('Audio passthrough'), 100);
    await tester.ensureVisible(find.text('Audio passthrough'));
    await settle(tester);

    await tester.tap(find.text('Video decoder'));
    await settle(tester);
    await tester.tap(find.text('Software').last);
    await settle(tester);
    expect(
      container.read(playerSettingsControllerProvider).decoder,
      VideoDecoder.software,
    );
    expect(find.text('Software'), findsOneWidget, reason: 'shown as value');

    await tester.tap(find.text('Audio passthrough'));
    await settle(tester);
    expect(
      find.textContaining('currently passes through: Dolby Digital (AC3)'),
      findsOneWidget,
    );
    // The message pushes options below the dialog's visible area; a tap
    // there would hit the barrier and close the dialog.
    for (final option in ['DTS', 'Dolby Digital Plus (E-AC3)']) {
      await tester.ensureVisible(find.text(option));
      await settle(tester);
      await tester.tap(find.text(option));
      await settle(tester);
    }
    await settle(tester);
    await pressBack(tester);
    await settle(tester);
    expect(container.read(playerSettingsControllerProvider).passthrough, {
      AudioPassthrough.eac3,
      AudioPassthrough.dts,
    });
    expect(find.text('Dolby Digital Plus (E-AC3), DTS'), findsOneWidget);
  });

  testWidgets('about shows license and disclaimer', (tester) async {
    await openSettings(tester);

    // The list builds lazily: scroll it into existence, then fully into view.
    await tester.scrollUntilVisible(find.text('About TiviBuddy'), 100);
    await tester.ensureVisible(find.text('About TiviBuddy'));
    await settle(tester);
    await tester.tap(find.text('About TiviBuddy'));
    await settle(tester);

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(find.text('Disclaimer'), findsOneWidget);
    expect(find.textContaining('GNU General Public License'), findsOneWidget);
  });
}

class _FakeCapabilities implements AudioOutputCapabilities {
  const _FakeCapabilities();

  @override
  Future<PassthroughSupport?> query() async =>
      const PassthroughSupport({AudioPassthrough.ac3});
}
