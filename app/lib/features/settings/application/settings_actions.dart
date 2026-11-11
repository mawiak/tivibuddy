import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../data/settings_data_providers.dart';

part 'settings_actions.g.dart';

@Riverpod(keepAlive: true)
SettingsActions settingsActions(Ref ref) => SettingsActions(ref);

/// Use cases of the settings screens (SET-1 to SET-3).
class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  String? get _profileId => _ref.read(activeProfileIdProvider);

  Future<void> setLanguage(String? languageCode) async {
    final profileId = _profileId;
    if (profileId == null) return;
    await _ref
        .read(profileSettingsRepositoryProvider)
        .setLanguage(profileId, languageCode);
  }

  Future<void> resetProfileSettings() async {
    final profileId = _profileId;
    if (profileId == null) return;
    await _ref.read(profileSettingsRepositoryProvider).reset(profileId);
  }

  Future<void> setStartProfile(String? profileId) => _ref
      .read(deviceSettingsRepositoryProvider)
      .setDefaultProfileId(profileId);

  Future<void> resetDeviceSettings() =>
      _ref.read(deviceSettingsRepositoryProvider).reset();
}
