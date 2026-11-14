import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/like_pattern.dart';
import '../domain/movie.dart';
import '../domain/movie_repository.dart';

class DriftMovieRepository implements MovieRepository {
  DriftMovieRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();
  static const _vodKind = 'vod';

  DateTime _now() => _clock().toUtc();

  /// Below this position a movie counts as not started.
  static const _resumeFrom = 60;

  @override
  Stream<List<MovieCategory>> watchCategories(String playlistId) {
    final count = _db.movies.streamId.count();
    final query =
        _db.select(_db.movieCategories).join([
            leftOuterJoin(
              _db.movies,
              _db.movies.playlistId.equalsExp(_db.movieCategories.playlistId) &
                  _db.movies.categoryId.equalsExp(
                    _db.movieCategories.categoryId,
                  ),
              useColumns: false,
            ),
          ])
          ..addColumns([count])
          ..where(_db.movieCategories.playlistId.equals(playlistId))
          ..groupBy([
            _db.movieCategories.playlistId,
            _db.movieCategories.categoryId,
          ])
          ..orderBy([OrderingTerm(expression: _db.movieCategories.sortOrder)]);

    return query.watch().map(
      (rows) => [
        for (final row in rows)
          if (row.read(count)! > 0)
            MovieCategory(
              id: row.readTable(_db.movieCategories).categoryId,
              name: row.readTable(_db.movieCategories).name,
              movieCount: row.read(count)!,
            ),
      ],
    );
  }

  /// Movies of [filter] with their order. Favorites and continue watching
  /// join the states of [profileId]. [counting] selects only a count.
  JoinedSelectStatement<HasResultSet, dynamic> _query(
    String playlistId,
    VodFilter filter,
    String profileId, {
    Expression<int>? counting,
  }) {
    final movies = _db.movies;
    final states = _db.movieStates;
    var where = movies.playlistId.equals(playlistId);
    final categoryId = filter.categoryId;
    if (categoryId != null) where &= movies.categoryId.equals(categoryId);

    final List<OrderingTerm> order;
    final List<Join<HasResultSet, dynamic>> joins;
    switch (filter.list) {
      case VodList.favorites:
        joins = [_stateJoin(profileId)];
        where &= states.favorite.equals(true);
        order = [OrderingTerm.desc(states.updatedAt)];
      case VodList.continueWatching:
        joins = [_stateJoin(profileId)];
        where &=
            states.watched.equals(false) &
            states.positionSeconds.isBiggerOrEqualValue(_resumeFrom);
        order = [OrderingTerm.desc(states.lastWatchedAt)];
      case VodList.all || null:
        joins = [];
        order = [OrderingTerm.asc(movies.position)];
    }

    if (counting != null) {
      return _db.selectOnly(movies).join(joins)
        ..addColumns([counting])
        ..where(where);
    }
    return _db.select(movies).join(joins)
      ..where(where)
      ..orderBy([...order, OrderingTerm.asc(movies.streamId)]);
  }

  Join<HasResultSet, dynamic> _stateJoin(String profileId) => innerJoin(
    _db.movieStates,
    _db.movieStates.playlistId.equalsExp(_db.movies.playlistId) &
        _db.movieStates.streamId.equalsExp(_db.movies.streamId) &
        _db.movieStates.profileId.equals(profileId) &
        _db.movieStates.deleted.equals(false),
    useColumns: false,
  );

  @override
  Stream<int> watchCount(
    String playlistId,
    VodFilter filter, {
    required String profileId,
  }) {
    final count = _db.movies.streamId.count();
    return _query(
      playlistId,
      filter,
      profileId,
      counting: count,
    ).map((row) => row.read(count)!).watchSingle();
  }

  @override
  Future<List<Movie>> getMovies(
    String playlistId,
    VodFilter filter, {
    required String profileId,
    required int offset,
    required int limit,
  }) async {
    final query = _query(playlistId, filter, profileId)
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return [for (final row in rows) _toDomain(row.readTable(_db.movies))];
  }

  @override
  Future<List<Movie>> search(
    String playlistId,
    String query, {
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.movies)
              ..where(
                (m) =>
                    m.playlistId.equals(playlistId) &
                    m.name.like(likePattern(query), escapeChar: likeEscape),
              )
              ..orderBy([(m) => OrderingTerm(expression: m.position)])
              ..limit(limit))
            .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Movie?> getMovie(String playlistId, int streamId) async {
    final row =
        await (_db.select(_db.movies)..where(
              (m) =>
                  m.playlistId.equals(playlistId) & m.streamId.equals(streamId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<DateTime?> getLoadedAt(String playlistId) async =>
      (await (_db.select(_db.catalogStates)..where(
                (s) =>
                    s.playlistId.equals(playlistId) & s.kind.equals(_vodKind),
              ))
              .getSingleOrNull())
          ?.loadedAt;

  @override
  Future<void> replaceCategories(
    String playlistId,
    List<MovieCategory> categories,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.movieCategories,
    )..where((c) => c.playlistId.equals(playlistId))).go();
    await _db.batch((batch) {
      batch.insertAll(_db.movieCategories, [
        for (final (index, category) in categories.indexed)
          MovieCategoriesCompanion.insert(
            playlistId: playlistId,
            categoryId: category.id,
            name: category.name,
            sortOrder: index,
          ),
      ]);
    });
  });

  @override
  Future<void> upsertMovies(
    List<Movie> movies, {
    required DateTime loadStartedAt,
  }) => _db.batch((batch) {
    batch.insertAllOnConflictUpdate(_db.movies, [
      for (final movie in movies)
        MoviesCompanion.insert(
          playlistId: movie.playlistId,
          streamId: movie.streamId,
          name: movie.name,
          position: movie.position,
          posterUrl: Value(movie.posterUrl),
          rating: Value(movie.rating),
          addedAt: Value(movie.addedAt),
          categoryId: Value(movie.categoryId),
          containerExtension: Value(movie.containerExtension),
          seenInLoad: loadStartedAt,
        ),
    ]);
  });

  @override
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  }) => _db.transaction(() async {
    await (_db.delete(_db.movies)..where(
          (m) =>
              m.playlistId.equals(playlistId) &
              m.seenInLoad.isSmallerThanValue(loadStartedAt),
        ))
        .go();
    await _db
        .into(_db.catalogStates)
        .insertOnConflictUpdate(
          CatalogStatesCompanion.insert(
            playlistId: playlistId,
            kind: _vodKind,
            loadedAt: _now(),
          ),
        );
  });

  @override
  Future<void> deleteForPlaylist(String playlistId) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.movies,
        )..where((m) => m.playlistId.equals(playlistId))).go();
        await (_db.delete(
          _db.movieCategories,
        )..where((c) => c.playlistId.equals(playlistId))).go();
        await (_db.delete(_db.catalogStates)..where(
              (s) => s.playlistId.equals(playlistId) & s.kind.equals(_vodKind),
            ))
            .go();
        await (_db.update(
          _db.movieStates,
        )..where((s) => s.playlistId.equals(playlistId))).write(
          MovieStatesCompanion(
            deleted: const Value(true),
            updatedAt: Value(_now()),
          ),
        );
      });

  SimpleSelectStatement<$MovieStatesTable, MovieStateRow> _state(
    String profileId,
    String playlistId,
    int streamId,
  ) => _db.select(_db.movieStates)
    ..where(
      (s) =>
          s.profileId.equals(profileId) &
          s.playlistId.equals(playlistId) &
          s.streamId.equals(streamId) &
          s.deleted.equals(false),
    );

  @override
  Stream<MovieState> watchState(
    String profileId,
    String playlistId,
    int streamId,
  ) => _state(
    profileId,
    playlistId,
    streamId,
  ).watchSingleOrNull().map(_stateToDomain);

  @override
  Future<MovieState> getState(
    String profileId,
    String playlistId,
    int streamId,
  ) async => _stateToDomain(
    await _state(profileId, playlistId, streamId).getSingleOrNull(),
  );

  @override
  Future<void> saveState(
    String profileId,
    String playlistId,
    int streamId,
    MovieState state,
  ) async {
    final now = _now();
    // A deleted row keeps the unique key, so it is revived instead of a new
    // row being inserted.
    final existing =
        await (_db.select(_db.movieStates)..where(
              (s) =>
                  s.profileId.equals(profileId) &
                  s.playlistId.equals(playlistId) &
                  s.streamId.equals(streamId),
            ))
            .getSingleOrNull();
    final values = MovieStatesCompanion(
      positionSeconds: Value(state.position.inSeconds),
      durationSeconds: Value(state.duration?.inSeconds),
      watched: Value(state.watched),
      favorite: Value(state.favorite),
      deleted: const Value(false),
      updatedAt: Value(now),
      lastWatchedAt: state.position > Duration.zero || state.watched
          ? Value(now)
          : const Value.absent(),
    );
    if (existing == null) {
      await _db
          .into(_db.movieStates)
          .insert(
            values.copyWith(
              id: Value(_uuid.v7()),
              createdAt: Value(now),
              profileId: Value(profileId),
              playlistId: Value(playlistId),
              streamId: Value(streamId),
            ),
          );
    } else {
      await (_db.update(
        _db.movieStates,
      )..where((s) => s.id.equals(existing.id))).write(values);
    }
  }

  @override
  Future<void> deleteStatesForProfile(String profileId) =>
      (_db.update(
        _db.movieStates,
      )..where((s) => s.profileId.equals(profileId))).write(
        MovieStatesCompanion(
          deleted: const Value(true),
          updatedAt: Value(_now()),
        ),
      );

  static MovieState _stateToDomain(MovieStateRow? row) => row == null
      ? MovieState.initial
      : MovieState(
          position: Duration(seconds: row.positionSeconds),
          duration: row.durationSeconds == null
              ? null
              : Duration(seconds: row.durationSeconds!),
          watched: row.watched,
          favorite: row.favorite,
        );

  static Movie _toDomain(MovieRow row) => Movie(
    playlistId: row.playlistId,
    streamId: row.streamId,
    name: row.name,
    position: row.position,
    posterUrl: row.posterUrl,
    rating: row.rating,
    addedAt: row.addedAt,
    categoryId: row.categoryId,
    containerExtension: row.containerExtension,
  );
}
