import '../../playlists/domain/catalog_access.dart';
import 'movie.dart';

/// Lists the grid can show besides the provider categories.
enum MovieList { all, favorites, continueWatching }

/// Which movies a grid shows: a provider category or one of [MovieList].
class MovieFilter {
  const MovieFilter.list(MovieList this.list) : categoryId = null;

  const MovieFilter.category(String this.categoryId) : list = null;

  static const all = MovieFilter.list(MovieList.all);

  final MovieList? list;
  final String? categoryId;

  @override
  bool operator ==(Object other) =>
      other is MovieFilter &&
      other.list == list &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(list, categoryId);
}

/// Local copy of the movie catalog of playlists plus the movie states of
/// profiles (DATA-3, DATA-4). The UI only reads from here.
abstract interface class MovieRepository {
  Stream<List<MovieCategory>> watchCategories(String playlistId);

  /// Number of movies matching [filter]. Favorites and continue watching
  /// belong to [profileId].
  Stream<int> watchCount(
    String playlistId,
    MovieFilter filter, {
    required String profileId,
  });

  /// A page of movies matching [filter] in display order.
  Future<List<Movie>> getMovies(
    String playlistId,
    MovieFilter filter, {
    required String profileId,
    required int offset,
    required int limit,
  });

  Future<Movie?> getMovie(String playlistId, int streamId);

  Future<DateTime?> getLoadedAt(String playlistId);

  Future<void> replaceCategories(
    String playlistId,
    List<MovieCategory> categories,
  );

  Future<void> upsertMovies(
    List<Movie> movies, {
    required DateTime loadStartedAt,
  });

  Future<void> completeLoad(
    String playlistId, {
    required DateTime loadStartedAt,
  });

  /// Deletes the catalog and marks the movie states of the playlist deleted.
  Future<void> deleteForPlaylist(String playlistId);

  Stream<MovieState> watchState(
    String profileId,
    String playlistId,
    int streamId,
  );

  Future<MovieState> getState(
    String profileId,
    String playlistId,
    int streamId,
  );

  Future<void> saveState(
    String profileId,
    String playlistId,
    int streamId,
    MovieState state,
  );

  /// Marks all movie states of a profile deleted.
  Future<void> deleteStatesForProfile(String profileId);
}

/// Loads the movie catalog and details from a provider (PL-3).
abstract interface class MovieCatalogSource {
  Future<List<MovieCategory>> fetchCategories(PlaylistAccess access);

  /// Movies in batches, parsed off the UI isolate (DATA-1).
  Stream<List<Movie>> fetchMovies(PlaylistAccess access);

  Future<MovieDetails> fetchDetails(PlaylistAccess access, Movie movie);

  String streamUrl(
    PlaylistAccess access,
    Movie movie, {
    String? containerExtension,
  });
}
