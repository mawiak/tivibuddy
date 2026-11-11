import 'package:drift/drift.dart';

import '../../../core/database/sync_columns.dart';
import '../../profiles/data/profiles_table.dart';
import '../domain/playlist.dart';

@DataClassName('PlaylistRow')
class Playlists extends Table with SyncColumns {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get type => textEnum<PlaylistType>()();
  TextColumn get name => text()();
  TextColumn get serverUrl => text()();
  TextColumn get username => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  // Account state from the last successful connection test.
  TextColumn get accountStatus => text().nullable()();
  DateTimeColumn get accountCheckedAt => dateTime().nullable()();
  DateTimeColumn get accountExpiresAt => dateTime().nullable()();
  IntColumn get accountMaxConnections => integer().nullable()();
  IntColumn get accountActiveConnections => integer().nullable()();
}
