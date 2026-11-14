import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/content_hooks.dart';
import '../../../shared/widgets/focus_memory_scope.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/push_aside.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../player/data/player_providers.dart';
import '../../player/domain/playback_engine.dart';
import '../../player/presentation/playback_surface.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/domain/playlist.dart';
import '../../playlists/presentation/catalog_views.dart';
import '../application/live_catalog_controller.dart';
import '../application/live_tv_providers.dart';
import 'guide_grid.dart';
import 'live_player_screen.dart';

/// Live TV section of the home screen (LIVE-1, LIVE-2): the guide, with a
/// preview of the channel played last. Left or back from the programme
/// running now opens the categories, which push the guide to the right;
/// left or back from there reaches the side menu.
class LiveTvPane extends ConsumerStatefulWidget {
  const LiveTvPane({super.key});

  @override
  ConsumerState<LiveTvPane> createState() => _LiveTvPaneState();
}

class _LiveTvPaneState extends ConsumerState<LiveTvPane> {
  String? _checkedPlaylistId;
  bool _categoriesOpen = false;

  /// Categories remember the selected one, so they open on it.
  final _categoryScope = FocusMemoryScopeNode(debugLabel: 'liveCategories');

  /// A new category gets a new grid, which starts at its first channel.
  var _gridKey = GlobalKey<GuideGridState>();
  (String, String?)? _gridOf;

  /// Keeps the player engine alive after the full screen player closed, so
  /// the channel continues in the preview. Closed with this section.
  ProviderSubscription<PlaybackEngine>? _preview;

  ContentHooksController? _hooks;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _hooks = ContentHooks.maybeOf(context)
      ?..register(back: _onBack, enter: _onEnter);
  }

  /// Back from the guide opens the categories; back from the categories
  /// is left to the home screen, which focuses the menu.
  /// Whether the last build showed the categories layout; only then the
  /// categories can be opened.
  bool _showsGuide = false;
  bool _loading = false;
  bool _enterPending = false;

  /// Entering from the menu starts in the categories, focused on the
  /// selected one, like common IPTV players.
  bool _onEnter() {
    if (ScreenClass.of(context).isPhone) return false;
    if (!_showsGuide) {
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
    final grid = _gridKey.currentState;
    if (_categoriesOpen || grid == null || !grid.hasFocus) return false;
    if (ScreenClass.of(context).isPhone) return false;
    _openCategories();
    return true;
  }

  @override
  void dispose() {
    _hooks?.unregister(back: _onBack, enter: _onEnter);
    _preview?.close();
    _categoryScope.dispose();
    super.dispose();
  }

  Future<void> _play(Playlist playlist, String? categoryId, int index) async {
    await context.push(
      AppRoutes.livePlayer,
      extra: LivePlayerArgs(
        playlistId: playlist.id,
        categoryId: categoryId,
        index: index,
      ),
    );
    if (!mounted) return;
    final playing = ref.read(nowPlayingProvider);
    if (playing == null) return;
    setState(() {
      _preview ??= ref.listenManual(playbackEngineProvider, (_, _) {});
    });
    // Back from the player shows the channel that played last.
    if (playing.position.playlistId == playlist.id &&
        playing.position.categoryId == categoryId) {
      _gridKey.currentState?.showRow(playing.position.index);
    }
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
      if (mounted) _gridKey.currentState?.focus();
    });
  }

  /// Loads the catalog once per playlist when it is missing or outdated.
  void _ensureCatalog(String playlistId) {
    if (_checkedPlaylistId == playlistId) return;
    _checkedPlaylistId = playlistId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(liveCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    _showsGuide = false;
    _loading = false;
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(activeProfilePlaylistsProvider);
    final playlist = ref.watch(livePlaylistSelectionProvider);

    if (!playlists.hasValue) {
      _loading = true;
      return const Center(child: CircularProgressIndicator());
    }
    if (playlist == null) {
      return NoPlaylistView(message: l10n.liveNoPlaylistMessage);
    }

    _ensureCatalog(playlist.id);
    final status = ref.watch(liveCatalogControllerProvider(playlist.id));
    final categoryId = ref.watch(liveCategorySelectionProvider(playlist.id));
    final categories =
        ref.watch(liveCategoriesProvider(playlist.id)).value ?? const [];
    final channels = ref
        .watch(liveChannelListProvider(playlist.id, categoryId))
        .value;
    // Whether there is a catalog at all, independent of the selected
    // category: switching categories must keep categories and grid on
    // screen.
    final allChannels = ref
        .watch(liveChannelListProvider(playlist.id, null))
        .value;

    // Nothing focusable while the list opens: a button shown only for a
    // moment would take the focus with it when it disappears.
    if (allChannels == null) {
      _loading = true;
      return const Center(child: CircularProgressIndicator());
    }
    if (allChannels.length == 0) {
      return CatalogStateView(
        loadedText: switch (status) {
          LiveCatalogLoading(:final channelsLoaded) => l10n.liveLoadingCount(
            channelsLoaded,
          ),
          _ => null,
        },
        failure: switch (status) {
          LiveCatalogFailed(:final reason) => reason,
          _ => null,
        },
        loadingTitle: l10n.liveLoading,
        emptyText: l10n.liveNoChannels,
        refreshLabel: l10n.liveRefresh,
        onRetry: () => ref
            .read(liveCatalogControllerProvider(playlist.id).notifier)
            .refresh(),
      );
    }

    if (_gridOf != (playlist.id, categoryId)) {
      _gridOf = (playlist.id, categoryId);
      _gridKey = GlobalKey<GuideGridState>();
    }
    final playing = _preview == null ? null : ref.watch(nowPlayingProvider);
    final playingHere =
        playing != null &&
        playing.position.playlistId == playlist.id &&
        playing.position.categoryId == categoryId;
    final categoryName =
        categories.where((c) => c.id == categoryId).firstOrNull?.name ??
        l10n.liveAllChannels;
    final isPhone = ScreenClass.of(context).isPhone;

    final grid = channels == null
        ? const SizedBox.shrink()
        : GuideGrid(
            key: _gridKey,
            playlistId: playlist.id,
            channels: channels,
            autofocus: !_categoriesOpen,
            playingIndex: playingHere ? playing.position.index : null,
            subtitle: '${playlist.name}  ·  $categoryName',
            preview: isPhone || _preview == null
                ? null
                : _Preview(
                    engine: _preview!.read(),
                    onSelect: playing == null
                        ? null
                        : () => _play(
                            playlist,
                            playing.position.categoryId,
                            playing.position.index,
                          ),
                  ),
            headerAction: isPhone
                ? _CategoryButton(playlistId: playlist.id, title: categoryName)
                : null,
            onPlay: (index) => _play(playlist, categoryId, index),
          );

    if (isPhone) return grid;

    _showsGuide = true;
    if (_enterPending) {
      _enterPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onEnter();
      });
    }
    return PushAside(
      open: _categoriesOpen,
      panelWidth: 260,
      panel: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        // Focus moving into the grid, for example by touch, closes the
        // categories. The side menu and dialogs leave them open, like
        // in common IPTV players.
        onFocusChange: (focused) {
          if (!focused && (_gridKey.currentState?.hasFocus ?? false)) {
            _closeCategories(focusGrid: false);
          }
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
                  selectedCategoryId: categoryId,
                  status: status,
                  onChosen: _closeCategories,
                ),
              ),
            ),
          ),
        ),
      ),
      child: LeaveLeft(onLeftEdge: _openCategories, child: grid),
    );
  }
}

/// Video of the channel played last.
class _Preview extends StatelessWidget {
  const _Preview({required this.engine, required this.onSelect});

  final PlaybackEngine engine;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onSelect,
    child: PlaybackSurface(engine: engine),
  );
}

/// Category selection on phones, where there is no room for the list.
class _CategoryButton extends ConsumerWidget {
  const _CategoryButton({required this.playlistId, required this.title});

  final String playlistId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      onSelect: () async {
        final categories =
            ref.read(liveCategoriesProvider(playlistId)).value ?? const [];
        final chosen = await showTvChoiceDialog<String>(
          context,
          title: l10n.liveChooseCategory,
          choices: [
            TvChoice('', l10n.liveAllChannels),
            for (final c in categories) TvChoice(c.id, c.name),
          ],
        );
        if (chosen == null) return;
        ref
            .read(liveCategorySelectionProvider(playlistId).notifier)
            .select(chosen.isEmpty ? null : chosen);
      },
      builder: (context, focused) => Container(
        constraints: const BoxConstraints(maxWidth: 160),
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: MarqueeText(
                title,
                active: focused,
                style: textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryColumn extends ConsumerStatefulWidget {
  const _CategoryColumn({
    required this.playlist,
    required this.playlists,
    required this.selectedCategoryId,
    required this.status,
    required this.onChosen,
  });

  final Playlist playlist;
  final List<Playlist> playlists;
  final String? selectedCategoryId;
  final LiveCatalogStatus status;

  /// Select on a category: it is chosen, the column closes.
  final VoidCallback onChosen;

  @override
  ConsumerState<_CategoryColumn> createState() => _CategoryColumnState();
}

class _CategoryColumnState extends ConsumerState<_CategoryColumn> {
  /// Opens scrolled to the selected category, so its tile is built and
  /// takes focus; lists only build the visible rows.
  late final _scroll = ScrollController(
    initialScrollOffset: math.max(0, _selectedEntry - 3) * _CategoryTile.extent,
  );

  /// Focus node of the category selected when the column opened. It stays
  /// with that tile, so focus moving on and changing the selection does not
  /// move a focused node between tiles.
  final _openedOn = FocusNode(debugLabel: 'openedCategory');
  late final String? _openedCategoryId = widget.selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openedOn.requestFocus();
    });
  }

  int get _selectedEntry {
    final categories =
        ref.read(liveCategoriesProvider(widget.playlist.id)).value ?? const [];
    final index = categories.indexWhere(
      (c) => c.id == widget.selectedCategoryId,
    );
    return (widget.playlists.length > 1 ? 1 : 0) + index + 1;
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
    final playlists = widget.playlists;
    final selectedCategoryId = widget.selectedCategoryId;
    final status = widget.status;
    final l10n = AppLocalizations.of(context);
    final categories =
        ref.watch(liveCategoriesProvider(playlist.id)).value ?? const [];
    final selection = ref.read(
      liveCategorySelectionProvider(playlist.id).notifier,
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
      _CategoryTile(
        label: l10n.liveAllChannels,
        selected: selectedCategoryId == null,
        focusNode: _openedCategoryId == null ? _openedOn : null,
        onSelect: widget.onChosen,
        onFocus: () => selection.select(null),
      ),
      for (final category in categories)
        _CategoryTile(
          label: category.name,
          count: category.channelCount,
          selected: category.id == selectedCategoryId,
          focusNode: category.id == _openedCategoryId ? _openedOn : null,
          onSelect: widget.onChosen,
          onFocus: () => selection.select(category.id),
        ),
      _CategoryTile(
        label: status is LiveCatalogLoading
            ? l10n.liveUpdating
            : l10n.liveRefresh,
        icon: Icons.refresh,
        onSelect: () => ref
            .read(liveCatalogControllerProvider(playlist.id).notifier)
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

  /// Categories switch the channel list as soon as they are focused, like in
  /// common IPTV players.
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
