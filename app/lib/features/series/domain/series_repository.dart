import '../../playlists/domain/catalog_access.dart';
import '../../vod/domain/vod_filter.dart';
import 'series.dart';

export '../../vod/domain/vod_filter.dart';

/// Local copy of the series catalog of playlists plus the series and
/// episode states of profiles (DATA-3, DATA-4). The UI only reads from here.
abstract interface class SeriesRepository {
  Stream<List<SeriesCategory>> watchCategories(String playlistId);

  /// Number of series matching [filter]. Favorites and continue watching
  /// belong to [profileId].
  Stream<int> watchCount(
    String playlistId,
    VodFilter filter, {
    required String profileId,
  });

  /// A page of series matching [filter] in display order.
  Future<List<Series>> getSeries(
    String playlistId,
    VodFilter filter, {
    required String profileId,
    required int offset,
    required int limit,
  });

  /// Series whose name contains [query], in provider order (VOD-1).
  Future<List<Series>> search(
    String playlistId,
    String query, {
    required int limit,
  });

  Future<DateTime?> getLoadedAt(String playlistId);

  Future<void> replaceCategories(
    String playlistId,
    List<SeriesCategory> categories,
  );

  Future<void> upsertSeries(
    List<Series> series, {
    required DateTime loadStartedAt,
  });

  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  });

  /// Deletes the catalog and marks the states of the playlist deleted.
  Future<void> deleteForPlaylist(String playlistId);

  Stream<SeriesState> watchSeriesState(
    String profileId,
    String playlistId,
    int seriesId,
  );

  Future<SeriesState> getSeriesState(
    String profileId,
    String playlistId,
    int seriesId,
  );

  Future<void> setFavorite(
    String profileId,
    String playlistId,
    int seriesId, {
    required bool favorite,
  });

  /// States of the episodes of a series by episode id.
  Stream<Map<int, EpisodeState>> watchEpisodeStates(
    String profileId,
    String playlistId,
    int seriesId,
  );

  /// Saves the state of an episode and makes it the last played one of its
  /// series.
  Future<void> saveEpisodeState(
    String profileId,
    String playlistId,
    int seriesId,
    int episodeId,
    EpisodeState state,
  );

  /// Marks all series and episode states of a profile deleted.
  Future<void> deleteStatesForProfile(String profileId);
}

/// Loads the series catalog, seasons and episodes from a provider (PL-3).
abstract interface class SeriesCatalogSource {
  Future<List<SeriesCategory>> fetchCategories(PlaylistAccess access);

  /// Series in batches, parsed off the UI isolate (DATA-1).
  Stream<List<Series>> fetchSeries(PlaylistAccess access);

  Future<SeriesDetails> fetchDetails(PlaylistAccess access, Series series);

  String episodeUrl(PlaylistAccess access, Episode episode);
}
