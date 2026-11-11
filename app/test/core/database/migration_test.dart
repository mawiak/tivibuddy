import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/database/app_database.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('tivibuddy_db'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('upgrades a version 1 database and keeps its profiles', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final file = File('${dir.path}/app.sqlite');

    // Recreate the state of a version 1 installation: no playlists table.
    final v1 = AppDatabase(NativeDatabase(file));
    await v1.customStatement('''
INSERT INTO profiles (id, created_at, updated_at, name)
VALUES ('p1', '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z', 'Anna')
''');
    await v1.customStatement('DROP TABLE playlists');
    await v1.customStatement('DROP TABLE profile_setting_entries');
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(await upgraded.select(upgraded.playlists).get(), isEmpty);
    expect(
      await upgraded.select(upgraded.profileSettingEntries).get(),
      isEmpty,
    );
    final profiles = await upgraded.select(upgraded.profiles).get();
    expect(profiles.single.name, 'Anna');
  });
}
