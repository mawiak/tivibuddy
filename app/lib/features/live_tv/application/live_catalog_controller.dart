import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../playlists/domain/playlist.dart';
import '../data/live_tv_data_providers.dart';
import '../domain/live_tv_repository.dart';
import 'live_tv_providers.dart';

part 'live_catalog_controller.g.dart';

sealed class LiveCatalogStatus {
  const LiveCatalogStatus();
}

final class LiveCatalogIdle extends LiveCatalogStatus {
  const LiveCatalogIdle();
}

final class LiveCatalogLoading extends LiveCatalogStatus {
  const LiveCatalogLoading(this.channelsLoaded);
  final int channelsLoaded;
}

final class LiveCatalogFailed extends LiveCatalogStatus {
  const LiveCatalogFailed(this.reason);
  final CatalogLoadFailure reason;
}

/// Loads the live catalog of a playlist from the provider into the local
/// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
/// while a refresh runs.
@Riverpod(keepAlive: true)
class LiveCatalogController extends _$LiveCatalogController {
  /// Catalogs older than this are refreshed automatically when opened.
  static const maxAge = Duration(hours: 12);

  @override
  LiveCatalogStatus build(String playlistId) => const LiveCatalogIdle();

  bool get _isLoading => state is LiveCatalogLoading;

  /// Loads the catalog when it was never loaded or is older than [maxAge].
  Future<void> ensureFresh() async {
    if (_isLoading) return;
    final loadedAt = await ref
        .read(liveTvRepositoryProvider)
        .getLoadedAt(playlistId);
    if (loadedAt == null ||
        DateTime.now().toUtc().difference(loadedAt) > maxAge) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    state = const LiveCatalogLoading(0);
    final repository = ref.read(liveTvRepositoryProvider);
    try {
      final source = ref.read(liveCatalogSourceProvider(PlaylistType.xtream));
      // Listening keeps the auto-disposed access provider alive while it
      // loads.
      final accessSubscription = ref.listen(
        playlistAccessProvider(playlistId),
        (_, _) {},
      );
      final PlaylistAccess access;
      try {
        access = await ref.read(playlistAccessProvider(playlistId).future);
      } finally {
        accessSubscription.close();
      }

      final startedAt = DateTime.now().toUtc();
      await repository.replaceCategories(
        playlistId,
        await source.fetchCategories(access),
      );

      var loaded = 0;
      await for (final batch in source.fetchChannels(access)) {
        await repository.upsertChannels(batch, loadStartedAt: startedAt);
        loaded += batch.length;
        state = LiveCatalogLoading(loaded);
      }
      await repository.completeLoad(playlistId, loadStartedAt: startedAt);
      state = const LiveCatalogIdle();
    } on CatalogLoadException catch (error) {
      state = LiveCatalogFailed(error.reason);
    }
  }
}
