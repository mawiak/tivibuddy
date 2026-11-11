import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/live_tv/data/live_tv_tables.dart';
import '../../features/movies/data/movies_tables.dart';
import '../../features/playlists/data/playlists_table.dart';
import '../../features/playlists/domain/playlist.dart';
import '../../features/profiles/data/profiles_table.dart';
import '../../features/settings/data/device_settings_table.dart';
import '../../features/settings/data/profile_settings_table.dart';

part 'app_database.g.dart';

/// Local SQLite database. It is the single source of truth for the UI
/// (DATA-3). Feature tables are defined in the data layer of their feature
/// and registered here.
@DriftDatabase(
  tables: [
    Profiles,
    Playlists,
    ProfileSettingEntries,
    DeviceSettingEntries,
    LiveCategories,
    LiveChannels,
    CatalogStates,
    EpgProgrammes,
    MovieCategories,
    Movies,
    MovieStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(playlists);
      if (from < 3) await migrator.createTable(profileSettingEntries);
      if (from < 4) {
        await migrator.createTable(liveCategories);
        await migrator.createTable(liveChannels);
        await migrator.createTable(catalogStates);
        await migrator.createIndex(liveChannelsByCategory);
        await migrator.createIndex(liveChannelsByNumber);
      }
      if (from < 5) await migrator.createTable(epgProgrammes);
      if (from < 6) {
        await migrator.createTable(movieCategories);
        await migrator.createTable(movies);
        await migrator.createTable(movieStates);
        await migrator.createIndex(moviesByCategory);
        await migrator.createIndex(moviesByPosition);
        await migrator.createIndex(movieStatesByMovie);
      }
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
