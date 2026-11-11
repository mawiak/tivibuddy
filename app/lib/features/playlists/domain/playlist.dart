/// Kind of source a playlist is loaded from (PL-3). Only Xtream Codes is
/// implemented; M3U follows in a later milestone.
enum PlaylistType { xtream }

/// A provider account of a profile (PL-1). The password is not part of this
/// entity: it lives in secure storage (PL-4).
class Playlist {
  const Playlist({
    required this.id,
    required this.profileId,
    required this.type,
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.sortOrder,
    this.account,
  });

  static const maxNameLength = 40;

  final String id;
  final String profileId;
  final PlaylistType type;
  final String name;
  final String serverUrl;
  final String username;
  final int sortOrder;

  /// Account state from the last successful connection test, if any.
  final AccountInfo? account;
}

/// Account details reported by the provider.
class AccountInfo {
  const AccountInfo({
    required this.status,
    required this.checkedAt,
    this.expiresAt,
    this.maxConnections,
    this.activeConnections,
  });

  final String status;
  final DateTime checkedAt;

  /// Null means the account does not expire.
  final DateTime? expiresAt;
  final int? maxConnections;
  final int? activeConnections;

  bool get isActive => status.toLowerCase() == 'active';
}

/// Values entered in the playlist form.
class PlaylistInput {
  const PlaylistInput({
    required this.name,
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String name;
  final String serverUrl;
  final String username;
  final String password;
}

enum PlaylistInputError {
  nameEmpty,
  nameTooLong,
  serverInvalid,
  usernameEmpty,
  passwordEmpty,
}

/// Returns all problems of [input]; empty when it is valid.
Set<PlaylistInputError> validatePlaylistInput(PlaylistInput input) => {
  if (input.name.trim().isEmpty) PlaylistInputError.nameEmpty,
  if (input.name.trim().length > Playlist.maxNameLength)
    PlaylistInputError.nameTooLong,
  if (normalizeServerUrl(input.serverUrl) == null)
    PlaylistInputError.serverInvalid,
  if (input.username.trim().isEmpty) PlaylistInputError.usernameEmpty,
  if (input.password.isEmpty) PlaylistInputError.passwordEmpty,
};

/// Turns user input like `example.com:8080/` into `http://example.com:8080`.
/// Returns null when the input is not a usable http(s) server address.
String? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'http://$text';
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  final path = uri.path.endsWith('/')
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: path,
  ).toString();
}

/// Credentials contained in a full playlist link, for example
/// `http://host:8080/get.php?username=u&password=p&type=m3u_plus`. Users often
/// receive such links from their provider, so the form can split them.
({String serverUrl, String username, String password})? parseXtreamLink(
  String input,
) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null || !uri.hasScheme) return null;
  final username = uri.queryParameters['username'];
  final password = uri.queryParameters['password'];
  if (username == null || password == null) return null;
  final server = normalizeServerUrl(
    Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString(),
  );
  if (server == null) return null;
  return (serverUrl: server, username: username, password: password);
}
