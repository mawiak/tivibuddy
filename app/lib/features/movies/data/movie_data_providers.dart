import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../playlists/data/playlist_data_providers.dart';
import '../../playlists/domain/playlist.dart';
import '../domain/movie_repository.dart';
import 'drift_movie_repository.dart';
import 'xtream/xtream_movie_source.dart';

part 'movie_data_providers.g.dart';

@Riverpod(keepAlive: true)
MovieRepository movieRepository(Ref ref) =>
    DriftMovieRepository(ref.watch(appDatabaseProvider));

/// Movie source for each playlist type (PL-3).
@Riverpod(keepAlive: true)
MovieCatalogSource movieCatalogSource(Ref ref, PlaylistType type) =>
    switch (type) {
      PlaylistType.xtream => XtreamMovieSource(
        ref.watch(xtreamApiClientProvider),
      ),
    };
