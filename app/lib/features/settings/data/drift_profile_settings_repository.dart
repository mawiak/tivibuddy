import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/profile_settings.dart';
import '../domain/profile_settings_repository.dart';

class DriftProfileSettingsRepository implements ProfileSettingsRepository {
  DriftProfileSettingsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const _language = 'language';

  SimpleSelectStatement<$ProfileSettingEntriesTable, ProfileSettingRow> _query(
    String profileId,
  ) =>
      _db.select(_db.profileSettingEntries)
        ..where((s) => s.profileId.equals(profileId) & s.deleted.equals(false));

  @override
  Stream<ProfileSettings> watch(String profileId) =>
      _query(profileId).watch().map(_toDomain);

  @override
  Future<ProfileSettings> get(String profileId) async =>
      _toDomain(await _query(profileId).get());

  @override
  Future<void> setLanguage(String profileId, String? languageCode) =>
      _set(profileId, _language, languageCode);

  @override
  Future<void> reset(String profileId) async {
    await (_db.update(
      _db.profileSettingEntries,
    )..where((s) => s.profileId.equals(profileId))).write(
      ProfileSettingEntriesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  /// Writes a value, or marks the setting deleted when [value] is null so
  /// the removal is synchronized as well.
  Future<void> _set(String profileId, String key, String? value) async {
    final now = _clock().toUtc();
    await _db
        .into(_db.profileSettingEntries)
        .insert(
          ProfileSettingEntriesCompanion.insert(
            id: '$profileId/$key',
            createdAt: now,
            updatedAt: now,
            profileId: profileId,
            key: key,
            value: value ?? '',
            deleted: Value(value == null),
          ),
          onConflict: DoUpdate(
            (_) => ProfileSettingEntriesCompanion(
              value: Value(value ?? ''),
              deleted: Value(value == null),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  static ProfileSettings _toDomain(List<ProfileSettingRow> rows) {
    final values = {for (final row in rows) row.key: row.value};
    return ProfileSettings(languageCode: values[_language]);
  }
}
