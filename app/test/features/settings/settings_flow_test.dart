import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/about/presentation/about_screen.dart';
import 'package:tivibuddy/features/home/application/home_section.dart';
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
    container = await pumpFullApp(tester, database: db);
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
