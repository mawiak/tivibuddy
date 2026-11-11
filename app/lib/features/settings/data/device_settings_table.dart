import 'package:drift/drift.dart';

/// Key-value store for settings that apply to this installation only
/// (SET-1). They are never synchronized.
@DataClassName('DeviceSettingRow')
class DeviceSettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
