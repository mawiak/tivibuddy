import 'package:tivibuddy/features/playlists/domain/credential_store.dart';

/// In-memory replacement for the platform secure storage, which is not
/// available in tests.
class FakeCredentialStore implements CredentialStore {
  final passwords = <String, String>{};

  @override
  Future<String?> readPassword(String playlistId) async =>
      passwords[playlistId];

  @override
  Future<void> writePassword(String playlistId, String password) async =>
      passwords[playlistId] = password;

  @override
  Future<void> deletePassword(String playlistId) async =>
      passwords.remove(playlistId);
}
