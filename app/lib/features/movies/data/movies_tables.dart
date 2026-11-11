import 'package:drift/drift.dart';

import '../../../core/database/sync_columns.dart';
import '../../playlists/data/playlists_table.dart';
import '../../profiles/data/profiles_table.dart';

// Provider catalog data: a local cache every device loads from the provider
// itself, so these tables carry no sync columns.

@DataClassName('MovieCategoryRow')
class MovieCategories extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, categoryId};
}

@DataClassName('MovieRow')
@TableIndex(
  name: 'movies_by_category',
  columns: {#playlistId, #categoryId, #position},
)
@TableIndex(name: 'movies_by_position', columns: {#playlistId, #position})
class Movies extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get streamId => integer()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  TextColumn get posterUrl => text().nullable()();
  RealColumn get rating => real().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get containerExtension => text().nullable()();

  /// Start time of the load that last delivered this movie. Movies from
  /// older loads are removed when a load completes.
  DateTimeColumn get seenInLoad => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, streamId};
}

/// Resume position, watched state and favorite of a movie per profile
/// (DATA-4). Synchronized, so movies are identified by playlist and stream
/// id, which are the same on every device.
@DataClassName('MovieStateRow')
@TableIndex(
  name: 'movie_states_by_movie',
  columns: {#profileId, #playlistId, #streamId},
  unique: true,
)
class MovieStates extends Table with SyncColumns {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get streamId => integer()();
  IntColumn get positionSeconds => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastWatchedAt => dateTime().nullable()();
}
