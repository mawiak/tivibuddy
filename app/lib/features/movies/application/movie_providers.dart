import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/paged_list.dart';
import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../../profiles/application/profile_providers.dart';
import '../../vod/application/vod_sort_providers.dart';
import '../data/movie_data_providers.dart';
import '../domain/movie.dart';
import '../domain/movie_repository.dart';

part 'movie_providers.g.dart';

/// Movies the grid shows for a playlist. Starts with all movies.
@riverpod
class MovieFilterSelection extends _$MovieFilterSelection {
  @override
  VodFilter build(String playlistId) => VodFilter.all;

  void select(VodFilter filter) => state = filter;
}

@riverpod
Stream<List<MovieCategory>> movieCategories(Ref ref, String playlistId) =>
    ref.watch(movieRepositoryProvider).watchCategories(playlistId);

/// Movies of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).
@riverpod
Future<PagedList<Movie>> movieList(
  Ref ref,
  String playlistId,
  VodFilter filter,
) async {
  final repository = ref.watch(movieRepositoryProvider);
  final profileId = ref.watch(activeProfileIdProvider) ?? '';
  final sort = ref.watch(vodSortSelectionProvider(VodSection.movies));
  final counts = repository.watchCount(
    playlistId,
    filter,
    profileId: profileId,
  );
  final completer = Completer<int>();
  Timer? rebuild;
  final subscription = counts.listen((count) {
    if (!completer.isCompleted) {
      completer.complete(count);
      return;
    }
    rebuild?.cancel();
    rebuild = Timer(const Duration(milliseconds: 1500), ref.invalidateSelf);
  });
  ref.onDispose(() {
    rebuild?.cancel();
    subscription.cancel();
  });

  final list = PagedList<Movie>(
    length: await completer.future,
    // Poster grids show more items per screen than channel lists.
    pageSize: 60,
    loader: (offset, limit) => repository.getMovies(
      playlistId,
      filter,
      profileId: profileId,
      sort: sort,
      offset: offset,
      limit: limit,
    ),
  );
  ref.onDispose(list.dispose);
  return list;
}

/// Details from the provider, cached for a few minutes.
@riverpod
Future<MovieDetails> movieDetails(Ref ref, Movie movie) async {
  final link = ref.keepAlive();
  final expiry = Timer(const Duration(minutes: 10), link.close);
  ref.onDispose(expiry.cancel);

  final source = ref.read(movieCatalogSourceProvider(PlaylistType.xtream));
  final access = ref.watch(playlistAccessProvider(movie.playlistId).future);
  try {
    return await source.fetchDetails(await access, movie);
  } on Exception {
    // Details are optional; the movie still plays.
    return MovieDetails.empty;
  }
}

/// What the active profile did with a movie.
@riverpod
Stream<MovieState> movieState(Ref ref, Movie movie) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return Stream.value(MovieState.initial);
  return ref
      .watch(movieRepositoryProvider)
      .watchState(profileId, movie.playlistId, movie.streamId);
}

/// Playback URL of a movie.
@riverpod
Future<String> movieStreamUrl(Ref ref, Movie movie) async {
  final source = ref.read(movieCatalogSourceProvider(PlaylistType.xtream));
  final details = ref.watch(movieDetailsProvider(movie).future);
  final access = await ref.watch(
    playlistAccessProvider(movie.playlistId).future,
  );
  return source.streamUrl(
    access,
    movie,
    containerExtension: (await details).containerExtension,
  );
}
