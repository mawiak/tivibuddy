import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import 'pin_hasher.dart';

class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(
    this._db, {
    PinHasher? pinHasher,
    DateTime Function()? clock,
  }) : _pinHasher = pinHasher ?? PinHasher(),
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final PinHasher _pinHasher;
  final DateTime Function() _clock;
  static const _uuid = Uuid();

  DateTime _now() => _clock().toUtc();

  SimpleSelectStatement<$ProfilesTable, ProfileRow> _activeProfiles() =>
      _db.select(_db.profiles)
        ..where((p) => p.deleted.equals(false))
        ..orderBy([
          (p) => OrderingTerm(expression: p.sortOrder),
          (p) => OrderingTerm(expression: p.createdAt),
        ]);

  @override
  Stream<List<Profile>> watchAll() =>
      _activeProfiles().watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<Profile>> getAll() async =>
      (await _activeProfiles().get()).map(_toDomain).toList();

  @override
  Future<Profile?> findById(String id) async {
    final row = await _findRow(id);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Profile> create({
    required String name,
    required ProfileAvatar avatar,
    String? pin,
  }) async {
    _checkName(name);
    if (pin != null) _checkPin(pin);

    final now = _now();
    final id = _uuid.v7();
    await _db.transaction(() async {
      final maxOrder = _db.profiles.sortOrder.max();
      final lastOrder = await (_db.selectOnly(
        _db.profiles,
      )..addColumns([maxOrder])).map((row) => row.read(maxOrder)).getSingle();

      await _db
          .into(_db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              name: name.trim(),
              avatarPreset: Value(_presetIndex(avatar)),
              avatarImage: Value(_imageBytes(avatar)),
              pinHash: Value(pin == null ? null : _pinHasher.hash(pin)),
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
    required ProfileAvatar avatar,
  }) async {
    _checkName(name);
    await _write(
      id,
      ProfilesCompanion(
        name: Value(name.trim()),
        avatarPreset: Value(_presetIndex(avatar)),
        avatarImage: Value(_imageBytes(avatar)),
      ),
    );
  }

  @override
  Future<void> setPin(String id, String? pin) async {
    if (pin != null) _checkPin(pin);
    await _write(
      id,
      ProfilesCompanion(
        pinHash: Value(pin == null ? null : _pinHasher.hash(pin)),
      ),
    );
  }

  @override
  Future<bool> verifyPin(String id, String pin) async {
    final row = await _findRow(id);
    if (row == null) return false;
    final stored = row.pinHash;
    return stored == null || _pinHasher.verify(pin, stored);
  }

  @override
  Future<void> delete(String id) =>
      _write(id, const ProfilesCompanion(deleted: Value(true)));

  Future<ProfileRow?> _findRow(String id) => (_db.select(
    _db.profiles,
  )..where((p) => p.id.equals(id) & p.deleted.equals(false))).getSingleOrNull();

  Future<void> _write(String id, ProfilesCompanion changes) async {
    final updated =
        await (_db.update(_db.profiles)
              ..where((p) => p.id.equals(id) & p.deleted.equals(false)))
            .write(changes.copyWith(updatedAt: Value(_now())));
    if (updated == 0) throw StateError('Profile $id does not exist');
  }

  Profile _toDomain(ProfileRow row) {
    final image = row.avatarImage;
    return Profile(
      id: row.id,
      name: row.name,
      avatar: image != null
          ? ImageAvatar(image)
          : PresetAvatar(row.avatarPreset),
      hasPin: row.pinHash != null,
      sortOrder: row.sortOrder,
    );
  }

  static int _presetIndex(ProfileAvatar avatar) => switch (avatar) {
    PresetAvatar(:final index) => index,
    ImageAvatar() => 0,
  };

  static Uint8List? _imageBytes(ProfileAvatar avatar) => switch (avatar) {
    PresetAvatar() => null,
    ImageAvatar(:final pngBytes) => pngBytes,
  };

  static void _checkName(String name) {
    final error = validateProfileName(name);
    if (error != null) throw ArgumentError.value(name, 'name', error.name);
  }

  static void _checkPin(String pin) {
    if (!isValidPin(pin)) throw ArgumentError('PIN must have four digits');
  }
}
