import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/epg_repository.dart';
import '../domain/live_channel.dart';

class DriftEpgRepository implements EpgRepository {
  DriftEpgRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const _epgKind = 'epg';

  /// Longest programme the range query looks back for. A bound on the start
  /// lets SQLite use the primary key for the range instead of scanning all
  /// earlier programmes of the channel.
  static const _maxDuration = Duration(hours: 24);

  static int _seconds(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

  static DateTime _time(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

  @override
  Future<List<EpgEntry>> getProgrammes(
    String playlistId,
    String channelKey, {
    required DateTime from,
    required DateTime to,
  }) async {
    final rows =
        await (_db.select(_db.epgProgrammes)
              ..where(
                (p) =>
                    p.playlistId.equals(playlistId) &
                    p.channelKey.equals(channelKey) &
                    p.startsAt.isBiggerThanValue(
                      _seconds(from.subtract(_maxDuration)),
                    ) &
                    p.startsAt.isSmallerThanValue(_seconds(to)) &
                    p.endsAt.isBiggerThanValue(_seconds(from)),
              )
              ..orderBy([(p) => OrderingTerm(expression: p.startsAt)]))
            .get();
    return [
      for (final row in rows)
        EpgEntry(
          title: row.title,
          description: row.description,
          start: _time(row.startsAt),
          end: _time(row.endsAt),
        ),
    ];
  }

  SimpleSelectStatement<$CatalogStatesTable, CatalogStateRow> _state(
    String playlistId,
  ) => _db.select(_db.catalogStates)
    ..where((s) => s.playlistId.equals(playlistId) & s.kind.equals(_epgKind));

  @override
  Stream<DateTime?> watchLoadedAt(String playlistId) =>
      _state(playlistId).watchSingleOrNull().map((row) => row?.loadedAt);

  @override
  Future<DateTime?> getLoadedAt(String playlistId) async =>
      (await _state(playlistId).getSingleOrNull())?.loadedAt;

  @override
  Future<void> upsertProgrammes(
    String playlistId,
    List<EpgProgramme> programmes, {
    required DateTime loadStartedAt,
  }) => _db.batch((batch) {
    final seenInLoad = loadStartedAt.millisecondsSinceEpoch;
    batch.insertAllOnConflictUpdate(_db.epgProgrammes, [
      for (final programme in programmes)
        EpgProgrammesCompanion.insert(
          playlistId: playlistId,
          channelKey: programme.channelKey,
          startsAt: _seconds(programme.start),
          endsAt: _seconds(programme.end),
          title: programme.title,
          description: Value(programme.description),
          seenInLoad: seenInLoad,
        ),
    ]);
  });

  @override
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  }) => _db.transaction(() async {
    await (_db.delete(_db.epgProgrammes)..where(
          (p) =>
              p.playlistId.equals(playlistId) &
              p.seenInLoad.isSmallerThanValue(
                loadStartedAt.millisecondsSinceEpoch,
              ),
        ))
        .go();
    await _db
        .into(_db.catalogStates)
        .insertOnConflictUpdate(
          CatalogStatesCompanion.insert(
            playlistId: playlistId,
            kind: _epgKind,
            loadedAt: _clock().toUtc(),
          ),
        );
  });

  @override
  Future<void> deleteForPlaylist(String playlistId) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.epgProgrammes,
        )..where((p) => p.playlistId.equals(playlistId))).go();
        await (_db.delete(_db.catalogStates)..where(
              (s) => s.playlistId.equals(playlistId) & s.kind.equals(_epgKind),
            ))
            .go();
      });

  @override
  Future<void> markAllOutdated() => (_db.delete(
    _db.catalogStates,
  )..where((s) => s.kind.equals(_epgKind))).go();

  @override
  Future<void> deleteAll() => _db.transaction(() async {
    await _db.delete(_db.epgProgrammes).go();
    await markAllOutdated();
  });
}
