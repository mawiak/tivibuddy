import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../player/presentation/playback_time.dart';
import '../application/movie_actions.dart';
import '../application/movie_providers.dart';
import '../domain/movie.dart';
import 'movie_poster.dart';
import 'vod_player_screen.dart';

/// Details of a movie with play, resume, favorite and watched actions
/// (VOD-2, DATA-4).
class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final details = ref.watch(movieDetailsProvider(movie));
    final info = details.value ?? MovieDetails.empty;
    final state = ref.watch(movieStateProvider(movie)).value;
    final actions = ref.read(movieActionsProvider);
    final isPhone = ScreenClass.of(context).isPhone;

    void play({Duration? start}) => context.push(
      AppRoutes.vodPlayer,
      extra: VodPlayerArgs(movie: movie, start: start),
    );

    final rating = info.rating ?? movie.rating;
    final duration = info.duration;
    final meta = [
      ?info.year,
      if (duration != null) l10n.guideMinutes(duration.inMinutes),
      ?info.genre,
      if (rating != null) '★ ${rating.toStringAsFixed(1)}',
      if (state?.watched ?? false) l10n.movieWatched,
    ].join('  ·  ');

    final canResume = state?.canResume ?? false;
    final buttons = <Widget>[
      if (canResume) ...[
        TvButton(
          label: l10n.movieResume(formatPlaybackTime(state!.position)),
          icon: Icons.play_arrow,
          style: TvButtonStyle.primary,
          autofocus: true,
          onPressed: () => play(start: state.position),
        ),
        TvButton(
          label: l10n.movieStartOver,
          icon: Icons.replay,
          onPressed: play,
        ),
      ] else
        TvButton(
          label: l10n.moviePlay,
          icon: Icons.play_arrow,
          style: TvButtonStyle.primary,
          autofocus: true,
          onPressed: play,
        ),
      TvButton(
        label: (state?.favorite ?? false)
            ? l10n.movieFavoriteRemove
            : l10n.movieFavoriteAdd,
        icon: (state?.favorite ?? false) ? Icons.star : Icons.star_border,
        onPressed: () => actions.toggleFavorite(movie),
      ),
      TvButton(
        label: (state?.watched ?? false)
            ? l10n.movieMarkUnwatched
            : l10n.movieMarkWatched,
        icon: Icons.check,
        onPressed: () =>
            actions.setWatched(movie, watched: !(state?.watched ?? false)),
      ),
    ];

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movie.name,
          style: textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (meta.isNotEmpty)
          Text(
            meta,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: 16),
        if (details.isLoading && !details.hasValue)
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (info.plot case final plot?)
          Text(
            plot,
            style: textTheme.bodyMedium,
            maxLines: isPhone ? 8 : 5,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 12),
        if (info.director case final director?)
          Text(
            l10n.movieDirector(director),
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (info.cast case final cast?)
          Text(
            l10n.movieCast(cast),
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 24),
        Wrap(spacing: 12, runSpacing: 12, children: buttons),
      ],
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (info.backdropUrl case final backdrop?)
            Opacity(
              opacity: 0.35,
              child: PosterImage(
                url: backdrop,
                width: MediaQuery.sizeOf(context).width,
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Color(0x660D1117)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isPhone ? 16 : 40),
              child: isPhone
                  ? text
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 300,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: PosterImage(
                              url: info.posterUrl ?? movie.posterUrl,
                              width: 200,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(child: text),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
