import 'package:tivibuddy/features/playlists/domain/catalog_access.dart';
import 'package:tivibuddy/features/series/domain/series.dart';
import 'package:tivibuddy/features/series/domain/series_repository.dart';

Series testSeries(String playlistId, int i, {String? categoryId}) => Series(
  playlistId: playlistId,
  seriesId: 3000 + i,
  name: 'Series $i',
  position: i,
  categoryId: categoryId,
  plot: 'Plot of series $i',
);

/// Two seasons with three episodes each; episode ids encode season and
/// number, for example 102 for season 1, episode 2.
SeriesDetails testSeriesDetails() => SeriesDetails(
  seasons: const [Season(number: 1), Season(number: 2)],
  episodes: [
    for (var season = 1; season <= 2; season++)
      for (var number = 1; number <= 3; number++)
        Episode(
          id: season * 100 + number,
          seasonNumber: season,
          episodeNumber: number,
          title: 'Episode $season.$number',
          duration: const Duration(minutes: 45),
          containerExtension: 'mkv',
        ),
  ],
);

/// Series source serving a fixed catalog without network access.
class FakeSeriesCatalogSource implements SeriesCatalogSource {
  FakeSeriesCatalogSource({this.categories = const [], this.series = const []});

  List<SeriesCategory> categories;
  List<Series> series;
  int loads = 0;

  @override
  Future<List<SeriesCategory>> fetchCategories(PlaylistAccess access) async =>
      categories;

  @override
  Stream<List<Series>> fetchSeries(PlaylistAccess access) async* {
    loads++;
    yield series;
  }

  @override
  Future<SeriesDetails> fetchDetails(
    PlaylistAccess access,
    Series series,
  ) async => testSeriesDetails();

  @override
  String episodeUrl(PlaylistAccess access, Episode episode) =>
      'http://episode/${episode.id}.${episode.containerExtension}';
}
