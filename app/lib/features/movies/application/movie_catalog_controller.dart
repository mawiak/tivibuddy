import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/domain/catalog_access.dart';
import '../../playlists/domain/playlist.dart';
import '../data/movie_data_providers.dart';

part 'movie_catalog_controller.g.dart';

sealed class MovieCatalogStatus {
  const MovieCatalogStatus();
}

final class MovieCatalogIdle extends MovieCatalogStatus {
  const MovieCatalogIdle();
}

final class MovieCatalogLoading extends MovieCatalogStatus {
  const MovieCatalogLoading(this.moviesLoaded);
  final int moviesLoaded;
}

final class MovieCatalogFailed extends MovieCatalogStatus {
  const MovieCatalogFailed(this.reason);
  final CatalogLoadFailure reason;
}

/// Loads the movie catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.
@Riverpod(keepAlive: true)
class MovieCatalogController extends _$MovieCatalogController {
  /// Catalogs older than this are refreshed automatically when opened.
  static const maxAge = Duration(hours: 12);

  @override
  MovieCatalogStatus build(String playlistId) => const MovieCatalogIdle();

  bool get _isLoading => state is MovieCatalogLoading;

  Future<void> ensureFresh() async {
    if (_isLoading) return;
    final loadedAt = await ref
        .read(movieRepositoryProvider)
        .getLoadedAt(playlistId);
    if (loadedAt == null ||
        DateTime.now().toUtc().difference(loadedAt) > maxAge) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    state = const MovieCatalogLoading(0);
    final repository = ref.read(movieRepositoryProvider);
    try {
      final source = ref.read(movieCatalogSourceProvider(PlaylistType.xtream));
      final access = await readPlaylistAccess(ref, playlistId);

      final startedAt = DateTime.now().toUtc();
      await repository.replaceCategories(
        playlistId,
        await source.fetchCategories(access),
      );
      var loaded = 0;
      await for (final batch in source.fetchMovies(access)) {
        await repository.upsertMovies(batch, loadStartedAt: startedAt);
        loaded += batch.length;
        state = MovieCatalogLoading(loaded);
      }
      await repository.completeLoad(playlistId, loadStartedAt: startedAt);
      state = const MovieCatalogIdle();
    } on CatalogLoadException catch (error) {
      state = MovieCatalogFailed(error.reason);
    }
  }
}
