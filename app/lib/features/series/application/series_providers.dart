import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/paged_list.dart';
import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../../profiles/application/profile_providers.dart';
import '../../vod/application/vod_sort_providers.dart';
import '../data/series_data_providers.dart';
import '../domain/series.dart';
import '../domain/series_repository.dart';

part 'series_providers.g.dart';

/// Series the grid shows for a playlist. Starts with all series.
@riverpod
class SeriesFilterSelection extends _$SeriesFilterSelection {
  @override
  VodFilter build(String playlistId) => VodFilter.all;

  void select(VodFilter filter) => state = filter;
}

@riverpod
Stream<List<SeriesCategory>> seriesCategories(Ref ref, String playlistId) =>
    ref.watch(seriesRepositoryProvider).watchCategories(playlistId);

/// Series of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).
@riverpod
Future<PagedList<Series>> seriesList(
  Ref ref,
  String playlistId,
  VodFilter filter,
) async {
  final repository = ref.watch(seriesRepositoryProvider);
  final profileId = ref.watch(activeProfileIdProvider) ?? '';
  final sort = ref.watch(vodSortSelectionProvider(VodSection.series));
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

  final list = PagedList<Series>(
    length: await completer.future,
    pageSize: 60,
    loader: (offset, limit) => repository.getSeries(
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

/// Seasons and episodes from the provider, cached for a few minutes.
@riverpod
Future<SeriesDetails> seriesDetails(Ref ref, Series series) async {
  final link = ref.keepAlive();
  final expiry = Timer(const Duration(minutes: 10), link.close);
  ref.onDispose(expiry.cancel);

  final source = ref.read(seriesCatalogSourceProvider(PlaylistType.xtream));
  final access = ref.watch(playlistAccessProvider(series.playlistId).future);
  return source.fetchDetails(await access, series);
}

/// Favorite and last episode of a series for the active profile.
@riverpod
Stream<SeriesState> seriesState(Ref ref, Series series) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return Stream.value(SeriesState.initial);
  return ref
      .watch(seriesRepositoryProvider)
      .watchSeriesState(profileId, series.playlistId, series.seriesId);
}

/// Episode states of a series for the active profile, by episode id.
@riverpod
Stream<Map<int, EpisodeState>> episodeStates(Ref ref, Series series) {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return Stream.value(const {});
  return ref
      .watch(seriesRepositoryProvider)
      .watchEpisodeStates(profileId, series.playlistId, series.seriesId);
}

/// Playback URL of an episode.
@riverpod
Future<String> episodeStreamUrl(Ref ref, Series series, Episode episode) async {
  final source = ref.read(seriesCatalogSourceProvider(PlaylistType.xtream));
  final access = await ref.watch(
    playlistAccessProvider(series.playlistId).future,
  );
  return source.episodeUrl(access, episode);
}

/// The episode "play" starts: the last played one while it is unfinished,
/// else the one after it, else the first one.
Episode? nextEpisode(
  List<Episode> episodes,
  SeriesState state,
  Map<int, EpisodeState> states,
) {
  if (episodes.isEmpty) return null;
  final last = episodes.indexWhere((e) => e.id == state.lastEpisodeId);
  if (last < 0) return episodes.first;
  final lastState = states[episodes[last].id] ?? EpisodeState.initial;
  if (!lastState.watched) return episodes[last];
  return last + 1 < episodes.length ? episodes[last + 1] : episodes[last];
}
