import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../live_tv/data/live_tv_data_providers.dart';
import '../../live_tv/domain/live_channel.dart';
import '../../movies/data/movie_data_providers.dart';
import '../../movies/domain/movie.dart';
import '../../series/data/series_data_providers.dart';
import '../../series/domain/series.dart';

part 'search_providers.g.dart';

/// Results per kind; more need a more specific query.
const searchLimit = 50;

/// Queries shorter than this are not searched.
const searchMinLength = 2;

/// Text the user searches for (VOD-1). Kept while the section is closed,
/// so returning from a result shows the same results.
@Riverpod(keepAlive: true)
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void set(String query) => state = query.trim();
}

@riverpod
Future<List<LiveChannel>> channelSearch(
  Ref ref,
  String playlistId,
  String query,
) => ref
    .watch(liveTvRepositoryProvider)
    .search(playlistId, query, limit: searchLimit);

@riverpod
Future<List<Movie>> movieSearch(Ref ref, String playlistId, String query) => ref
    .watch(movieRepositoryProvider)
    .search(playlistId, query, limit: searchLimit);

@riverpod
Future<List<Series>> seriesSearch(Ref ref, String playlistId, String query) =>
    ref
        .watch(seriesRepositoryProvider)
        .search(playlistId, query, limit: searchLimit);
