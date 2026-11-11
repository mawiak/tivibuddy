import 'dart:async';

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
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../playlists/domain/playlist.dart';
import '../application/live_catalog_controller.dart';
import '../application/live_tv_providers.dart';
import '../domain/live_channel.dart';
import 'channel_widgets.dart';
import 'live_player_screen.dart';

/// Live TV section of the home screen (LIVE-1): categories, channel list and
/// details of the focused channel.
class LiveTvPane extends ConsumerStatefulWidget {
  const LiveTvPane({super.key});

  @override
  ConsumerState<LiveTvPane> createState() => _LiveTvPaneState();
}

class _LiveTvPaneState extends ConsumerState<LiveTvPane> {
  /// Position of the channel shown in the info panel, together with the
  /// category it belongs to. Updated after focus rested briefly, so
  /// scrolling through the list does not request programme data for every
  /// channel passed. A position instead of a channel keeps the panel correct
  /// when the row's data arrives after it got focus.
  final _infoPosition = ValueNotifier<(String?, int)?>(null);
  Timer? _infoDelay;
  String? _checkedPlaylistId;

  /// Channel list remembers its focused row. While the categories have
  /// focus, a new channel list must not take focus with its first row.
  bool _categoriesFocused = false;
  late final _channelScope = FocusMemoryScopeNode(
    debugLabel: 'liveChannels',
    allowAutofocus: () => !_categoriesFocused,
  );

  @override
  void dispose() {
    _infoDelay?.cancel();
    _infoPosition.dispose();
    _channelScope.dispose();
    super.dispose();
  }

  void _onChannelFocused(String? categoryId, int index) {
    _infoDelay?.cancel();
    _infoDelay = Timer(
      const Duration(milliseconds: 400),
      () => _infoPosition.value = (categoryId, index),
    );
  }

  void _play(Playlist playlist, String? categoryId, int index) {
    context.push(
      AppRoutes.livePlayer,
      extra: LivePlayerArgs(
        playlistId: playlist.id,
        categoryId: categoryId,
        index: index,
      ),
    );
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
    final playlists = ref.watch(activeProfilePlaylistsProvider);
    final playlist = ref.watch(livePlaylistSelectionProvider);

    if (!playlists.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (playlist == null) return const _NoPlaylist();

    _ensureCatalog(playlist.id);
    final status = ref.watch(liveCatalogControllerProvider(playlist.id));
    final categoryId = ref.watch(liveCategorySelectionProvider(playlist.id));
    final channels = ref
        .watch(liveChannelListProvider(playlist.id, categoryId))
        .value;
    final hasCatalog = channels != null && channels.length > 0;

    if (!hasCatalog && categoryId == null) {
      return _CatalogState(playlistId: playlist.id, status: status);
    }

    final isPhone = ScreenClass.of(context).isPhone;
    final channelList = _ChannelList(
      channels: channels,
      header: _ChannelHeader(playlist: playlist, categoryId: categoryId),
      onFocused: (index) => _onChannelFocused(categoryId, index),
      onSelect: (index) => _play(playlist, categoryId, index),
    );

    if (isPhone) return channelList;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 220,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) => _categoriesFocused = focused,
            child: ExitRight(
              onRight: _channelScope.enter,
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
        Expanded(
          child: FocusScope(
            node: _channelScope,
            child: FocusTraversalGroup(child: channelList),
          ),
        ),
        SizedBox(
          width: 280,
          child: ListenableBuilder(
            listenable: Listenable.merge([_infoPosition, channels]),
            builder: (context, _) {
              final position = _infoPosition.value;
              final channel = position == null || position.$1 != categoryId
                  ? null
                  : channels?.itemAt(position.$2);
              return channel == null
                  ? const SizedBox.shrink()
                  : _InfoPanel(channel: channel);
            },
          ),
        ),
      ],
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
        onFocus: () => selection.select(null),
      ),
      for (final category in categories)
        _CategoryTile(
          label: category.name,
          count: category.channelCount,
          selected: category.id == selectedCategoryId,
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
    this.onFocus,
    this.onSelect,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final bool selected;

  /// Categories switch the channel list as soon as they are focused, like in
  /// common IPTV players.
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

class _ChannelHeader extends ConsumerWidget {
  const _ChannelHeader({required this.playlist, required this.categoryId});

  final Playlist playlist;
  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final categories =
        ref.watch(liveCategoriesProvider(playlist.id)).value ?? const [];
    final status = ref.watch(liveCatalogControllerProvider(playlist.id));
    final title =
        categories.where((c) => c.id == categoryId).firstOrNull?.name ??
        l10n.liveAllChannels;

    final Widget heading = ScreenClass.of(context).isPhone
        ? TvFocusable(
            onSelect: () async {
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
                  .read(liveCategorySelectionProvider(playlist.id).notifier)
                  .select(chosen.isEmpty ? null : chosen);
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
          if (status is LiveCatalogLoading) ...[
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(l10n.liveUpdating, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ChannelList extends StatelessWidget {
  const _ChannelList({
    required this.channels,
    required this.header,
    required this.onFocused,
    required this.onSelect,
  });

  final PagedList<LiveChannel>? channels;
  final Widget header;
  final ValueChanged<int> onFocused;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final channels = this.channels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: channels == null
              ? const SizedBox.shrink()
              : ListenableBuilder(
                  listenable: channels,
                  builder: (context, _) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemExtent: channelRowHeight,
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels.itemAt(index);
                      return ChannelRow(
                        key: ValueKey(index),
                        channel: channel,
                        autofocus: index == 0,
                        onFocusChange: (focused) {
                          if (focused) onFocused(index);
                        },
                        onSelect: () => onSelect(index),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _InfoPanel extends ConsumerWidget {
  const _InfoPanel({required this.channel});

  final LiveChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final nowNext = ref.watch(nowNextProvider(channel));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChannelLogo(url: channel.logoUrl, size: 80),
          const SizedBox(height: 12),
          Text(
            '${channel.number}  ${channel.name}',
            style: textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (channel.archiveDays > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.liveCatchupDays(channel.archiveDays),
              style: textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          nowNext.isLoading && !nowNext.hasValue
              ? const LinearProgressIndicator(minHeight: 2)
              : NowNextView(nowNext: nowNext.value, showDescription: true),
        ],
      ),
    );
  }
}
