import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../application/movie_providers.dart';
import '../domain/movie.dart';

/// Poster image of a movie, decoded at display size (RES-2).
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url, required this.width});

  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    const fallback = ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(
        child: Icon(Icons.movie_outlined, color: AppColors.textSecondary),
      ),
    );
    if (url == null) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// A movie in the grid: poster with progress, watched and favorite marks,
/// and its title below. [movie] is null while its page loads.
class MoviePoster extends ConsumerWidget {
  const MoviePoster({
    super.key,
    required this.movie,
    required this.onSelect,
    this.onFocusChange,
    this.autofocus = false,
  });

  final Movie? movie;
  final VoidCallback? onSelect;

  /// Called with the focus state and the poster's context, for example to
  /// scroll it into a position.
  final void Function(bool focused, BuildContext context)? onFocusChange;
  final bool autofocus;

  static const _titleHeight = 30.0;

  /// Height of a grid cell for a poster [width] wide (2:3 plus title).
  static double extentFor(double width) => width * 1.5 + _titleHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = this.movie;
    final textTheme = Theme.of(context).textTheme;
    final state = movie == null
        ? MovieState.initial
        : ref.watch(movieStateProvider(movie)).value ?? MovieState.initial;
    final progress = state.canResume ? state.progress : null;

    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      onFocusChange: onFocusChange == null
          ? null
          : (focused) => onFocusChange!(focused, context),
      builder: (context, focused) => LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: focused ? AppColors.focusBorder : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(
                        url: movie?.posterUrl,
                        width: constraints.maxWidth,
                      ),
                      if (state.favorite)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.star,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                      if (state.watched)
                        const Positioned(
                          top: 4,
                          left: 4,
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: AppColors.success,
                          ),
                        ),
                      if (progress != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: const Color(0x99000000),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _titleHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: MarqueeText(
                  movie?.name ?? '',
                  active: focused,
                  style: textTheme.bodySmall?.copyWith(
                    color: focused ? AppColors.textPrimary : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
