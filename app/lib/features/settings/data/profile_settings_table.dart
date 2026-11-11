import 'package:drift/drift.dart';

import '../../../core/database/sync_columns.dart';
import '../../profiles/data/profiles_table.dart';

/// Key-value settings per profile (SET-2). One row per setting, so new
/// settings need no schema migration and sync per setting (last write wins).
/// The id is `<profileId>/<key>`.
@DataClassName('ProfileSettingRow')
class ProfileSettingEntries extends Table with SyncColumns {
  TextColumn get profileId => text().references(Profiles, #id)();
  TextColumn get key => text()();
  TextColumn get value => text()();
}
