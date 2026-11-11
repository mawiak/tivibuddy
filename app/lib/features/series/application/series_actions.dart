import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../data/series_data_providers.dart';
import '../domain/series.dart';

part 'series_actions.g.dart';

@Riverpod(keepAlive: true)
SeriesActions seriesActions(Ref ref) => SeriesActions(ref);

/// Use cases around watching series (DATA-4).
class SeriesActions {
  SeriesActions(this._ref);

  final Ref _ref;

  /// Remaining time below which an episode counts as watched, so the end
  /// credits do not keep it unfinished.
  static const watchedBefore = Duration(minutes: 2);

  String? get _profileId => _ref.read(activeProfileIdProvider);

  Future<void> toggleFavorite(Series series) async {
    final profileId = _profileId;
    if (profileId == null) return;
    final repository = _ref.read(seriesRepositoryProvider);
    final state = await repository.getSeriesState(
      profileId,
      series.playlistId,
      series.seriesId,
    );
    await repository.setFavorite(
      profileId,
      series.playlistId,
      series.seriesId,
      favorite: !state.favorite,
    );
  }

  /// Stores the playback position of an episode; near the end it becomes
  /// watched and starts from the beginning next time.
  Future<void> saveEpisodeProgress(
    Series series,
    Episode episode,
    Duration position,
    Duration? duration,
  ) async {
    final finished =
        duration != null &&
        duration > Duration.zero &&
        duration - position <= watchedBefore;
    await _save(
      series,
      episode,
      EpisodeState(
        position: finished ? Duration.zero : position,
        duration: duration ?? episode.duration,
        watched: finished,
      ),
    );
  }

  Future<void> setEpisodeWatched(
    Series series,
    Episode episode, {
    required bool watched,
  }) => _save(
    series,
    episode,
    EpisodeState(duration: episode.duration, watched: watched),
  );

  Future<void> _save(Series series, Episode episode, EpisodeState state) async {
    final profileId = _profileId;
    if (profileId == null) return;
    await _ref
        .read(seriesRepositoryProvider)
        .saveEpisodeState(
          profileId,
          series.playlistId,
          series.seriesId,
          episode.id,
          state,
        );
  }
}
