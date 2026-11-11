import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/domain/playlist.dart';
import '../../playlists/presentation/catalog_views.dart';
import '../../vod/presentation/vod_browser.dart';
import '../../vod/presentation/vod_info_header.dart';
import '../application/movie_catalog_controller.dart';
import '../application/movie_providers.dart';
import '../domain/movie.dart';
import '../domain/movie_repository.dart';
import 'movie_poster.dart';

/// Movies section of the home screen (VOD-1): categories and poster grid,
/// see [VodBrowser].
class MoviesPane extends ConsumerStatefulWidget {
  const MoviesPane({super.key});

  @override
  ConsumerState<MoviesPane> createState() => _MoviesPaneState();
}

class _MoviesPaneState extends ConsumerState<MoviesPane> {
  String? _checkedPlaylistId;

  /// Loads the catalog once per playlist when it is missing or outdated.
  void _ensureCatalog(String playlistId) {
    if (_checkedPlaylistId == playlistId) return;
    _checkedPlaylistId = playlistId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(movieCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(activeProfilePlaylistsProvider);
    // The playlist choice is shared with live TV.
    final playlist = ref.watch(livePlaylistSelectionProvider);
    if (playlists.hasValue && playlist == null) {
      return NoPlaylistView(message: l10n.moviesNoPlaylistMessage);
    }
    if (playlist != null) _ensureCatalog(playlist.id);

    final status = playlist == null
        ? const MovieCatalogIdle()
        : ref.watch(movieCatalogControllerProvider(playlist.id));
    final filter = playlist == null
        ? MovieFilter.all
        : ref.watch(movieFilterSelectionProvider(playlist.id));
    final movies = playlist == null
        ? null
        : ref.watch(movieListProvider(playlist.id, filter)).value;
    // Whether there is a catalog at all, independent of the selected list:
    // switching lists must keep categories and grid on screen.
    final allMovies = playlist == null
        ? null
        : ref.watch(movieListProvider(playlist.id, MovieFilter.all)).value;
    final categories = playlist == null
        ? const <MovieCategory>[]
        : ref.watch(movieCategoriesProvider(playlist.id)).value ?? const [];

    void refresh() => ref
        .read(movieCatalogControllerProvider(playlist!.id).notifier)
        .refresh();

    return VodBrowser<Movie>(
      // Nothing focusable while the list opens: a button shown only for a
      // moment would take the focus with it when it disappears.
      loading: playlist == null || allMovies == null,
      emptyView: allMovies != null && allMovies.length == 0
          ? CatalogStateView(
              loadedText: switch (status) {
                MovieCatalogLoading(:final moviesLoaded) =>
                  l10n.moviesLoadingCount(moviesLoaded),
                _ => null,
              },
              failure: switch (status) {
                MovieCatalogFailed(:final reason) => reason,
                _ => null,
              },
              loadingTitle: l10n.moviesLoading,
              emptyText: l10n.moviesNone,
              refreshLabel: l10n.moviesRefresh,
              onRetry: refresh,
            )
          : null,
      items: movies,
      listKey: filter,
      listTitle: filterLabel(l10n, filter, categories),
      updating: status is MovieCatalogLoading,
      updatingLabel: l10n.moviesUpdating,
      entries: [
        if (playlist != null && (playlists.value?.length ?? 0) > 1)
          VodCategoryEntry.action(
            label: playlist.name,
            icon: Icons.playlist_play,
            onSelect: () => _choosePlaylist(playlists.value!),
          ),
        for (final list in const [
          MovieFilter.list(MovieList.continueWatching),
          MovieFilter.list(MovieList.favorites),
          MovieFilter.all,
        ])
          VodCategoryEntry.list(
            key: list,
            label: filterLabel(l10n, list, categories),
          ),
        for (final category in categories)
          VodCategoryEntry.list(
            key: MovieFilter.category(category.id),
            label: category.name,
            count: category.movieCount,
          ),
        VodCategoryEntry.action(
          label: status is MovieCatalogLoading
              ? l10n.moviesUpdating
              : l10n.moviesRefresh,
          icon: Icons.refresh,
          onSelect: refresh,
        ),
      ],
      onListFocused: (key) => ref
          .read(movieFilterSelectionProvider(playlist!.id).notifier)
          .select(key as MovieFilter),
      tileBuilder:
          (context, movie, index, {required autofocus, onFocusChange}) =>
              MoviePoster(
                movie: movie,
                autofocus: autofocus,
                onFocusChange: onFocusChange,
                onSelect: movie == null
                    ? null
                    : () => context.push(AppRoutes.movieDetail, extra: movie),
              ),
      infoBuilder: (context, movie) => _MovieInfo(
        movie: movie,
        listTitle: filterLabel(l10n, filter, categories),
      ),
    );
  }

  Future<void> _choosePlaylist(List<Playlist> playlists) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showTvChoiceDialog<Playlist>(
      context,
      title: l10n.liveChoosePlaylist,
      choices: [for (final p in playlists) TvChoice(p, p.name)],
    );
    if (chosen != null) {
      ref.read(livePlaylistSelectionProvider.notifier).select(chosen);
    }
  }
}

String filterLabel(
  AppLocalizations l10n,
  MovieFilter filter,
  List<MovieCategory> categories,
) => switch (filter.list) {
  MovieList.all => l10n.moviesAll,
  MovieList.favorites => l10n.moviesFavorites,
  MovieList.continueWatching => l10n.moviesContinue,
  null =>
    categories.where((c) => c.id == filter.categoryId).firstOrNull?.name ??
        l10n.moviesAll,
};

/// Details of the focused movie, loaded from the provider on demand.
class _MovieInfo extends ConsumerWidget {
  const _MovieInfo({required this.movie, required this.listTitle});

  final Movie? movie;
  final String listTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final movie = this.movie;
    final info = movie == null
        ? MovieDetails.empty
        : ref.watch(movieDetailsProvider(movie)).value ?? MovieDetails.empty;
    final rating = info.rating ?? movie?.rating;
    final duration = info.duration;
    return VodInfoHeader(
      listTitle: listTitle,
      title: movie?.name,
      meta: [
        ?info.year,
        if (duration != null) l10n.guideMinutes(duration.inMinutes),
        ?info.genre,
        if (rating != null) '★ ${rating.toStringAsFixed(1)}',
      ].join('  ·  '),
      plot: info.plot,
      backdropUrl: info.backdropUrl,
    );
  }
}
