import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/series.dart';
import '../domain/series_repository.dart';

class DriftSeriesRepository implements SeriesRepository {
  DriftSeriesRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();
  static const _seriesKind = 'series';

  DateTime _now() => _clock().toUtc();

  @override
  Stream<List<SeriesCategory>> watchCategories(String playlistId) {
    final count = _db.seriesItems.seriesId.count();
    final query =
        _db.select(_db.seriesCategories).join([
            leftOuterJoin(
              _db.seriesItems,
              _db.seriesItems.playlistId.equalsExp(
                    _db.seriesCategories.playlistId,
                  ) &
                  _db.seriesItems.categoryId.equalsExp(
                    _db.seriesCategories.categoryId,
                  ),
              useColumns: false,
            ),
          ])
          ..addColumns([count])
          ..where(_db.seriesCategories.playlistId.equals(playlistId))
          ..groupBy([
            _db.seriesCategories.playlistId,
            _db.seriesCategories.categoryId,
          ])
          ..orderBy([OrderingTerm(expression: _db.seriesCategories.sortOrder)]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          if (row.read(count)! > 0)
            SeriesCategory(
              id: row.readTable(_db.seriesCategories).categoryId,
              name: row.readTable(_db.seriesCategories).name,
              seriesCount: row.read(count)!,
            ),
      ],
    );
  }

  /// Series of [filter] with their order. Favorites and continue watching
  /// join the states of [profileId]. [counting] selects only a count.
  JoinedSelectStatement<HasResultSet, dynamic> _query(
    String playlistId,
    VodFilter filter,
    String profileId, {
    Expression<int>? counting,
  }) {
    final series = _db.seriesItems;
    final states = _db.seriesStates;
    var where = series.playlistId.equals(playlistId);
    final categoryId = filter.categoryId;
    if (categoryId != null) where &= series.categoryId.equals(categoryId);

    final List<OrderingTerm> order;
    final List<Join<HasResultSet, dynamic>> joins;
    switch (filter.list) {
      case VodList.favorites:
        joins = [_stateJoin(profileId)];
        where &= states.favorite.equals(true);
        order = [OrderingTerm.desc(states.updatedAt)];
      case VodList.continueWatching:
        joins = [_stateJoin(profileId)];
        where &= states.lastWatchedAt.isNotNull();
        order = [OrderingTerm.desc(states.lastWatchedAt)];
      case VodList.all || null:
        joins = [];
        order = [OrderingTerm.asc(series.position)];
    }

    if (counting != null) {
      return _db.selectOnly(series).join(joins)
        ..addColumns([counting])
        ..where(where);
    }
    return _db.select(series).join(joins)
      ..where(where)
      ..orderBy([...order, OrderingTerm.asc(series.seriesId)]);
  }

  Join<HasResultSet, dynamic> _stateJoin(String profileId) => innerJoin(
    _db.seriesStates,
    _db.seriesStates.playlistId.equalsExp(_db.seriesItems.playlistId) &
        _db.seriesStates.seriesId.equalsExp(_db.seriesItems.seriesId) &
        _db.seriesStates.profileId.equals(profileId) &
        _db.seriesStates.deleted.equals(false),
    useColumns: false,
  );

  @override
  Stream<int> watchCount(
    String playlistId,
    VodFilter filter, {
    required String profileId,
  }) {
    final count = _db.seriesItems.seriesId.count();
    return _query(
      playlistId,
      filter,
      profileId,
      counting: count,
    ).map((row) => row.read(count)!).watchSingle();
  }

  @override
  Future<List<Series>> getSeries(
    String playlistId,
    VodFilter filter, {
    required String profileId,
    required int offset,
    required int limit,
  }) async {
    final query = _query(playlistId, filter, profileId)
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return [for (final row in rows) _toDomain(row.readTable(_db.seriesItems))];
  }

  @override
  Future<DateTime?> getLoadedAt(String playlistId) async =>
      (await (_db.select(_db.catalogStates)..where(
                (s) =>
                    s.playlistId.equals(playlistId) &
                    s.kind.equals(_seriesKind),
              ))
              .getSingleOrNull())
          ?.loadedAt;

  @override
  Future<void> replaceCategories(
    String playlistId,
    List<SeriesCategory> categories,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.seriesCategories,
    )..where((c) => c.playlistId.equals(playlistId))).go();
    await _db.batch((batch) {
      batch.insertAll(_db.seriesCategories, [
        for (final (index, category) in categories.indexed)
          SeriesCategoriesCompanion.insert(
            playlistId: playlistId,
            categoryId: category.id,
            name: category.name,
            sortOrder: index,
          ),
      ]);
    });
  });

  @override
  Future<void> upsertSeries(
    List<Series> series, {
    required DateTime loadStartedAt,
  }) => _db.batch((batch) {
    batch.insertAllOnConflictUpdate(_db.seriesItems, [
      for (final item in series)
        SeriesItemsCompanion.insert(
          playlistId: item.playlistId,
          seriesId: item.seriesId,
          name: item.name,
          position: item.position,
          coverUrl: Value(item.coverUrl),
          backdropUrl: Value(item.backdropUrl),
          rating: Value(item.rating),
          categoryId: Value(item.categoryId),
          plot: Value(item.plot),
          genre: Value(item.genre),
          releaseDate: Value(item.releaseDate),
          seenInLoad: loadStartedAt,
        ),
    ]);
  });

  @override
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  }) => _db.transaction(() async {
    await (_db.delete(_db.seriesItems)..where(
          (s) =>
              s.playlistId.equals(playlistId) &
              s.seenInLoad.isSmallerThanValue(loadStartedAt),
        ))
        .go();
    await _db
        .into(_db.catalogStates)
        .insertOnConflictUpdate(
          CatalogStatesCompanion.insert(
            playlistId: playlistId,
            kind: _seriesKind,
            loadedAt: _now(),
          ),
        );
  });

  @override
  Future<void> deleteForPlaylist(
    String playlistId,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.seriesItems,
    )..where((s) => s.playlistId.equals(playlistId))).go();
    await (_db.delete(
      _db.seriesCategories,
    )..where((c) => c.playlistId.equals(playlistId))).go();
    await (_db.delete(_db.catalogStates)..where(
          (s) => s.playlistId.equals(playlistId) & s.kind.equals(_seriesKind),
        ))
        .go();
    const deleted = Value(true);
    final updatedAt = Value(_now());
    await (_db.update(_db.seriesStates)
          ..where((s) => s.playlistId.equals(playlistId)))
        .write(SeriesStatesCompanion(deleted: deleted, updatedAt: updatedAt));
    await (_db.update(_db.episodeStates)
          ..where((s) => s.playlistId.equals(playlistId)))
        .write(EpisodeStatesCompanion(deleted: deleted, updatedAt: updatedAt));
  });

  /// The row of a series, also a deleted one: it keeps the unique key, so
  /// it is revived instead of a new row being inserted.
  Future<SeriesStateRow?> _seriesRow(
    String profileId,
    String playlistId,
    int seriesId,
  ) =>
      (_db.select(_db.seriesStates)..where(
            (s) =>
                s.profileId.equals(profileId) &
                s.playlistId.equals(playlistId) &
                s.seriesId.equals(seriesId),
          ))
          .getSingleOrNull();

  @override
  Stream<SeriesState> watchSeriesState(
    String profileId,
    String playlistId,
    int seriesId,
  ) =>
      (_db.select(_db.seriesStates)..where(
            (s) =>
                s.profileId.equals(profileId) &
                s.playlistId.equals(playlistId) &
                s.seriesId.equals(seriesId) &
                s.deleted.equals(false),
          ))
          .watchSingleOrNull()
          .map(_seriesStateToDomain);

  @override
  Future<SeriesState> getSeriesState(
    String profileId,
    String playlistId,
    int seriesId,
  ) async {
    final row = await _seriesRow(profileId, playlistId, seriesId);
    return _seriesStateToDomain(row == null || row.deleted ? null : row);
  }

  Future<void> _writeSeriesState(
    String profileId,
    String playlistId,
    int seriesId,
    SeriesStatesCompanion values,
  ) async {
    final now = _now();
    final row = await _seriesRow(profileId, playlistId, seriesId);
    final changes = values.copyWith(
      deleted: const Value(false),
      updatedAt: Value(now),
    );
    if (row == null) {
      await _db
          .into(_db.seriesStates)
          .insert(
            changes.copyWith(
              id: Value(_uuid.v7()),
              createdAt: Value(now),
              profileId: Value(profileId),
              playlistId: Value(playlistId),
              seriesId: Value(seriesId),
            ),
          );
    } else {
      // A revived row starts without its old favorite and progress.
      final reset = row.deleted
          ? const SeriesStatesCompanion(
              favorite: Value(false),
              lastEpisodeId: Value(null),
              lastWatchedAt: Value(null),
            )
          : const SeriesStatesCompanion();
      await (_db.update(
        _db.seriesStates,
      )..where((s) => s.id.equals(row.id))).write(
        SeriesStatesCompanion(
          favorite: changes.favorite.present
              ? changes.favorite
              : reset.favorite,
          lastEpisodeId: changes.lastEpisodeId.present
              ? changes.lastEpisodeId
              : reset.lastEpisodeId,
          lastWatchedAt: changes.lastWatchedAt.present
              ? changes.lastWatchedAt
              : reset.lastWatchedAt,
          deleted: changes.deleted,
          updatedAt: changes.updatedAt,
        ),
      );
    }
  }

  @override
  Future<void> setFavorite(
    String profileId,
    String playlistId,
    int seriesId, {
    required bool favorite,
  }) => _writeSeriesState(
    profileId,
    playlistId,
    seriesId,
    SeriesStatesCompanion(favorite: Value(favorite)),
  );

  @override
  Stream<Map<int, EpisodeState>> watchEpisodeStates(
    String profileId,
    String playlistId,
    int seriesId,
  ) =>
      (_db.select(_db.episodeStates)..where(
            (s) =>
                s.profileId.equals(profileId) &
                s.playlistId.equals(playlistId) &
                s.seriesId.equals(seriesId) &
                s.deleted.equals(false),
          ))
          .watch()
          .map(
            (rows) => {
              for (final row in rows)
                row.episodeId: EpisodeState(
                  position: Duration(seconds: row.positionSeconds),
                  duration: row.durationSeconds == null
                      ? null
                      : Duration(seconds: row.durationSeconds!),
                  watched: row.watched,
                ),
            },
          );

  @override
  Future<void> saveEpisodeState(
    String profileId,
    String playlistId,
    int seriesId,
    int episodeId,
    EpisodeState state,
  ) => _db.transaction(() async {
    final now = _now();
    final existing =
        await (_db.select(_db.episodeStates)..where(
              (s) =>
                  s.profileId.equals(profileId) &
                  s.playlistId.equals(playlistId) &
                  s.seriesId.equals(seriesId) &
                  s.episodeId.equals(episodeId),
            ))
            .getSingleOrNull();
    final values = EpisodeStatesCompanion(
      positionSeconds: Value(state.position.inSeconds),
      durationSeconds: Value(state.duration?.inSeconds),
      watched: Value(state.watched),
      deleted: const Value(false),
      updatedAt: Value(now),
    );
    if (existing == null) {
      await _db
          .into(_db.episodeStates)
          .insert(
            values.copyWith(
              id: Value(_uuid.v7()),
              createdAt: Value(now),
              profileId: Value(profileId),
              playlistId: Value(playlistId),
              seriesId: Value(seriesId),
              episodeId: Value(episodeId),
            ),
          );
    } else {
      await (_db.update(
        _db.episodeStates,
      )..where((s) => s.id.equals(existing.id))).write(values);
    }
    await _writeSeriesState(
      profileId,
      playlistId,
      seriesId,
      SeriesStatesCompanion(
        lastEpisodeId: Value(episodeId),
        lastWatchedAt: Value(now),
      ),
    );
  });

  @override
  Future<void> deleteStatesForProfile(
    String profileId,
  ) => _db.transaction(() async {
    const deleted = Value(true);
    final updatedAt = Value(_now());
    await (_db.update(_db.seriesStates)
          ..where((s) => s.profileId.equals(profileId)))
        .write(SeriesStatesCompanion(deleted: deleted, updatedAt: updatedAt));
    await (_db.update(_db.episodeStates)
          ..where((s) => s.profileId.equals(profileId)))
        .write(EpisodeStatesCompanion(deleted: deleted, updatedAt: updatedAt));
  });

  static SeriesState _seriesStateToDomain(SeriesStateRow? row) => row == null
      ? SeriesState.initial
      : SeriesState(favorite: row.favorite, lastEpisodeId: row.lastEpisodeId);

  static Series _toDomain(SeriesRow row) => Series(
    playlistId: row.playlistId,
    seriesId: row.seriesId,
    name: row.name,
    position: row.position,
    coverUrl: row.coverUrl,
    backdropUrl: row.backdropUrl,
    rating: row.rating,
    categoryId: row.categoryId,
    plot: row.plot,
    genre: row.genre,
    releaseDate: row.releaseDate,
  );
}
