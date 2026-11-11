import 'package:tivibuddy/features/movies/domain/movie.dart';
import 'package:tivibuddy/features/movies/domain/movie_repository.dart';
import 'package:tivibuddy/features/playlists/domain/catalog_access.dart';

Movie testMovie(String playlistId, int i, {String? categoryId}) => Movie(
  playlistId: playlistId,
  streamId: 2000 + i,
  name: 'Movie $i',
  position: i,
  categoryId: categoryId,
  containerExtension: 'mkv',
);

/// Movie source serving a fixed catalog without network access.
class FakeMovieCatalogSource implements MovieCatalogSource {
  FakeMovieCatalogSource({
    this.categories = const [],
    this.movies = const [],
    this.failure,
  });

  List<MovieCategory> categories;
  List<Movie> movies;
  CatalogLoadFailure? failure;
  int loads = 0;

  @override
  Future<List<MovieCategory>> fetchCategories(PlaylistAccess access) async {
    if (failure case final failure?) throw CatalogLoadException(failure);
    return categories;
  }

  @override
  Stream<List<Movie>> fetchMovies(PlaylistAccess access) async* {
    loads++;
    for (var i = 0; i < movies.length; i += 50) {
      yield movies.sublist(i, (i + 50).clamp(0, movies.length));
    }
  }

  @override
  Future<MovieDetails> fetchDetails(PlaylistAccess access, Movie movie) async =>
      MovieDetails(
        plot: 'Plot of ${movie.name}',
        genre: 'Drama',
        releaseDate: '2024-05-01',
        duration: const Duration(minutes: 100),
        containerExtension: 'mp4',
      );

  @override
  String streamUrl(
    PlaylistAccess access,
    Movie movie, {
    String? containerExtension,
  }) =>
      'http://movie/${movie.streamId}.'
      '${containerExtension ?? movie.containerExtension}';
}
