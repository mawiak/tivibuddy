import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/settings_data_providers.dart';

part 'device_settings_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<String?> defaultProfileId(Ref ref) =>
    ref.watch(deviceSettingsRepositoryProvider).watchDefaultProfileId();
