import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/device_settings_repository.dart';

class DriftDeviceSettingsRepository implements DeviceSettingsRepository {
  DriftDeviceSettingsRepository(this._db);

  final AppDatabase _db;

  static const _defaultProfileKey = 'startup.defaultProfileId';
  static const _guideDaysKey = 'guide.days';

  @override
  Stream<String?> watchDefaultProfileId() => _watch(_defaultProfileKey);

  @override
  Future<String?> getDefaultProfileId() => _get(_defaultProfileKey);

  @override
  Future<void> setDefaultProfileId(String? profileId) =>
      _set(_defaultProfileKey, profileId);

  @override
  Stream<int?> watchGuideDays() =>
      _watch(_guideDaysKey).map((value) => int.tryParse(value ?? ''));

  @override
  Future<int?> getGuideDays() async =>
      int.tryParse(await _get(_guideDaysKey) ?? '');

  @override
  Future<void> setGuideDays(int? days) => _set(_guideDaysKey, days?.toString());

  @override
  Future<String?> getValue(String key) => _get(key);

  @override
  Stream<String?> watchValue(String key) => _watch(key);

  @override
  Future<void> setValue(String key, String? value) => _set(key, value);

  @override
  Future<void> reset() => _db.delete(_db.deviceSettingEntries).go();

  Future<String?> _get(String key) async =>
      (await _query(key).getSingleOrNull())?.value;

  Stream<String?> _watch(String key) =>
      _query(key).watchSingleOrNull().map((row) => row?.value);

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(
        _db.deviceSettingEntries,
      )..where((s) => s.key.equals(key))).go();
    } else {
      await _db
          .into(_db.deviceSettingEntries)
          .insertOnConflictUpdate(
            DeviceSettingEntriesCompanion.insert(key: key, value: value),
          );
    }
  }

  SimpleSelectStatement<$DeviceSettingEntriesTable, DeviceSettingRow> _query(
    String key,
  ) => _db.select(_db.deviceSettingEntries)..where((s) => s.key.equals(key));
}
