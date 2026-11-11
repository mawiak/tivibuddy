import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../data/movie_data_providers.dart';
import '../domain/movie.dart';

part 'movie_actions.g.dart';

@Riverpod(keepAlive: true)
MovieActions movieActions(Ref ref) => MovieActions(ref);

/// Use cases around watching movies (DATA-4).
class MovieActions {
  MovieActions(this._ref);

  final Ref _ref;

  /// Remaining time below which a movie counts as watched, so the credits
  /// do not leave it in "continue watching".
  static const watchedBefore = Duration(minutes: 5);

  Future<MovieState> _state(Movie movie) async {
    final profileId = _ref.read(activeProfileIdProvider);
    if (profileId == null) return MovieState.initial;
    return _ref
        .read(movieRepositoryProvider)
        .getState(profileId, movie.playlistId, movie.streamId);
  }

  Future<void> _save(Movie movie, MovieState state) async {
    final profileId = _ref.read(activeProfileIdProvider);
    if (profileId == null) return;
    await _ref
        .read(movieRepositoryProvider)
        .saveState(profileId, movie.playlistId, movie.streamId, state);
  }

  Future<void> toggleFavorite(Movie movie) async {
    final state = await _state(movie);
    await _save(
      movie,
      MovieState(
        position: state.position,
        duration: state.duration,
        watched: state.watched,
        favorite: !state.favorite,
      ),
    );
  }

  /// Stores the playback position; near the end the movie becomes watched
  /// and starts from the beginning next time.
  Future<void> savePosition(
    Movie movie,
    Duration position,
    Duration? duration,
  ) async {
    final state = await _state(movie);
    final finished =
        duration != null &&
        duration > Duration.zero &&
        duration - position <= watchedBefore;
    await _save(
      movie,
      MovieState(
        position: finished ? Duration.zero : position,
        duration: duration ?? state.duration,
        watched: finished || state.watched,
        favorite: state.favorite,
      ),
    );
  }

  Future<void> setWatched(Movie movie, {required bool watched}) async {
    final state = await _state(movie);
    await _save(
      movie,
      MovieState(
        duration: state.duration,
        watched: watched,
        favorite: state.favorite,
      ),
    );
  }
}
