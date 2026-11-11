import 'package:drift/drift.dart';

import '../../../core/database/sync_columns.dart';
import '../../playlists/data/playlists_table.dart';
import '../../profiles/data/profiles_table.dart';

// Provider catalog data: a local cache every device loads from the provider
// itself, so these tables carry no sync columns.

@DataClassName('SeriesCategoryRow')
class SeriesCategories extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, categoryId};
}

@DataClassName('SeriesRow')
@TableIndex(
  name: 'series_by_category',
  columns: {#playlistId, #categoryId, #position},
)
@TableIndex(name: 'series_by_position', columns: {#playlistId, #position})
class SeriesItems extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get seriesId => integer()();
  TextColumn get name => text()();
  IntColumn get position => integer()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get backdropUrl => text().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get plot => text().nullable()();
  TextColumn get genre => text().nullable()();
  TextColumn get releaseDate => text().nullable()();

  /// Start time of the load that last delivered this series. Series from
  /// older loads are removed when a load completes.
  DateTimeColumn get seenInLoad => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, seriesId};
}

/// Favorite and last played episode of a series per profile (DATA-4).
@DataClassName('SeriesStateRow')
@TableIndex(
  name: 'series_states_by_series',
  columns: {#profileId, #playlistId, #seriesId},
  unique: true,
)
class SeriesStates extends Table with SyncColumns {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get seriesId => integer()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  IntColumn get lastEpisodeId => integer().nullable()();
  DateTimeColumn get lastWatchedAt => dateTime().nullable()();
}

/// Resume position and watched state of an episode per profile (DATA-4).
@DataClassName('EpisodeStateRow')
@TableIndex(
  name: 'episode_states_by_episode',
  columns: {#profileId, #playlistId, #seriesId, #episodeId},
  unique: true,
)
class EpisodeStates extends Table with SyncColumns {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get seriesId => integer()();
  IntColumn get episodeId => integer()();
  IntColumn get positionSeconds => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
}
