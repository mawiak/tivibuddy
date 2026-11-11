import 'package:drift/drift.dart';

/// Columns every synchronizable table carries (see SYNC-7 in ai/requirements.md).
///
/// Rows are never removed directly. They are marked [deleted] so the deletion
/// can be propagated to other devices.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
