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
import '../../vod/presentation/poster_tile.dart';
import '../../vod/presentation/vod_browser.dart';
import '../../vod/presentation/vod_info_header.dart';
import '../application/series_catalog_controller.dart';
import '../application/series_providers.dart';
import '../domain/series.dart';
import '../domain/series_repository.dart';

/// Series section of the home screen (VOD-1): categories and poster grid,
/// see [VodBrowser].
class SeriesPane extends ConsumerStatefulWidget {
  const SeriesPane({super.key});

  @override
  ConsumerState<SeriesPane> createState() => _SeriesPaneState();
}

class _SeriesPaneState extends ConsumerState<SeriesPane> {
  String? _checkedPlaylistId;

  /// Loads the catalog once per playlist when it is missing or outdated.
  void _ensureCatalog(String playlistId) {
    if (_checkedPlaylistId == playlistId) return;
    _checkedPlaylistId = playlistId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(seriesCatalogControllerProvider(playlistId).notifier)
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
      return NoPlaylistView(message: l10n.seriesNoPlaylistMessage);
    }
    if (playlist != null) _ensureCatalog(playlist.id);

    final status = playlist == null
        ? const SeriesCatalogIdle()
        : ref.watch(seriesCatalogControllerProvider(playlist.id));
    final filter = playlist == null
        ? VodFilter.all
        : ref.watch(seriesFilterSelectionProvider(playlist.id));
    final series = playlist == null
        ? null
        : ref.watch(seriesListProvider(playlist.id, filter)).value;
    // Whether there is a catalog at all, independent of the selected list.
    final allSeries = playlist == null
        ? null
        : ref.watch(seriesListProvider(playlist.id, VodFilter.all)).value;
    final categories = playlist == null
        ? const <SeriesCategory>[]
        : ref.watch(seriesCategoriesProvider(playlist.id)).value ?? const [];

    void refresh() => ref
        .read(seriesCatalogControllerProvider(playlist!.id).notifier)
        .refresh();
    String label(VodFilter filter) => switch (filter.list) {
      VodList.all => l10n.seriesAll,
      VodList.favorites => l10n.moviesFavorites,
      VodList.continueWatching => l10n.moviesContinue,
      null =>
        categories.where((c) => c.id == filter.categoryId).firstOrNull?.name ??
            l10n.seriesAll,
    };

    return VodBrowser<Series>(
      // Nothing focusable while the list opens: a button shown only for a
      // moment would take the focus with it when it disappears.
      loading: playlist == null || allSeries == null,
      emptyView: allSeries != null && allSeries.length == 0
          ? CatalogStateView(
              loadedText: switch (status) {
                SeriesCatalogLoading(:final seriesLoaded) =>
                  l10n.seriesLoadingCount(seriesLoaded),
                _ => null,
              },
              failure: switch (status) {
                SeriesCatalogFailed(:final reason) => reason,
                _ => null,
              },
              loadingTitle: l10n.seriesLoading,
              emptyText: l10n.seriesNone,
              refreshLabel: l10n.seriesRefresh,
              onRetry: refresh,
            )
          : null,
      items: series,
      listKey: filter,
      listTitle: label(filter),
      updating: status is SeriesCatalogLoading,
      updatingLabel: l10n.seriesUpdating,
      entries: [
        if (playlist != null && (playlists.value?.length ?? 0) > 1)
          VodCategoryEntry.action(
            label: playlist.name,
            icon: Icons.playlist_play,
            onSelect: () => _choosePlaylist(playlists.value!),
          ),
        for (final list in const [
          VodFilter.list(VodList.continueWatching),
          VodFilter.list(VodList.favorites),
          VodFilter.all,
        ])
          VodCategoryEntry.list(key: list, label: label(list)),
        for (final category in categories)
          VodCategoryEntry.list(
            key: VodFilter.category(category.id),
            label: category.name,
            count: category.seriesCount,
          ),
        VodCategoryEntry.action(
          label: status is SeriesCatalogLoading
              ? l10n.seriesUpdating
              : l10n.seriesRefresh,
          icon: Icons.refresh,
          onSelect: refresh,
        ),
      ],
      onListFocused: (key) => ref
          .read(seriesFilterSelectionProvider(playlist!.id).notifier)
          .select(key as VodFilter),
      tileBuilder:
          (context, item, index, {required autofocus, onFocusChange}) =>
              _SeriesPoster(
                series: item,
                autofocus: autofocus,
                onFocusChange: onFocusChange,
              ),
      // The provider list already contains the details, so no request is
      // needed here.
      infoBuilder: (context, item) => VodInfoHeader(
        listTitle: label(filter),
        title: item?.name,
        meta: item == null
            ? null
            : [
                ?item.year,
                ?item.genre,
                if (item.rating case final rating?)
                  '★ ${rating.toStringAsFixed(1)}',
              ].join('  ·  '),
        plot: item?.plot,
        backdropUrl: item?.backdropUrl,
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

/// A series in the grid with the favorite mark of the active profile.
class _SeriesPoster extends ConsumerWidget {
  const _SeriesPoster({
    required this.series,
    required this.autofocus,
    this.onFocusChange,
  });

  final Series? series;
  final bool autofocus;
  final void Function(bool focused, BuildContext context)? onFocusChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = this.series;
    final state = series == null
        ? SeriesState.initial
        : ref.watch(seriesStateProvider(series)).value ?? SeriesState.initial;
    return PosterTile(
      title: series?.name ?? '',
      posterUrl: series?.coverUrl,
      icon: Icons.video_library_outlined,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      favorite: state.favorite,
      onSelect: series == null
          ? null
          : () => context.push(AppRoutes.seriesDetail, extra: series),
    );
  }
}
