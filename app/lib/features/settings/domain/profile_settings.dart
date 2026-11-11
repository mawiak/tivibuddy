/// Settings that belong to a profile and are synchronized with it (SET-2).
/// Extended as features are added.
class ProfileSettings {
  const ProfileSettings({this.languageCode});

  static const defaults = ProfileSettings();

  /// App language as locale tag, or null to follow the device language.
  final String? languageCode;
}
