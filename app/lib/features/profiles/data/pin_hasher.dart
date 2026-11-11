import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hashes profile PINs with a random salt, so the plain PIN is neither stored
/// locally nor sent to the sync server.
///
/// A four-digit PIN is a convenience lock against other household members,
/// not protection against an attacker with access to the database.
class PinHasher {
  PinHasher({Random? random}) : _random = random ?? Random.secure();

  static const _version = 'v1';
  static const _saltLength = 16;

  final Random _random;

  String hash(String pin) {
    final salt = List<int>.generate(_saltLength, (_) => _random.nextInt(256));
    return '$_version:${base64.encode(salt)}:${_digest(salt, pin)}';
  }

  bool verify(String pin, String stored) {
    final parts = stored.split(':');
    if (parts.length != 3 || parts[0] != _version) return false;
    final salt = base64.decode(parts[1]);
    return _digest(salt, pin) == parts[2];
  }

  String _digest(List<int> salt, String pin) =>
      base64.encode(sha256.convert([...salt, ...utf8.encode(pin)]).bytes);
}
