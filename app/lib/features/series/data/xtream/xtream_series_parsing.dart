import '../../../playlists/data/xtream/xtream_values.dart';
import '../../domain/series.dart';

// Parsing of Xtream series responses.

SeriesCategory? parseSeriesCategory(Map<String, Object?> json) {
  final id = xtreamText(json['category_id']);
  final name = xtreamText(json['category_name']);
  if (id == null || name == null) return null;
  return SeriesCategory(id: id, name: name, seriesCount: 0);
}

String? _firstText(Object? value) => switch (value) {
  final List<Object?> list when list.isNotEmpty => xtreamText(list.first),
  _ => xtreamText(value),
};

double? _rating(Object? value) {
  final rating = xtreamDouble(value);
  return rating == null || rating <= 0 ? null : rating;
}

/// Returns null for entries without a usable series id.
Series? parseSeries(
  Map<String, Object?> json, {
  required String playlistId,
  required int position,
}) {
  final seriesId = xtreamInt(json['series_id']);
  if (seriesId == null) return null;
  return Series(
    playlistId: playlistId,
    seriesId: seriesId,
    name: xtreamText(json['name']) ?? '#$seriesId',
    position: position,
    coverUrl: xtreamText(json['cover']),
    backdropUrl: _firstText(json['backdrop_path']),
    rating: _rating(json['rating']),
    categoryId: xtreamCategoryId(json),
    plot: xtreamText(json['plot']),
    genre: xtreamText(json['genre']),
    releaseDate:
        xtreamText(json['releaseDate']) ?? xtreamText(json['release_date']),
  );
}

Episode? _parseEpisode(Object? json, int fallbackSeason) {
  if (json is! Map<String, Object?>) return null;
  final id = xtreamInt(json['id']);
  if (id == null) return null;
  final info = json['info'];
  final details = info is Map<String, Object?>
      ? info
      : const <String, Object?>{};
  final seconds = xtreamInt(details['duration_secs']);
  final number = xtreamInt(json['episode_num']) ?? 0;
  return Episode(
    id: id,
    seasonNumber: xtreamInt(json['season']) ?? fallbackSeason,
    episodeNumber: number,
    title: xtreamText(json['title']) ?? '#$number',
    plot: xtreamText(details['plot']),
    duration: seconds == null || seconds <= 0
        ? null
        : Duration(seconds: seconds),
    imageUrl: xtreamText(details['movie_image']),
    containerExtension: xtreamText(json['container_extension']),
  );
}

/// Parses the `get_series_info` response. Panels send the episodes as a map
/// from season number to a list, or as one list.
SeriesDetails parseSeriesDetails(Object? body) {
  if (body is! Map<String, Object?>) return SeriesDetails.empty;

  final episodes = <Episode>[];
  switch (body['episodes']) {
    case final Map<String, Object?> bySeason:
      for (final MapEntry(:key, :value) in bySeason.entries) {
        if (value is! List) continue;
        final season = int.tryParse(key) ?? 0;
        for (final item in value) {
          episodes.addAll([?_parseEpisode(item, season)]);
        }
      }
    case final List<Object?> list:
      for (final item in list) {
        episodes.addAll([?_parseEpisode(item, 0)]);
      }
  }
  episodes.sort(
    (a, b) => a.seasonNumber != b.seasonNumber
        ? a.seasonNumber.compareTo(b.seasonNumber)
        : a.episodeNumber.compareTo(b.episodeNumber),
  );

  final seasonInfo = <int, Map<String, Object?>>{};
  final seasons = body['seasons'];
  if (seasons is List) {
    for (final item in seasons) {
      if (item is! Map<String, Object?>) continue;
      final number = xtreamInt(item['season_number']);
      if (number != null) seasonInfo[number] = item;
    }
  }
  final numbers = {for (final e in episodes) e.seasonNumber}.toList()..sort();

  final info = body['info'];
  final details = info is Map<String, Object?>
      ? info
      : const <String, Object?>{};
  return SeriesDetails(
    seasons: [
      for (final number in numbers)
        Season(
          number: number,
          name: xtreamText(seasonInfo[number]?['name']),
          coverUrl: xtreamText(seasonInfo[number]?['cover']),
        ),
    ],
    episodes: episodes,
    cast: xtreamText(details['cast']),
    director: xtreamText(details['director']),
  );
}
