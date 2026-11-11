import 'live_channel.dart';

/// Local copy of the live catalog of playlists (DATA-3). The UI only reads
/// from here; [LiveCatalogSource] fills it.
abstract interface class LiveTvRepository {
  /// Categories in provider order, with the number of channels each.
  Stream<List<LiveCategory>> watchCategories(String playlistId);

  /// Number of channels in [categoryId], or in the whole playlist when null.
  Stream<int> watchChannelCount(String playlistId, {String? categoryId});

  /// A page of channels in display order.
  Future<List<LiveChannel>> getChannels(
    String playlistId, {
    String? categoryId,
    required int offset,
    required int limit,
  });

  /// Guide ids of all channels of [playlistId], used to keep only the
  /// programmes of known channels when the guide is loaded.
  Future<Set<String>> getEpgChannelIds(String playlistId);

  /// When the catalog of [playlistId] was last loaded completely.
  Stream<DateTime?> watchLoadedAt(String playlistId);

  Future<DateTime?> getLoadedAt(String playlistId);

  Future<void> replaceCategories(
    String playlistId,
    List<LiveCategory> categories,
  );

  /// Inserts or updates channels and marks them as seen in the load that
  /// started at [loadStartedAt].
  Future<void> upsertChannels(
    List<LiveChannel> channels, {
    required DateTime loadStartedAt,
  });

  /// Removes channels that were not part of the load started at
  /// [loadStartedAt] and records the completion time.
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  });

  Future<void> deleteForPlaylist(String playlistId);
}

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

/// Loads the live catalog and programme data from a provider (PL-3).
abstract interface class LiveCatalogSource {
  Future<List<LiveCategory>> fetchCategories(PlaylistAccess access);

  /// Channels in batches, parsed off the UI isolate (DATA-1).
  Stream<List<LiveChannel>> fetchChannels(PlaylistAccess access);

  Future<NowNext> fetchNowNext(PlaylistAccess access, LiveChannel channel);

  /// Programmes of the full guide in batches, parsed off the UI isolate
  /// (DATA-1). Only programmes of [channelKeys] that overlap the range from
  /// [from] to [to] are delivered.
  Stream<List<EpgProgramme>> fetchProgrammes(
    PlaylistAccess access, {
    required Set<String> channelKeys,
    required DateTime from,
    required DateTime to,
  });

  String streamUrl(PlaylistAccess access, LiveChannel channel);
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
