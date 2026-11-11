import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../playlists/data/playlist_data_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../domain/epg_repository.dart';
import '../domain/live_tv_repository.dart';
import 'drift_epg_repository.dart';
import 'drift_live_tv_repository.dart';
import 'xtream/xtream_live_source.dart';

part 'live_tv_data_providers.g.dart';

@Riverpod(keepAlive: true)
LiveTvRepository liveTvRepository(Ref ref) =>
    DriftLiveTvRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
EpgRepository epgRepository(Ref ref) =>
    DriftEpgRepository(ref.watch(appDatabaseProvider));

/// Catalog source for each playlist type (PL-3).
@Riverpod(keepAlive: true)
LiveCatalogSource liveCatalogSource(Ref ref, PlaylistType type) =>
    switch (type) {
      PlaylistType.xtream => XtreamLiveSource(
        ref.watch(xtreamApiClientProvider),
      ),
    };
