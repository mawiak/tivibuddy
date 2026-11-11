import 'package:drift/drift.dart';

import '../../../core/database/sync_columns.dart';

@DataClassName('ProfileRow')
class Profiles extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Index into the bundled avatar set. Used when [avatarImage] is null.
  IntColumn get avatarPreset => integer().withDefault(const Constant(0))();

  /// Custom avatar as a small PNG, stored in the database so it works on the
  /// web and can be synchronized like any other value.
  BlobColumn get avatarImage => blob().nullable()();

  /// Salted hash of the optional profile PIN.
  TextColumn get pinHash => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
