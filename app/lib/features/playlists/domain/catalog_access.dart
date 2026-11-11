// Types shared by every catalog that is loaded from a playlist provider
// (live channels, movies, series).

/// Access data of a playlist, including the password from secure storage.
class PlaylistAccess {
  const PlaylistAccess({
    required this.playlistId,
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  final String playlistId;
  final String serverUrl;
  final String username;
  final String password;
}

/// Loading the catalog failed.
class CatalogLoadException implements Exception {
  const CatalogLoadException(this.reason, [this.detail]);

  final CatalogLoadFailure reason;
  final String? detail;

  @override
  String toString() => 'CatalogLoadException($reason, $detail)';
}

enum CatalogLoadFailure {
  unauthorized,
  unreachable,
  invalidResponse,
  missingPassword,
}
