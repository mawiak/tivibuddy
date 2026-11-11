/// A movie category of a playlist as defined by the provider.
class MovieCategory {
  const MovieCategory({
    required this.id,
    required this.name,
    required this.movieCount,
  });

  final String id;
  final String name;
  final int movieCount;
}

/// A movie of a playlist. Kept small and free of Flutter types, so it can
/// be sent between isolates while loading large catalogs.
final class Movie {
  const Movie({
    required this.playlistId,
    required this.streamId,
    required this.name,
    required this.position,
    this.posterUrl,
    this.rating,
    this.addedAt,
    this.categoryId,
    this.containerExtension,
  });

  final String playlistId;

  /// Provider id, used to build the playback URL.
  final int streamId;
  final String name;

  /// Index in the provider list, the default order.
  final int position;
  final String? posterUrl;

  /// Rating on a scale of 10, when the provider knows one.
  final double? rating;
  final DateTime? addedAt;
  final String? categoryId;

  /// File extension of the stream, for example `mkv` or `mp4`.
  final String? containerExtension;

  @override
  bool operator ==(Object other) =>
      other is Movie &&
      other.playlistId == playlistId &&
      other.streamId == streamId;

  @override
  int get hashCode => Object.hash(playlistId, streamId);
}

/// Details of a movie loaded on demand from the provider.
class MovieDetails {
  const MovieDetails({
    this.plot,
    this.genre,
    this.cast,
    this.director,
    this.releaseDate,
    this.duration,
    this.backdropUrl,
    this.posterUrl,
    this.rating,
    this.containerExtension,
  });

  static const empty = MovieDetails();

  final String? plot;
  final String? genre;
  final String? cast;
  final String? director;

  /// As sent by the provider, usually `YYYY-MM-DD`.
  final String? releaseDate;
  final Duration? duration;
  final String? backdropUrl;
  final String? posterUrl;
  final double? rating;
  final String? containerExtension;

  String? get year {
    final date = releaseDate;
    return date != null && date.length >= 4 ? date.substring(0, 4) : null;
  }
}

/// What a profile did with a movie (DATA-4). Synchronized with the profile.
class MovieState {
  const MovieState({
    this.position = Duration.zero,
    this.duration,
    this.watched = false,
    this.favorite = false,
  });

  static const initial = MovieState();

  /// Resume position.
  final Duration position;
  final Duration? duration;
  final bool watched;
  final bool favorite;

  /// Progress between 0 and 1, or null without known duration.
  double? get progress {
    final total = duration?.inSeconds ?? 0;
    if (total <= 0 || position <= Duration.zero) return null;
    return (position.inSeconds / total).clamp(0, 1);
  }

  bool get canResume => !watched && position > const Duration(minutes: 1);
}
