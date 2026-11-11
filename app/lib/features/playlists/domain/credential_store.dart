/// Stores playlist passwords outside the database, in the secure storage of
/// the platform (PL-4).
abstract interface class CredentialStore {
  Future<String?> readPassword(String playlistId);

  Future<void> writePassword(String playlistId, String password);

  Future<void> deletePassword(String playlistId);
}
