import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../domain/device_settings_repository.dart';
import 'drift_device_settings_repository.dart';

part 'settings_data_providers.g.dart';

@Riverpod(keepAlive: true)
DeviceSettingsRepository deviceSettingsRepository(Ref ref) =>
    DriftDeviceSettingsRepository(ref.watch(appDatabaseProvider));
