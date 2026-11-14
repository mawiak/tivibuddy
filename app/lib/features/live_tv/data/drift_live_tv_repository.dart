import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/like_pattern.dart';
import '../domain/live_channel.dart';
import '../domain/live_tv_repository.dart';

class DriftLiveTvRepository implements LiveTvRepository {
  DriftLiveTvRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const _liveKind = 'live';

  @override
  Stream<List<LiveCategory>> watchCategories(String playlistId) {
    final count = _db.liveChannels.streamId.count();
    final query =
        _db.select(_db.liveCategories).join([
            leftOuterJoin(
              _db.liveChannels,
              _db.liveChannels.playlistId.equalsExp(
                    _db.liveCategories.playlistId,
                  ) &
                  _db.liveChannels.categoryId.equalsExp(
                    _db.liveCategories.categoryId,
                  ),
              useColumns: false,
            ),
          ])
          ..addColumns([count])
          ..where(_db.liveCategories.playlistId.equals(playlistId))
          ..groupBy([
            _db.liveCategories.playlistId,
            _db.liveCategories.categoryId,
          ])
          ..orderBy([OrderingTerm(expression: _db.liveCategories.sortOrder)]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          if (row.read(count)! > 0)
            LiveCategory(
              id: row.readTable(_db.liveCategories).categoryId,
              name: row.readTable(_db.liveCategories).name,
              channelCount: row.read(count)!,
            ),
      ],
    );
  }

  Expression<bool> _channelFilter(String playlistId, String? categoryId) {
    final inPlaylist = _db.liveChannels.playlistId.equals(playlistId);
    return categoryId == null
        ? inPlaylist
        : inPlaylist & _db.liveChannels.categoryId.equals(categoryId);
  }

  @override
  Stream<int> watchChannelCount(String playlistId, {String? categoryId}) {
    final count = _db.liveChannels.streamId.count();
    return (_db.selectOnly(_db.liveChannels)
          ..addColumns([count])
          ..where(_channelFilter(playlistId, categoryId)))
        .map((row) => row.read(count)!)
        .watchSingle();
  }

  @override
  Future<List<LiveChannel>> getChannels(
    String playlistId, {
    String? categoryId,
    required int offset,
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.liveChannels)
              ..where((_) => _channelFilter(playlistId, categoryId))
              ..orderBy([
                (c) => OrderingTerm(expression: c.number),
                (c) => OrderingTerm(expression: c.streamId),
              ])
              ..limit(limit, offset: offset))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<LiveChannel>> search(
    String playlistId,
    String query, {
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.liveChannels)
              ..where(
                (c) =>
                    c.playlistId.equals(playlistId) &
                    c.name.like(likePattern(query), escapeChar: likeEscape),
              )
              ..orderBy([
                (c) => OrderingTerm(expression: c.number),
                (c) => OrderingTerm(expression: c.streamId),
              ])
              ..limit(limit))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<int> indexOf(LiveChannel channel, {String? categoryId}) async {
    final count = _db.liveChannels.streamId.count();
    final c = _db.liveChannels;
    // Channels before it in the order of getChannels: number, then id.
    final before =
        c.number.isSmallerThanValue(channel.number) |
        (c.number.equals(channel.number) &
            c.streamId.isSmallerThanValue(channel.streamId));
    final row =
        await (_db.selectOnly(c)
              ..addColumns([count])
              ..where(_channelFilter(channel.playlistId, categoryId) & before))
            .getSingle();
    return row.read(count)!;
  }

  @override
  Future<Set<String>> getEpgChannelIds(String playlistId) async {
    final key = _db.liveChannels.epgChannelId;
    final rows =
        await (_db.selectOnly(_db.liveChannels, distinct: true)
              ..addColumns([key])
              ..where(
                _db.liveChannels.playlistId.equals(playlistId) &
                    key.isNotNull(),
              ))
            .get();
    return {for (final row in rows) row.read(key)!};
  }

  SimpleSelectStatement<$CatalogStatesTable, CatalogStateRow> _state(
    String playlistId,
  ) => _db.select(_db.catalogStates)
    ..where((s) => s.playlistId.equals(playlistId) & s.kind.equals(_liveKind));

  @override
  Stream<DateTime?> watchLoadedAt(String playlistId) =>
      _state(playlistId).watchSingleOrNull().map((row) => row?.loadedAt);

  @override
  Future<DateTime?> getLoadedAt(String playlistId) async =>
      (await _state(playlistId).getSingleOrNull())?.loadedAt;

  @override
  Future<void> replaceCategories(
    String playlistId,
    List<LiveCategory> categories,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.liveCategories,
    )..where((c) => c.playlistId.equals(playlistId))).go();
    await _db.batch((batch) {
      batch.insertAll(_db.liveCategories, [
        for (final (index, category) in categories.indexed)
          LiveCategoriesCompanion.insert(
            playlistId: playlistId,
            categoryId: category.id,
            name: category.name,
            sortOrder: index,
          ),
      ]);
    });
  });

  @override
  Future<void> upsertChannels(
    List<LiveChannel> channels, {
    required DateTime loadStartedAt,
  }) => _db.batch((batch) {
    batch.insertAllOnConflictUpdate(_db.liveChannels, [
      for (final channel in channels)
        LiveChannelsCompanion.insert(
          playlistId: channel.playlistId,
          streamId: channel.streamId,
          number: channel.number,
          name: channel.name,
          logoUrl: Value(channel.logoUrl),
          epgChannelId: Value(channel.epgChannelId),
          categoryId: Value(channel.categoryId),
          archiveDays: Value(channel.archiveDays),
          seenInLoad: loadStartedAt,
        ),
    ]);
  });

  @override
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  }) => _db.transaction(() async {
    await (_db.delete(_db.liveChannels)..where(
          (c) =>
              c.playlistId.equals(playlistId) &
              c.seenInLoad.isSmallerThanValue(loadStartedAt),
        ))
        .go();
    await _db
        .into(_db.catalogStates)
        .insertOnConflictUpdate(
          CatalogStatesCompanion.insert(
            playlistId: playlistId,
            kind: _liveKind,
            loadedAt: _clock().toUtc(),
          ),
        );
  });

  @override
  Future<void> deleteForPlaylist(String playlistId) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.liveChannels,
        )..where((c) => c.playlistId.equals(playlistId))).go();
        await (_db.delete(
          _db.liveCategories,
        )..where((c) => c.playlistId.equals(playlistId))).go();
        await (_db.delete(
          _db.catalogStates,
        )..where((c) => c.playlistId.equals(playlistId))).go();
      });

  static LiveChannel _toDomain(LiveChannelRow row) => LiveChannel(
    playlistId: row.playlistId,
    streamId: row.streamId,
    number: row.number,
    name: row.name,
    logoUrl: row.logoUrl,
    epgChannelId: row.epgChannelId,
    categoryId: row.categoryId,
    archiveDays: row.archiveDays,
  );
}
