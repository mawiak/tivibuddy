import 'playlist.dart';

sealed class ConnectionResult {
  const ConnectionResult();
}

final class ConnectionOk extends ConnectionResult {
  const ConnectionOk(this.account);
  final AccountInfo account;
}

/// The server answered but rejected the username or password.
final class ConnectionUnauthorized extends ConnectionResult {
  const ConnectionUnauthorized();
}

/// The server could not be reached or did not answer like an Xtream server.
final class ConnectionFailed extends ConnectionResult {
  const ConnectionFailed(this.reason);
  final ConnectionFailure reason;
}

enum ConnectionFailure { unreachable, timeout, invalidResponse }

/// Checks credentials against a provider (PL-2). One implementation per
/// [PlaylistType].
abstract interface class ConnectionTester {
  Future<ConnectionResult> test({
    required String serverUrl,
    required String username,
    required String password,
  });
}
