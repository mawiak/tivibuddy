import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/playlists/data/playlists_table.dart';
import '../../features/playlists/domain/playlist.dart';
import '../../features/profiles/data/profiles_table.dart';
import '../../features/settings/data/device_settings_table.dart';

part 'app_database.g.dart';

/// Local SQLite database. It is the single source of truth for the UI
/// (DATA-3). Feature tables are defined in the data layer of their feature
/// and registered here.
@DriftDatabase(tables: [Profiles, Playlists, DeviceSettingEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(playlists);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _open() => driftDatabase(
    name: 'tivibuddy',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
