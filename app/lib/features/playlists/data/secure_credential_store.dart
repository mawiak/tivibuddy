import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/credential_store.dart';

/// Keystore (Android), Keychain (iOS, macOS), libsecret (Linux), DPAPI
/// (Windows) and WebCrypto (web) through flutter_secure_storage.
class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _key(String playlistId) => 'playlist.$playlistId.password';

  @override
  Future<String?> readPassword(String playlistId) =>
      _storage.read(key: _key(playlistId));

  @override
  Future<void> writePassword(String playlistId, String password) =>
      _storage.write(key: _key(playlistId), value: password);

  @override
  Future<void> deletePassword(String playlistId) =>
      _storage.delete(key: _key(playlistId));
}
