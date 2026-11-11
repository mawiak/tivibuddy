import 'live_channel.dart';

/// Local copy of the programme guide of playlists (LIVE-2, DATA-3). Filled
/// from the provider guide, read by the guide screen and the
/// now/next display.
abstract interface class EpgRepository {
  /// Programmes of [channelKey] that overlap the range from [from] to [to],
  /// ordered by start.
  Future<List<EpgEntry>> getProgrammes(
    String playlistId,
    String channelKey, {
    required DateTime from,
    required DateTime to,
  });

  /// When the guide of [playlistId] was last loaded completely.
  Stream<DateTime?> watchLoadedAt(String playlistId);

  Future<DateTime?> getLoadedAt(String playlistId);

  /// Inserts or updates programmes and marks them as seen in the load that
  /// started at [loadStartedAt].
  Future<void> upsertProgrammes(
    String playlistId,
    List<EpgProgramme> programmes, {
    required DateTime loadStartedAt,
  });

  /// Removes programmes that were not part of the load started at
  /// [loadStartedAt] and records the completion time.
  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  });

  Future<void> deleteForPlaylist(String playlistId);

  /// Makes every guide count as outdated, so it is loaded again when next
  /// opened.
  Future<void> markAllOutdated();

  Future<void> deleteAll();
}
