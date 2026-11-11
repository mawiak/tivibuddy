/// A series category of a playlist as defined by the provider.
class SeriesCategory {
  const SeriesCategory({
    required this.id,
    required this.name,
    required this.seriesCount,
  });

  final String id;
  final String name;
  final int seriesCount;
}

/// A series of a playlist with the details the provider list already
/// contains. Kept free of Flutter types, so it can be sent between
/// isolates while loading large catalogs.
final class Series {
  const Series({
    required this.playlistId,
    required this.seriesId,
    required this.name,
    required this.position,
    this.coverUrl,
    this.backdropUrl,
    this.rating,
    this.categoryId,
    this.plot,
    this.genre,
    this.releaseDate,
  });

  final String playlistId;

  /// Provider id, used to load seasons and episodes.
  final int seriesId;
  final String name;

  /// Index in the provider list, the default order.
  final int position;
  final String? coverUrl;
  final String? backdropUrl;

  /// Rating on a scale of 10, when the provider knows one.
  final double? rating;
  final String? categoryId;
  final String? plot;
  final String? genre;

  /// As sent by the provider, usually `YYYY-MM-DD`.
  final String? releaseDate;

  String? get year {
    final date = releaseDate;
    return date != null && date.length >= 4 ? date.substring(0, 4) : null;
  }

  @override
  bool operator ==(Object other) =>
      other is Series &&
      other.playlistId == playlistId &&
      other.seriesId == seriesId;

  @override
  int get hashCode => Object.hash(playlistId, seriesId);
}

class Season {
  const Season({required this.number, this.name, this.coverUrl});

  final int number;
  final String? name;
  final String? coverUrl;
}

class Episode {
  const Episode({
    required this.id,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.plot,
    this.duration,
    this.imageUrl,
    this.containerExtension,
  });

  /// Provider stream id of the episode, used to build the playback URL.
  final int id;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? plot;
  final Duration? duration;
  final String? imageUrl;
  final String? containerExtension;

  @override
  bool operator ==(Object other) => other is Episode && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Seasons and episodes of a series, loaded on demand from the provider.
class SeriesDetails {
  const SeriesDetails({
    this.seasons = const [],
    this.episodes = const [],
    this.cast,
    this.director,
  });

  static const empty = SeriesDetails();

  /// Seasons in ascending order. Seasons without episodes are left out.
  final List<Season> seasons;

  /// All episodes ordered by season and episode number.
  final List<Episode> episodes;
  final String? cast;
  final String? director;

  List<Episode> episodesOf(int season) => [
    for (final episode in episodes)
      if (episode.seasonNumber == season) episode,
  ];
}

/// Progress of a profile in an episode (DATA-4). Synchronized.
class EpisodeState {
  const EpisodeState({
    this.position = Duration.zero,
    this.duration,
    this.watched = false,
  });

  static const initial = EpisodeState();

  final Duration position;
  final Duration? duration;
  final bool watched;

  double? get progress {
    final total = duration?.inSeconds ?? 0;
    if (total <= 0 || position <= Duration.zero) return null;
    return (position.inSeconds / total).clamp(0, 1);
  }

  bool get canResume => !watched && position > const Duration(minutes: 1);
}

/// What a profile did with a series as a whole (DATA-4). Synchronized.
class SeriesState {
  const SeriesState({this.favorite = false, this.lastEpisodeId});

  static const initial = SeriesState();

  final bool favorite;

  /// Episode played last, where "continue" picks up.
  final int? lastEpisodeId;
}
