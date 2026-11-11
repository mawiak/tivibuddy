import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/profiles/application/profile_actions.dart';
import 'package:tivibuddy/features/profiles/application/profile_providers.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/settings_data_providers.dart';
import 'package:tivibuddy/features/startup/application/app_startup.dart';

import '../../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ProfileActions actions;

  setUp(() {
    db = createTestDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    actions = container.read(profileActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String?> defaultId() =>
      container.read(deviceSettingsRepositoryProvider).getDefaultProfileId();

  Future<Profile> save({
    String? id,
    String name = 'Anna',
    PinChange pin = const PinUnchanged(),
    bool startAutomatically = false,
  }) => actions.save(
    id: id,
    name: name,
    avatar: const PresetAvatar(0),
    pinChange: pin,
    startAutomatically: startAutomatically,
  );

  test('new profile form knows whether it is the first profile', () async {
    expect((await actions.loadForm(null)).isFirstProfile, isTrue);
    await save();
    expect((await actions.loadForm(null)).isFirstProfile, isFalse);
  });

  test('start automatically sets and clears the default profile', () async {
    final anna = await save(startAutomatically: true);
    expect(await defaultId(), anna.id);
    expect((await actions.loadForm(anna.id)).startAutomatically, isTrue);

    await save(id: anna.id);
    expect(await defaultId(), isNull);
  });

  test('form names a different default profile', () async {
    final anna = await save(startAutomatically: true);
    final ben = await save(name: 'Ben');

    expect((await actions.loadForm(ben.id)).otherDefaultProfileName, 'Anna');
    expect((await actions.loadForm(null)).otherDefaultProfileName, 'Anna');
    expect((await actions.loadForm(anna.id)).otherDefaultProfileName, isNull);
  });

  test('another profile taking over the default replaces it', () async {
    await save(startAutomatically: true);
    final ben = await save(name: 'Ben', startAutomatically: true);
    expect(await defaultId(), ben.id);
  });

  test('pin changes are applied', () async {
    final anna = await save(pin: const PinSet('1234'));
    expect(anna.hasPin, isTrue);
    expect(await actions.verifyPin(anna.id, '1234'), isTrue);

    final updated = await save(id: anna.id, pin: const PinRemoved());
    expect(updated.hasPin, isFalse);
  });

  test('deleting clears default and active profile', () async {
    final anna = await save(startAutomatically: true);
    actions.activate(anna.id);

    await actions.delete(anna.id);

    expect(await defaultId(), isNull);
    expect(container.read(activeProfileIdProvider), isNull);
  });

  group('startup', () {
    // Riverpod pauses providers nobody listens to. In the app the router
    // listens to startup; reading alone would never complete here.
    Future<void> runStartup() {
      container.listen(appStartupProvider, (_, _) {});
      return container.read(appStartupProvider.future);
    }

    test('activates a default profile without pin', () async {
      final anna = await save(startAutomatically: true);
      await runStartup();
      expect(container.read(activeProfileIdProvider), anna.id);
    });

    test('does not bypass the pin of a default profile', () async {
      await save(startAutomatically: true, pin: const PinSet('1234'));
      await runStartup();
      expect(container.read(activeProfileIdProvider), isNull);
    });
  });
}
