import 'package:drift/drift.dart';

import '../../playlists/data/playlists_table.dart';

// Provider catalog data. It is a local cache that every device loads from
// the provider itself, so these tables carry no sync columns.

@DataClassName('LiveCategoryRow')
class LiveCategories extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, categoryId};
}

@DataClassName('LiveChannelRow')
@TableIndex(
  name: 'live_channels_by_category',
  columns: {#playlistId, #categoryId, #number},
)
@TableIndex(name: 'live_channels_by_number', columns: {#playlistId, #number})
class LiveChannels extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  IntColumn get streamId => integer()();
  IntColumn get number => integer()();
  TextColumn get name => text()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get epgChannelId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get archiveDays => integer().withDefault(const Constant(0))();

  /// Start time of the load that last delivered this channel. Channels from
  /// older loads are removed when a load completes.
  DateTimeColumn get seenInLoad => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, streamId};
}

/// Completion time of the last full catalog load per playlist.
@DataClassName('CatalogStateRow')
class CatalogStates extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get kind => text()();
  DateTimeColumn get loadedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, kind};
}

/// Programmes of the provider guide. Times are stored as seconds since the
/// epoch: guides have hundreds of thousands of rows, and integers keep the
/// table and its range queries small.
@DataClassName('EpgProgrammeRow')
class EpgProgrammes extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get channelKey => text()();
  IntColumn get startsAt => integer()();
  IntColumn get endsAt => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  /// Start time (milliseconds) of the load that last delivered this
  /// programme.
  IntColumn get seenInLoad => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, channelKey, startsAt};

  @override
  bool get withoutRowId => true;
}
