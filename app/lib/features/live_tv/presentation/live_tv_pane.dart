import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/focus_memory_scope.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../player/data/player_providers.dart';
import '../../player/domain/playback_engine.dart';
import '../../player/presentation/playback_surface.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/domain/playlist.dart';
import '../application/live_catalog_controller.dart';
import '../application/live_tv_providers.dart';
import 'channel_widgets.dart';
import 'guide_grid.dart';
import 'live_player_screen.dart';

/// Live TV section of the home screen (LIVE-1, LIVE-2): the guide with a
/// preview of the channel played last. Left from the guide opens the
/// categories over it, left again the side menu.
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

  @override
  void dispose() {
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
    setState(() => _categoriesOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_categoryScope.hasFocus) _categoryScope.enter();
    });
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
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(activeProfilePlaylistsProvider);
    final playlist = ref.watch(livePlaylistSelectionProvider);

    if (!playlists.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (playlist == null) return const _NoPlaylist();

    _ensureCatalog(playlist.id);
    final status = ref.watch(liveCatalogControllerProvider(playlist.id));
    final categoryId = ref.watch(liveCategorySelectionProvider(playlist.id));
    final categories =
        ref.watch(liveCategoriesProvider(playlist.id)).value ?? const [];
    final channels = ref
        .watch(liveChannelListProvider(playlist.id, categoryId))
        .value;
    // Nothing focusable while the list opens: a button shown only for a
    // moment would take the focus with it when it disappears.
    if (channels == null && categoryId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (channels != null && channels.length == 0 && categoryId == null) {
      return _CatalogState(playlistId: playlist.id, status: status);
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
            preview: isPhone
                ? null
                : _Preview(
                    engine: _preview?.read(),
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

    return Stack(
      children: [
        Positioned.fill(
          child: LeaveLeft(onLeftEdge: _openCategories, child: grid),
        ),
        if (_categoriesOpen)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 260,
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
                        selectedCategoryId: categoryId,
                        status: status,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Video of the channel played last, or an empty frame before anything
/// played.
class _Preview extends StatelessWidget {
  const _Preview({required this.engine, required this.onSelect});

  final PlaybackEngine? engine;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final engine = this.engine;
    return GestureDetector(
      onTap: onSelect,
      child: engine == null
          ? const ColoredBox(
              color: AppColors.surface,
              child: Center(
                child: Icon(
                  Icons.live_tv,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : PlaybackSurface(engine: engine),
    );
  }
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

class _NoPlaylist extends StatelessWidget {
  const _NoPlaylist();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.playlist_add,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(l10n.liveNoPlaylistTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.liveNoPlaylistMessage,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TvButton(
              label: l10n.playlistAdd,
              icon: Icons.add,
              style: TvButtonStyle.primary,
              autofocus: true,
              onPressed: () => context.push(AppRoutes.newPlaylist),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown while no catalog exists yet: loading progress, error or empty.
class _CatalogState extends ConsumerWidget {
  const _CatalogState({required this.playlistId, required this.status});

  final String playlistId;
  final LiveCatalogStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    void retry() =>
        ref.read(liveCatalogControllerProvider(playlistId).notifier).refresh();

    final List<Widget> content = switch (status) {
      LiveCatalogLoading(:final channelsLoaded) => [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(l10n.liveLoading, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.liveLoadingCount(channelsLoaded), style: textTheme.bodySmall),
      ],
      LiveCatalogFailed(:final reason) => [
        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
        const SizedBox(height: 16),
        Text(
          describeCatalogFailure(l10n, reason),
          style: textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TvButton(
          label: l10n.liveRetry,
          icon: Icons.refresh,
          style: TvButtonStyle.primary,
          autofocus: true,
          onPressed: retry,
        ),
      ],
      LiveCatalogIdle() => [
        Text(l10n.liveNoChannels, style: textTheme.titleMedium),
        const SizedBox(height: 24),
        TvButton(
          label: l10n.liveRefresh,
          icon: Icons.refresh,
          autofocus: true,
          onPressed: retry,
        ),
      ],
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: content),
      ),
    );
  }
}

class _CategoryColumn extends ConsumerWidget {
  const _CategoryColumn({
    required this.playlist,
    required this.playlists,
    required this.selectedCategoryId,
    required this.status,
  });

  final Playlist playlist;
  final List<Playlist> playlists;
  final String? selectedCategoryId;
  final LiveCatalogStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        autofocus: selectedCategoryId == null,
        onFocus: () => selection.select(null),
      ),
      for (final category in categories)
        _CategoryTile(
          label: category.name,
          count: category.channelCount,
          selected: category.id == selectedCategoryId,
          autofocus: category.id == selectedCategoryId,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
    this.autofocus = false,
    this.onFocus,
    this.onSelect,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;
  final bool autofocus;

  /// Categories switch the channel list as soon as they are focused, like in
  /// common IPTV players.
  final VoidCallback? onFocus;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      autofocus: autofocus,
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
