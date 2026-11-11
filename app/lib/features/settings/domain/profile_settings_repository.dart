import 'profile_settings.dart';

abstract interface class ProfileSettingsRepository {
  Stream<ProfileSettings> watch(String profileId);

  Future<ProfileSettings> get(String profileId);

  /// Sets the language, or follows the device language when [languageCode]
  /// is null.
  Future<void> setLanguage(String profileId, String? languageCode);

  /// Restores the defaults for [profileId].
  Future<void> reset(String profileId);
}
