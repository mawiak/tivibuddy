import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../data/settings_data_providers.dart';
import '../domain/profile_settings.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<String?> defaultProfileId(Ref ref) =>
    ref.watch(deviceSettingsRepositoryProvider).watchDefaultProfileId();

/// Settings of the active profile, or the defaults without one.
@riverpod
Stream<ProfileSettings> activeProfileSettings(Ref ref) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return Stream.value(ProfileSettings.defaults);
  return ref.watch(profileSettingsRepositoryProvider).watch(profileId);
}

/// Language tag the app is shown in, or null for the device language.
@riverpod
String? appLanguage(Ref ref) =>
    ref.watch(activeProfileSettingsProvider).value?.languageCode;
