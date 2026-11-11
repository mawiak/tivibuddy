import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_profile_settings_repository.dart';

import '../../helpers/test_app.dart';

void main() {
  late AppDatabase db;
  late DriftProfileSettingsRepository repository;
  late String anna;
  late String ben;

  setUp(() async {
    db = createTestDatabase();
    repository = DriftProfileSettingsRepository(db);
    final profiles = DriftProfileRepository(db);
    anna = (await profiles.create(
      name: 'Anna',
      avatar: const PresetAvatar(0),
    )).id;
    ben = (await profiles.create(
      name: 'Ben',
      avatar: const PresetAvatar(1),
    )).id;
  });

  tearDown(() => db.close());

  test('defaults without stored values', () async {
    expect((await repository.get(anna)).languageCode, isNull);
  });

  test('stores settings per profile', () async {
    await repository.setLanguage(anna, 'de');

    expect((await repository.get(anna)).languageCode, 'de');
    expect((await repository.get(ben)).languageCode, isNull);
  });

  test('clearing a value keeps a deleted row for sync', () async {
    await repository.setLanguage(anna, 'de');
    await repository.setLanguage(anna, null);

    expect((await repository.get(anna)).languageCode, isNull);
    final row = await db.select(db.profileSettingEntries).getSingle();
    expect(row.deleted, isTrue);

    await repository.setLanguage(anna, 'en');
    expect((await repository.get(anna)).languageCode, 'en');
  });

  test('reset restores defaults of one profile only', () async {
    await repository.setLanguage(anna, 'de');
    await repository.setLanguage(ben, 'en');

    await repository.reset(anna);

    expect((await repository.get(anna)).languageCode, isNull);
    expect((await repository.get(ben)).languageCode, 'en');
  });
}
