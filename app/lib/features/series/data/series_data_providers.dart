import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../playlists/data/playlist_data_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../domain/series_repository.dart';
import 'drift_series_repository.dart';
import 'xtream/xtream_series_source.dart';

part 'series_data_providers.g.dart';

@Riverpod(keepAlive: true)
SeriesRepository seriesRepository(Ref ref) =>
    DriftSeriesRepository(ref.watch(appDatabaseProvider));

/// Series source for each playlist type (PL-3).
@Riverpod(keepAlive: true)
SeriesCatalogSource seriesCatalogSource(Ref ref, PlaylistType type) =>
    switch (type) {
      PlaylistType.xtream => XtreamSeriesSource(
        ref.watch(xtreamApiClientProvider),
      ),
    };
