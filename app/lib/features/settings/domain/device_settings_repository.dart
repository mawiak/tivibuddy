/// Settings that belong to this installation and are never synchronized
/// (SET-1). Extended in the settings milestone.
abstract interface class DeviceSettingsRepository {
  /// Profile that is opened automatically on start, if any (PROF-5).
  Stream<String?> watchDefaultProfileId();

  Future<String?> getDefaultProfileId();

  Future<void> setDefaultProfileId(String? profileId);

  /// Restores the defaults of all device settings.
  Future<void> reset();
}
