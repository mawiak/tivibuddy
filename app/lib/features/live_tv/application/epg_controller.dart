import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../playlists/domain/playlist.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/data/settings_data_providers.dart';
import '../data/live_tv_data_providers.dart';
import '../domain/live_tv_repository.dart';
import 'live_tv_providers.dart';

part 'epg_controller.g.dart';

sealed class GuideStatus {
  const GuideStatus();
}

final class GuideIdle extends GuideStatus {
  const GuideIdle();
}

final class GuideLoading extends GuideStatus {
  const GuideLoading(this.programmesLoaded);
  final int programmesLoaded;
}

final class GuideFailed extends GuideStatus {
  const GuideFailed(this.reason);
  final CatalogLoadFailure reason;
}

/// Loads the programme guide of a playlist into the local database
/// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
/// from shortly before now up to the configured number of days ahead.
@Riverpod(keepAlive: true)
class EpgController extends _$EpgController {
  /// Guides older than this are refreshed automatically.
  static const maxAge = Duration(hours: 12);

  /// Programmes that ended earlier than this before the load are dropped.
  static const keepPast = Duration(hours: 3);

  @override
  GuideStatus build(String playlistId) => const GuideIdle();

  bool get _isLoading => state is GuideLoading;

  /// Loads the guide when it was never loaded or is older than [maxAge].
  Future<void> ensureFresh() async {
    if (_isLoading) return;
    final loadedAt = await ref
        .read(epgRepositoryProvider)
        .getLoadedAt(playlistId);
    if (loadedAt == null ||
        DateTime.now().toUtc().difference(loadedAt) > maxAge) {
      await refresh();
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    state = const GuideLoading(0);
    final epg = ref.read(epgRepositoryProvider);
    final liveTv = ref.read(liveTvRepositoryProvider);
    try {
      final days =
          await ref.read(deviceSettingsRepositoryProvider).getGuideDays() ??
          defaultGuideDays;
      if (days == 0) {
        state = const GuideIdle();
        return;
      }
      final source = ref.read(liveCatalogSourceProvider(PlaylistType.xtream));
      final access = await readPlaylistAccess(ref, playlistId);
      final channelKeys = await liveTv.getEpgChannelIds(playlistId);

      final startedAt = DateTime.now().toUtc();
      var loaded = 0;
      await for (final batch in source.fetchProgrammes(
        access,
        channelKeys: channelKeys,
        from: startedAt.subtract(keepPast),
        to: startedAt.add(Duration(days: days)),
      )) {
        await epg.upsertProgrammes(playlistId, batch, loadStartedAt: startedAt);
        loaded += batch.length;
        state = GuideLoading(loaded);
      }
      await epg.completeLoad(playlistId, loadStartedAt: startedAt);
      state = const GuideIdle();
    } on CatalogLoadException catch (error) {
      state = GuideFailed(error.reason);
    }
  }
}
