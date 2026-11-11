import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../player/presentation/playback_time.dart';
import '../../vod/presentation/poster_tile.dart';
import '../../vod/presentation/vod_player_screen.dart';
import '../application/series_actions.dart';
import '../application/series_providers.dart';
import '../domain/series.dart';

/// Details of a series with seasons and episodes (VOD-1, VOD-2, DATA-4):
/// play or resume where the profile left off, favorite, and the episodes of
/// the selected season with their progress.
class SeriesDetailScreen extends ConsumerStatefulWidget {
  const SeriesDetailScreen({super.key, required this.series});

  final Series series;

  @override
  ConsumerState<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends ConsumerState<SeriesDetailScreen> {
  /// Season whose episodes are listed; null until the user picks one, then
  /// the season of the episode "play" starts is shown.
  int? _season;

  Series get _series => widget.series;

  void _play(Episode episode, EpisodeState state) {
    final l10n = AppLocalizations.of(context);
    // The actions are read here: the player also saves when it closes, when
    // its own ref can no longer be used.
    final actions = ref.read(seriesActionsProvider);
    context.push(
      AppRoutes.vodPlayer,
      extra: VodPlayerArgs(
        title:
            '${_series.name}  ·  '
            '${l10n.seriesEpisodeCode(episode.seasonNumber, episode.episodeNumber)}'
            '  ${episode.title}',
        start: state.canResume ? state.position : null,
        resolveUrl: (ref) =>
            ref.read(episodeStreamUrlProvider(_series, episode).future),
        saveProgress: (position, duration) =>
            actions.saveEpisodeProgress(_series, episode, position, duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isPhone = ScreenClass.of(context).isPhone;
    final details = ref.watch(seriesDetailsProvider(_series));
    final info = details.value ?? SeriesDetails.empty;
    final seriesState =
        ref.watch(seriesStateProvider(_series)).value ?? SeriesState.initial;
    final episodeStates =
        ref.watch(episodeStatesProvider(_series)).value ?? const {};

    final next = nextEpisode(info.episodes, seriesState, episodeStates);
    final nextState = next == null
        ? EpisodeState.initial
        : episodeStates[next.id] ?? EpisodeState.initial;
    final season =
        _season ?? next?.seasonNumber ?? info.seasons.firstOrNull?.number;

    final meta = [
      ?_series.year,
      ?_series.genre,
      if (_series.rating case final rating?) '★ ${rating.toStringAsFixed(1)}',
    ].join('  ·  ');

    final buttons = <Widget>[
      if (next != null)
        TvButton(
          label: nextState.canResume
              ? l10n.seriesResume(
                  next.seasonNumber,
                  next.episodeNumber,
                  formatPlaybackTime(nextState.position),
                )
              : l10n.seriesPlay(next.seasonNumber, next.episodeNumber),
          icon: Icons.play_arrow,
          style: TvButtonStyle.primary,
          autofocus: true,
          onPressed: () => _play(next, nextState),
        ),
      TvButton(
        label: seriesState.favorite
            ? l10n.movieFavoriteRemove
            : l10n.movieFavoriteAdd,
        icon: seriesState.favorite ? Icons.star : Icons.star_border,
        autofocus: next == null,
        onPressed: () =>
            ref.read(seriesActionsProvider).toggleFavorite(_series),
      ),
    ];

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isPhone) ...[
          SizedBox(
            width: 120,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PosterImage(
                url: _series.coverUrl,
                width: 120,
                icon: Icons.video_library_outlined,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _series.name,
                style: textTheme.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_series.plot case final plot?) ...[
                const SizedBox(height: 8),
                Text(
                  plot,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Wrap(spacing: 12, runSpacing: 12, children: buttons),
            ],
          ),
        ),
      ],
    );

    final Widget episodesArea;
    if (details.hasError && !details.hasValue) {
      episodesArea = Center(
        child: Text(l10n.seriesDetailsFailed, style: textTheme.bodyMedium),
      );
    } else if (!details.hasValue) {
      episodesArea = const Center(child: CircularProgressIndicator());
    } else if (info.episodes.isEmpty) {
      episodesArea = Center(
        child: Text(l10n.seriesNoEpisodes, style: textTheme.bodyMedium),
      );
    } else {
      final episodeList = _EpisodeList(
        // A new season starts at its first episode.
        key: ValueKey(season),
        episodes: season == null ? info.episodes : info.episodesOf(season),
        states: episodeStates,
        onSelect: (episode) =>
            _play(episode, episodeStates[episode.id] ?? EpisodeState.initial),
      );
      final seasons = _SeasonList(
        seasons: info.seasons,
        selected: season,
        horizontal: isPhone,
        onFocus: (number) => setState(() => _season = number),
      );
      episodesArea = isPhone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 48, child: seasons),
                Expanded(child: episodeList),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 180, child: seasons),
                const SizedBox(width: 16),
                Expanded(child: episodeList),
              ],
            );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_series.backdropUrl case final backdrop?)
            Opacity(
              opacity: 0.25,
              child: PosterImage(
                url: backdrop,
                width: MediaQuery.sizeOf(context).width,
              ),
            ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isPhone ? 16 : 32,
                isPhone ? 16 : 24,
                isPhone ? 16 : 32,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: 16),
                  Expanded(child: episodesArea),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seasons of a series. Focusing a season shows its episodes, like the
/// categories of the other sections.
class _SeasonList extends StatelessWidget {
  const _SeasonList({
    required this.seasons,
    required this.selected,
    required this.horizontal,
    required this.onFocus,
  });

  final List<Season> seasons;
  final int? selected;
  final bool horizontal;
  final ValueChanged<int> onFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: seasons.length,
      itemBuilder: (context, index) {
        final season = seasons[index];
        final isSelected = season.number == selected;
        return TvFocusable(
          onFocusChange: (focused) {
            if (focused) onFocus(season.number);
          },
          onSelect: () => onFocus(season.number),
          builder: (context, focused) => Container(
            height: 44,
            margin: horizontal
                ? const EdgeInsets.only(right: 8)
                : const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: focused ? AppColors.focusFill : null,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: focused ? AppColors.focusBorder : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              season.name ?? l10n.seriesSeason(season.number),
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.accent : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

class _EpisodeList extends StatelessWidget {
  const _EpisodeList({
    super.key,
    required this.episodes,
    required this.states,
    required this.onSelect,
  });

  final List<Episode> episodes;
  final Map<int, EpisodeState> states;
  final ValueChanged<Episode> onSelect;

  static const _rowHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      itemExtent: _rowHeight,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final state = states[episode.id] ?? EpisodeState.initial;
        final progress = state.canResume ? state.progress : null;
        final duration = episode.duration;
        return TvFocusable(
          onSelect: () => onSelect(episode),
          builder: (context, focused) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: focused ? AppColors.focusFill : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: focused ? AppColors.focusBorder : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 104,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PosterImage(
                          url: episode.imageUrl,
                          width: 104,
                          icon: Icons.play_circle_outline,
                        ),
                        if (progress != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 3,
                              backgroundColor: const Color(0x99000000),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MarqueeText(
                        '${l10n.seriesEpisodeCode(episode.seasonNumber, episode.episodeNumber)}'
                        '  ${episode.title}',
                        active: focused,
                        style: textTheme.bodyMedium,
                      ),
                      if (episode.plot case final plot?)
                        Text(
                          plot,
                          style: textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (duration != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    l10n.guideMinutes(duration.inMinutes),
                    style: textTheme.bodySmall,
                  ),
                ],
                if (state.watched) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
