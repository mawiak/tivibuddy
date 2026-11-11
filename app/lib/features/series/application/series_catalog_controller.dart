import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/domain/catalog_access.dart';
import '../../playlists/domain/playlist.dart';
import '../data/series_data_providers.dart';

part 'series_catalog_controller.g.dart';

sealed class SeriesCatalogStatus {
  const SeriesCatalogStatus();
}

final class SeriesCatalogIdle extends SeriesCatalogStatus {
  const SeriesCatalogIdle();
}

final class SeriesCatalogLoading extends SeriesCatalogStatus {
  const SeriesCatalogLoading(this.seriesLoaded);
  final int seriesLoaded;
}

final class SeriesCatalogFailed extends SeriesCatalogStatus {
  const SeriesCatalogFailed(this.reason);
  final CatalogLoadFailure reason;
}

/// Loads the series catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.
@Riverpod(keepAlive: true)
class SeriesCatalogController extends _$SeriesCatalogController {
  /// Catalogs older than this are refreshed automatically when opened.
  static const maxAge = Duration(hours: 12);

  @override
  SeriesCatalogStatus build(String playlistId) => const SeriesCatalogIdle();

  bool get _isLoading => state is SeriesCatalogLoading;

  Future<void> ensureFresh() async {
    if (_isLoading) return;
    final loadedAt = await ref
        .read(seriesRepositoryProvider)
        .getLoadedAt(playlistId);
    if (loadedAt == null ||
        DateTime.now().toUtc().difference(loadedAt) > maxAge) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    state = const SeriesCatalogLoading(0);
    final repository = ref.read(seriesRepositoryProvider);
    try {
      final source = ref.read(seriesCatalogSourceProvider(PlaylistType.xtream));
      final access = await readPlaylistAccess(ref, playlistId);

      final startedAt = DateTime.now().toUtc();
      await repository.replaceCategories(
        playlistId,
        await source.fetchCategories(access),
      );
      var loaded = 0;
      await for (final batch in source.fetchSeries(access)) {
        await repository.upsertSeries(batch, loadStartedAt: startedAt);
        loaded += batch.length;
        state = SeriesCatalogLoading(loaded);
      }
      await repository.completeLoad(playlistId, loadStartedAt: startedAt);
      state = const SeriesCatalogIdle();
    } on CatalogLoadException catch (error) {
      state = SeriesCatalogFailed(error.reason);
    }
  }
}
