import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/paged_list.dart';
import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/content_hooks.dart';
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

/// Movies section of the home screen (VOD-1): a poster grid of the selected
/// category. Left from the first column or back opens the categories next
/// to it, focused on the selected one; select or right on a category closes
/// them again, like common IPTV players.
class MoviesPane extends ConsumerStatefulWidget {
  const MoviesPane({super.key});

  @override
  ConsumerState<MoviesPane> createState() => _MoviesPaneState();
}

class _MoviesPaneState extends ConsumerState<MoviesPane> {
  String? _checkedPlaylistId;

  bool _categoriesOpen = false;

  /// While the categories are open, a new grid must not take focus with its
  /// first poster.
  late final _gridScope = FocusMemoryScopeNode(
    debugLabel: 'movieGrid',
    allowAutofocus: () => !_categoriesOpen,
  );
  final _categoryScope = FocusMemoryScopeNode(debugLabel: 'movieCategories');
  ContentHooksController? _hooks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _hooks = ContentHooks.maybeOf(context)
      ?..register(back: _onBack, enter: _onEnter);
  }

  @override
  void dispose() {
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _gridScope.dispose();
    _categoryScope.dispose();
    super.dispose();
  }

  /// Back from the grid opens the categories; back from the categories is
  /// left to the home screen, which focuses the menu.
  /// Whether the last build showed the categories layout; only then the
  /// categories can be opened.
  bool _showsGrid = false;
  bool _loading = false;
  bool _enterPending = false;

  /// Entering from the menu starts in the categories, focused on the
  /// selected one, like common IPTV players.
  bool _onEnter() {
    if (ScreenClass.of(context).isPhone) return false;
    if (!_showsGrid) {
      // Still loading: the categories open as soon as they are there, and
      // focus stays in the menu meanwhile.
      if (!_loading) return false;
      _enterPending = true;
      return true;
    }
    if (_categoriesOpen) {
      _categoryScope.enter();
    } else {
      _openCategories();
    }
    return true;
  }

  bool _onBack() {
    if (_categoriesOpen || !_gridScope.hasFocus) return false;
    if (ScreenClass.of(context).isPhone) return false;
    _openCategories();
    return true;
  }

  void _openCategories() {
    // The category column focuses the selected category when it opens.
    setState(() => _categoriesOpen = true);
  }

  void _closeCategories({bool focusGrid = true}) {
    if (!_categoriesOpen) return;
    setState(() => _categoriesOpen = false);
    if (!focusGrid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _gridScope.enter();
    });
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
    _showsGrid = false;
    _loading = false;
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(activeProfilePlaylistsProvider);
    // The playlist choice is shared with live TV.
    final playlist = ref.watch(livePlaylistSelectionProvider);

    if (!playlists.hasValue) {
      _loading = true;
      return const Center(child: CircularProgressIndicator());
    }
    if (playlist == null) {
      return NoPlaylistView(message: l10n.moviesNoPlaylistMessage);
    }

    _ensureCatalog(playlist.id);
    final status = ref.watch(movieCatalogControllerProvider(playlist.id));
    final filter = ref.watch(movieFilterSelectionProvider(playlist.id));
    final movies = ref.watch(movieListProvider(playlist.id, filter)).value;
    // Whether there is a catalog at all, independent of the selected list:
    // switching lists must keep categories and grid on screen.
    final allMovies = ref
        .watch(movieListProvider(playlist.id, MovieFilter.all))
        .value;

    // Nothing focusable while the list opens: a button shown only for a
    // moment would take the focus with it when it disappears.
    if (allMovies == null) {
      _loading = true;
      return const Center(child: CircularProgressIndicator());
    }
    if (allMovies.length == 0) {
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

    _showsGrid = true;
    if (_enterPending) {
      _enterPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onEnter();
      });
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_categoriesOpen)
          SizedBox(
            width: 240,
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              // Leaving the categories in any direction closes them.
              onFocusChange: (focused) {
                if (!focused) _closeCategories(focusGrid: false);
              },
              child: ExitRight(
                onRight: _closeCategories,
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
                        onChosen: _closeCategories,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: LeaveLeft(
            onLeftEdge: _openCategories,
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

class _CategoryColumn extends ConsumerStatefulWidget {
  const _CategoryColumn({
    required this.playlist,
    required this.playlists,
    required this.selected,
    required this.status,
    required this.onChosen,
  });

  final Playlist playlist;
  final List<Playlist> playlists;
  final MovieFilter selected;
  final MovieCatalogStatus status;

  /// Select on a category: it is chosen, the column closes.
  final VoidCallback onChosen;

  @override
  ConsumerState<_CategoryColumn> createState() => _CategoryColumnState();
}

class _CategoryColumnState extends ConsumerState<_CategoryColumn> {
  /// Fixed lists before the provider categories.
  static const _lists = [
    MovieFilter.list(MovieList.continueWatching),
    MovieFilter.list(MovieList.favorites),
    MovieFilter.all,
  ];

  /// The column opens scrolled to the selected entry, so its tile is built
  /// and can take focus; lists only build the visible rows.
  late final _scroll = ScrollController(
    initialScrollOffset: math.max(0, _openedIndex - 3) * _CategoryTile.extent,
  );

  /// Focus node of the entry selected when the column opened. It stays with
  /// that tile, so moving on and changing the selection never moves a
  /// focused node between tiles.
  final _openedOn = FocusNode(debugLabel: 'openedMovieCategory');
  late final MovieFilter _openedFilter = widget.selected;

  int get _openedIndex {
    final categories =
        ref.read(movieCategoriesProvider(widget.playlist.id)).value ?? const [];
    final offset = widget.playlists.length > 1 ? 1 : 0;
    final list = _lists.indexOf(widget.selected);
    if (list >= 0) return offset + list;
    final index = categories.indexWhere(
      (c) => c.id == widget.selected.categoryId,
    );
    return offset + _lists.length + math.max(0, index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openedOn.requestFocus();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _openedOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;
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
          selected: filter == widget.selected,
          focusNode: filter == _openedFilter ? _openedOn : null,
          onFocus: () => selection.select(filter),
          onSelect: widget.onChosen,
        );

    final entries = <Widget>[
      if (widget.playlists.length > 1)
        _CategoryTile(
          label: playlist.name,
          icon: Icons.playlist_play,
          onSelect: () async {
            final chosen = await showTvChoiceDialog<Playlist>(
              context,
              title: l10n.liveChoosePlaylist,
              choices: [for (final p in widget.playlists) TvChoice(p, p.name)],
            );
            if (chosen != null) {
              ref.read(livePlaylistSelectionProvider.notifier).select(chosen);
            }
          },
        ),
      for (final list in _lists) entry(list),
      for (final category in categories)
        entry(
          MovieFilter.category(category.id),
          label: category.name,
          count: category.movieCount,
        ),
      _CategoryTile(
        label: widget.status is MovieCatalogLoading
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
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemExtent: _CategoryTile.extent,
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
    this.focusNode,
    this.onFocus,
    this.onSelect,
  });

  /// Height of a tile including its gap, fixed for jumping to an entry.
  static const extent = 46.0;

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;
  final FocusNode? focusNode;

  /// Categories switch the grid as soon as they are focused, like the live
  /// TV categories.
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      focusNode: focusNode,
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
