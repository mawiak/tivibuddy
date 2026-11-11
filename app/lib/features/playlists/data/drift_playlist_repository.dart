import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/playlist.dart';
import '../domain/playlist_repository.dart';

class DriftPlaylistRepository implements PlaylistRepository {
  DriftPlaylistRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime _now() => _clock().toUtc();

  SimpleSelectStatement<$PlaylistsTable, PlaylistRow> _forProfile(
    String profileId,
  ) => _db.select(_db.playlists)
    ..where((p) => p.profileId.equals(profileId) & p.deleted.equals(false))
    ..orderBy([
      (p) => OrderingTerm(expression: p.sortOrder),
      (p) => OrderingTerm(expression: p.createdAt),
    ]);

  @override
  Stream<List<Playlist>> watchForProfile(String profileId) =>
      _forProfile(profileId)
          .watch()
          .map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<Playlist>> getForProfile(String profileId) async =>
      (await _forProfile(profileId).get()).map(_toDomain).toList();

  @override
  Future<Playlist?> findById(String id) async {
    final row =
        await (_db.select(_db.playlists)
              ..where((p) => p.id.equals(id) & p.deleted.equals(false)))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Playlist> create({
    required String profileId,
    required PlaylistType type,
    required String name,
    required String serverUrl,
    required String username,
  }) async {
    final now = _now();
    final id = _uuid.v7();
    await _db.transaction(() async {
      final maxOrder = _db.playlists.sortOrder.max();
      final lastOrder =
          await (_db.selectOnly(_db.playlists)
                ..addColumns([maxOrder])
                ..where(_db.playlists.profileId.equals(profileId)))
              .map((row) => row.read(maxOrder))
              .getSingle();

      await _db
          .into(_db.playlists)
          .insert(
            PlaylistsCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              profileId: profileId,
              type: type,
              name: name.trim(),
              serverUrl: serverUrl,
              username: username.trim(),
              sortOrder: Value((lastOrder ?? -1) + 1),
            ),
          );
    });
    return (await findById(id))!;
  }

  @override
  Future<void> update(
    String id, {
    required String name,
    required String serverUrl,
    required String username,
  }) => _write(
    id,
    PlaylistsCompanion(
      name: Value(name.trim()),
      serverUrl: Value(serverUrl),
      username: Value(username.trim()),
    ),
  );

  @override
  Future<void> saveAccountInfo(String id, AccountInfo account) => _write(
    id,
    PlaylistsCompanion(
      accountStatus: Value(account.status),
      accountCheckedAt: Value(account.checkedAt.toUtc()),
      accountExpiresAt: Value(account.expiresAt?.toUtc()),
      accountMaxConnections: Value(account.maxConnections),
      accountActiveConnections: Value(account.activeConnections),
    ),
  );

  @override
  Future<void> delete(String id) =>
      _write(id, const PlaylistsCompanion(deleted: Value(true)));

  @override
  Future<List<String>> deleteAllForProfile(String profileId) =>
      _db.transaction(() async {
        final ids = (await getForProfile(profileId)).map((p) => p.id).toList();
        await (_db.update(
          _db.playlists,
        )..where((p) => p.profileId.equals(profileId))).write(
          PlaylistsCompanion(
            deleted: const Value(true),
            updatedAt: Value(_now()),
          ),
        );
        return ids;
      });

  Future<void> _write(String id, PlaylistsCompanion changes) async {
    final updated =
        await (_db.update(_db.playlists)
              ..where((p) => p.id.equals(id) & p.deleted.equals(false)))
            .write(changes.copyWith(updatedAt: Value(_now())));
    if (updated == 0) throw StateError('Playlist $id does not exist');
  }

  Playlist _toDomain(PlaylistRow row) {
    final status = row.accountStatus;
    final checkedAt = row.accountCheckedAt;
    return Playlist(
      id: row.id,
      profileId: row.profileId,
      type: row.type,
      name: row.name,
      serverUrl: row.serverUrl,
      username: row.username,
      sortOrder: row.sortOrder,
      account: status == null || checkedAt == null
          ? null
          : AccountInfo(
              status: status,
              checkedAt: checkedAt,
              expiresAt: row.accountExpiresAt,
              maxConnections: row.accountMaxConnections,
              activeConnections: row.accountActiveConnections,
            ),
    );
  }
}
