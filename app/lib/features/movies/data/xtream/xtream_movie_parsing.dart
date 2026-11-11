import '../../../playlists/data/xtream/xtream_values.dart';
import '../../domain/movie.dart';

// Parsing of Xtream VOD responses.

MovieCategory? parseMovieCategory(Map<String, Object?> json) {
  final id = xtreamText(json['category_id']);
  final name = xtreamText(json['category_name']);
  if (id == null || name == null) return null;
  return MovieCategory(id: id, name: name, movieCount: 0);
}

/// Returns null for entries without a usable stream id.
Movie? parseMovie(
  Map<String, Object?> json, {
  required String playlistId,
  required int position,
}) {
  final streamId = xtreamInt(json['stream_id']);
  if (streamId == null) return null;
  final rating = xtreamDouble(json['rating']);
  return Movie(
    playlistId: playlistId,
    streamId: streamId,
    name: xtreamText(json['name']) ?? '#$streamId',
    position: position,
    posterUrl: xtreamText(json['stream_icon']),
    rating: rating == null || rating <= 0 ? null : rating,
    addedAt: xtreamTime(json['added']),
    categoryId: xtreamCategoryId(json),
    containerExtension: xtreamText(json['container_extension']),
  );
}

/// Parses the `get_vod_info` response.
MovieDetails parseMovieDetails(Object? body) {
  if (body is! Map<String, Object?>) return MovieDetails.empty;
  final info = body['info'];
  final data = body['movie_data'];
  if (info is! Map<String, Object?>) return MovieDetails.empty;

  final backdrop = info['backdrop_path'];
  final seconds = xtreamInt(info['duration_secs']);
  final rating = xtreamDouble(info['rating']);
  return MovieDetails(
    plot: xtreamText(info['plot']) ?? xtreamText(info['description']),
    genre: xtreamText(info['genre']),
    cast: xtreamText(info['cast']) ?? xtreamText(info['actors']),
    director: xtreamText(info['director']),
    releaseDate:
        xtreamText(info['releasedate']) ?? xtreamText(info['release_date']),
    duration: seconds == null || seconds <= 0
        ? null
        : Duration(seconds: seconds),
    backdropUrl: switch (backdrop) {
      final List<Object?> list when list.isNotEmpty => xtreamText(list.first),
      _ => xtreamText(backdrop),
    },
    posterUrl: xtreamText(info['movie_image']) ?? xtreamText(info['cover_big']),
    rating: rating == null || rating <= 0 ? null : rating,
    containerExtension: data is Map<String, Object?>
        ? xtreamText(data['container_extension'])
        : null,
  );
}
