import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/paged_list.dart';
import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/focus_memory_scope.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../live_tv/application/live_tv_providers.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/domain/playlist.dart';
import '../../playlists/presentation/catalog_views.dart';
import '../application/movie_catalog_controller.dart';
import '../application/movie_providers.dart';
import '../domain/movie.dart';
import '../domain/movie_repository.dart';
import 'movie_poster.dart';

/// Movies section of the home screen (VOD-1): categories on the left, a
/// poster grid of the selected one on the right.
class MoviesPane extends ConsumerStatefulWidget {
  const MoviesPane({super.key});

  @override
  ConsumerState<MoviesPane> createState() => _MoviesPaneState();
}

class _MoviesPaneState extends ConsumerState<MoviesPane> {
  String? _checkedPlaylistId;

  /// While the categories have focus, a new grid must not take focus with
  /// its first poster.
  bool _categoriesFocused = false;
  late final _gridScope = FocusMemoryScopeNode(
    debugLabel: 'movieGrid',
    allowAutofocus: () => !_categoriesFocused,
  );
  final _categoryScope = FocusMemoryScopeNode(debugLabel: 'movieCategories');

  @override
  void dispose() {
    _gridScope.dispose();
    _categoryScope.dispose();
    super.dispose();
  }

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

    if (!playlists.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (playlist == null) {
      return NoPlaylistView(message: l10n.moviesNoPlaylistMessage);
    }

    _ensureCatalog(playlist.id);
    final status = ref.watch(movieCatalogControllerProvider(playlist.id));
    final filter = ref.watch(movieFilterSelectionProvider(playlist.id));
    final movies = ref.watch(movieListProvider(playlist.id, filter)).value;

    // Nothing focusable while the list opens: a button shown only for a
    // moment would take the focus with it when it disappears.
    if (movies == null && filter == MovieFilter.all) {
      return const Center(child: CircularProgressIndicator());
    }
    if (movies != null && movies.length == 0 && filter == MovieFilter.all) {
      return CatalogStateView(
        loadedText: switch (status) {
          MovieCatalogLoading(:final moviesLoaded) => l10n.moviesLoadingCount(
            moviesLoaded,
          ),
          _ => null,
        },
        failure: switch (status) {
          MovieCatalogFailed(:final reason) => reason,
          _ => null,
        },
        loadingTitle: l10n.moviesLoading,
        emptyText: l10n.moviesNone,
        refreshLabel: l10n.moviesRefresh,
        onRetry: () => ref
            .read(movieCatalogControllerProvider(playlist.id).notifier)
            .refresh(),
      );
    }

    final isPhone = ScreenClass.of(context).isPhone;
    final grid = _MovieGrid(
      // A new filter starts at its first poster.
      key: ValueKey(filter),
      movies: movies,
      header: _GridHeader(
        playlist: playlist,
        filter: filter,
        status: status,
        selectable: isPhone,
      ),
    );
    if (isPhone) return grid;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 240,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) => _categoriesFocused = focused,
            child: ExitRight(
              onRight: _gridScope.enter,
              // Left from the categories reaches the menu through the
              // LeaveLeft of the home screen.
              child: LeaveLeft(
                child: FocusScope(
                  node: _categoryScope,
                  child: FocusTraversalGroup(
                    child: _CategoryColumn(
                      playlist: playlist,
                      playlists: playlists.value!,
                      selected: filter,
                      status: status,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: LeaveLeft(
            onLeftEdge: _categoryScope.enter,
            child: FocusScope(
              node: _gridScope,
              child: FocusTraversalGroup(child: grid),
            ),
          ),
        ),
      ],
    );
  }
}

/// Title of the selected list; on phones also the way to choose it.
class _GridHeader extends ConsumerWidget {
  const _GridHeader({
    required this.playlist,
    required this.filter,
    required this.status,
    required this.selectable,
  });

  final Playlist playlist;
  final MovieFilter filter;
  final MovieCatalogStatus status;
  final bool selectable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final categories =
        ref.watch(movieCategoriesProvider(playlist.id)).value ?? const [];
    final title = filterLabel(l10n, filter, categories);

    final Widget heading = selectable
        ? TvFocusable(
            onSelect: () async {
              final chosen = await showTvChoiceDialog<MovieFilter>(
                context,
                title: l10n.liveChooseCategory,
                choices: [
                  for (final list in MovieList.values)
                    TvChoice(
                      MovieFilter.list(list),
                      filterLabel(l10n, MovieFilter.list(list), categories),
                    ),
                  for (final c in categories)
                    TvChoice(MovieFilter.category(c.id), c.name),
                ],
              );
              if (chosen == null) return;
              ref
                  .read(movieFilterSelectionProvider(playlist.id).notifier)
                  .select(chosen);
            },
            builder: (context, focused) => Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          )
        : Text(title, style: textTheme.titleMedium, maxLines: 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(child: heading),
          if (status is MovieCatalogLoading) ...[
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.moviesUpdating, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
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

/// Poster grid with fixed cell sizes, so it is virtualized and jumps to any
/// row without measuring (RES-3, UI-3).
class _MovieGrid extends StatelessWidget {
  const _MovieGrid({super.key, required this.movies, required this.header});

  final PagedList<Movie>? movies;
  final Widget header;

  static const _posterWidth = 124.0;
  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movies = this.movies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: switch (movies) {
            null => const SizedBox.shrink(),
            PagedList(length: 0) => Center(
              child: Text(
                l10n.moviesEmptyList,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _ => LayoutBuilder(
              builder: (context, constraints) {
                final columns = math.max(
                  2,
                  ((constraints.maxWidth - 16) / (_posterWidth + _spacing))
                      .floor(),
                );
                return ListenableBuilder(
                  listenable: movies,
                  builder: (context, _) => GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: _spacing,
                      crossAxisSpacing: _spacing,
                      mainAxisExtent: MoviePoster.extentFor(
                        (constraints.maxWidth - 32 - (columns - 1) * _spacing) /
                            columns,
                      ),
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies.itemAt(index);
                      return MoviePoster(
                        key: ValueKey(index),
                        movie: movie,
                        autofocus: index == 0,
                        onSelect: movie == null
                            ? null
                            : () => context.push(
                                AppRoutes.movieDetail,
                                extra: movie,
                              ),
                      );
                    },
                  ),
                );
              },
            ),
          },
        ),
      ],
    );
  }
}

class _CategoryColumn extends ConsumerWidget {
  const _CategoryColumn({
    required this.playlist,
    required this.playlists,
    required this.selected,
    required this.status,
  });

  final Playlist playlist;
  final List<Playlist> playlists;
  final MovieFilter selected;
  final MovieCatalogStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories =
        ref.watch(movieCategoriesProvider(playlist.id)).value ?? const [];
    final selection = ref.read(
      movieFilterSelectionProvider(playlist.id).notifier,
    );

    Widget entry(MovieFilter filter, {String? label, int? count}) =>
        _CategoryTile(
          label: label ?? filterLabel(l10n, filter, categories),
          count: count,
          selected: filter == selected,
          onFocus: () => selection.select(filter),
        );

    final entries = <Widget>[
      if (playlists.length > 1)
        _CategoryTile(
          label: playlist.name,
          icon: Icons.playlist_play,
          onSelect: () async {
            final chosen = await showTvChoiceDialog<Playlist>(
              context,
              title: l10n.liveChoosePlaylist,
              choices: [for (final p in playlists) TvChoice(p, p.name)],
            );
            if (chosen != null) {
              ref.read(livePlaylistSelectionProvider.notifier).select(chosen);
            }
          },
        ),
      entry(const MovieFilter.list(MovieList.continueWatching)),
      entry(const MovieFilter.list(MovieList.favorites)),
      entry(MovieFilter.all),
      for (final category in categories)
        entry(
          MovieFilter.category(category.id),
          label: category.name,
          count: category.movieCount,
        ),
      _CategoryTile(
        label: status is MovieCatalogLoading
            ? l10n.moviesUpdating
            : l10n.moviesRefresh,
        icon: Icons.refresh,
        onSelect: () => ref
            .read(movieCatalogControllerProvider(playlist.id).notifier)
            .refresh(),
      ),
    ];

    return ColoredBox(
      color: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemExtent: 46,
        itemCount: entries.length,
        itemBuilder: (context, index) => entries[index],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    this.count,
    this.icon,
    this.selected = false,
    this.onFocus,
    this.onSelect,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;

  /// Categories switch the grid as soon as they are focused, like the live
  /// TV categories.
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      onFocusChange: (focused) {
        if (focused) onFocus?.call();
      },
      onSelect: onSelect,
      builder: (context, focused) {
        final color = selected ? AppColors.accent : AppColors.textPrimary;
        return Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: focused ? AppColors.focusFill : null,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: focused ? AppColors.focusBorder : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: MarqueeText(
                  label,
                  active: focused,
                  style: textTheme.bodyMedium?.copyWith(color: color),
                ),
              ),
              if (count != null) Text('$count', style: textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
