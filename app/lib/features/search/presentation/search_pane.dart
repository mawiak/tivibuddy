import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../../shared/widgets/tv_text_field.dart';
import '../../live_tv/application/live_catalog_controller.dart';
import '../../live_tv/application/live_tv_providers.dart';
import '../../live_tv/data/live_tv_data_providers.dart';
import '../../live_tv/domain/live_channel.dart';
import '../../live_tv/presentation/channel_widgets.dart';
import '../../live_tv/presentation/live_player_screen.dart';
import '../../movies/application/movie_catalog_controller.dart';
import '../../movies/domain/movie.dart';
import '../../movies/presentation/movie_poster.dart';
import '../../series/application/series_catalog_controller.dart';
import '../../series/domain/series.dart';
import '../../vod/presentation/poster_tile.dart';
import '../application/search_providers.dart';

/// Search section of the home screen (VOD-1): one query over the movies,
/// series and channels of the selected playlist, shown in one row per kind.
class SearchPane extends ConsumerStatefulWidget {
  const SearchPane({super.key});

  @override
  ConsumerState<SearchPane> createState() => _SearchPaneState();
}

class _SearchPaneState extends ConsumerState<SearchPane> {
  late final _controller = TextEditingController(
    text: ref.read(searchQueryProvider),
  );
  Timer? _debounce;
  String? _checkedPlaylistId;

  /// Loads missing or outdated catalogs once per playlist, so the search
  /// also covers sections that were never opened.
  void _ensureCatalogs(String playlistId) {
    if (_checkedPlaylistId == playlistId) return;
    _checkedPlaylistId = playlistId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(liveCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
      ref
          .read(movieCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
      ref
          .read(seriesCatalogControllerProvider(playlistId).notifier)
          .ensureFresh();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Searches once typing paused, so not every letter queries the database.
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(searchQueryProvider.notifier).set(text),
    );
  }

  Future<void> _playChannel(LiveChannel channel) async {
    // The player zaps through all channels, starting at this one.
    final index = await ref.read(liveTvRepositoryProvider).indexOf(channel);
    if (!mounted) return;
    await context.push(
      AppRoutes.livePlayer,
      extra: LivePlayerArgs(
        playlistId: channel.playlistId,
        categoryId: null,
        index: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final playlist = ref.watch(livePlaylistSelectionProvider);
    final query = ref.watch(searchQueryProvider);
    if (playlist != null) _ensureCatalogs(playlist.id);
    final searching = playlist != null && query.length >= searchMinLength;

    final channels = searching
        ? ref.watch(channelSearchProvider(playlist.id, query)).value
        : null;
    final movies = searching
        ? ref.watch(movieSearchProvider(playlist.id, query)).value
        : null;
    final series = searching
        ? ref.watch(seriesSearchProvider(playlist.id, query)).value
        : null;
    final loaded = channels != null && movies != null && series != null;
    final empty =
        loaded && channels.isEmpty && movies.isEmpty && series.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        TvTextField(
          controller: _controller,
          label: l10n.searchLabel,
          helperText: l10n.searchHint,
          onChanged: _onChanged,
          onSubmitted: (text) =>
              ref.read(searchQueryProvider.notifier).set(text),
        ),
        const SizedBox(height: 16),
        if (searching && !loaded)
          const Center(child: CircularProgressIndicator())
        else if (empty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              l10n.searchNoResults(query),
              style: textTheme.bodyMedium,
            ),
          ),
        if (movies != null && movies.isNotEmpty)
          _ResultRow(
            title: l10n.navMovies,
            height: PosterTile.extentFor(_posterWidth),
            itemWidth: _posterWidth,
            count: movies.length,
            itemBuilder: (context, index) => _MovieResult(movie: movies[index]),
          ),
        if (series != null && series.isNotEmpty)
          _ResultRow(
            title: l10n.navSeries,
            height: PosterTile.extentFor(_posterWidth),
            itemWidth: _posterWidth,
            count: series.length,
            itemBuilder: (context, index) =>
                _SeriesResult(series: series[index]),
          ),
        if (channels != null && channels.isNotEmpty)
          _ResultRow(
            title: l10n.playerChannelList,
            height: 88,
            itemWidth: 220,
            count: channels.length,
            itemBuilder: (context, index) => _ChannelResult(
              channel: channels[index],
              onSelect: () => _playChannel(channels[index]),
            ),
          ),
      ],
    );
  }

  static const _posterWidth = 110.0;
}

/// A titled horizontal row of results.
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.title,
    required this.height,
    required this.itemWidth,
    required this.count,
    required this.itemBuilder,
  });

  final String title;
  final double height;
  final double itemWidth;
  final int count;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title  ($count)', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: itemWidth,
                child: itemBuilder(context, index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelResult extends StatelessWidget {
  const _ChannelResult({required this.channel, required this.onSelect});

  final LiveChannel channel;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      onSelect: onSelect,
      builder: (context, focused) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: focused ? AppColors.focusFill : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ChannelLogo(url: channel.logoUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${channel.number}', style: textTheme.bodySmall),
                  MarqueeText(
                    channel.name,
                    active: focused,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieResult extends StatelessWidget {
  const _MovieResult({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) => MoviePoster(
    movie: movie,
    onSelect: () => context.push(AppRoutes.movieDetail, extra: movie),
  );
}

class _SeriesResult extends StatelessWidget {
  const _SeriesResult({required this.series});

  final Series series;

  @override
  Widget build(BuildContext context) => PosterTile(
    title: series.name,
    posterUrl: series.coverUrl,
    icon: Icons.video_library_outlined,
    onSelect: () => context.push(AppRoutes.seriesDetail, extra: series),
  );
}
