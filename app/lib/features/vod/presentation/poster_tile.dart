import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/marquee_text.dart';
import '../../../shared/widgets/tv_focusable.dart';

/// Poster or backdrop image, decoded at display size (RES-2).
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    required this.width,
    this.icon = Icons.movie_outlined,
  });

  final String? url;
  final double width;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final fallback = ColoredBox(
      color: AppColors.surfaceRaised,
      child: Center(child: Icon(icon, color: AppColors.textSecondary)),
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

/// A poster in a VOD grid with its title below and marks for progress,
/// watched and favorite.
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.onSelect,
    this.onFocusChange,
    this.autofocus = false,
    this.progress,
    this.watched = false,
    this.favorite = false,
    this.icon = Icons.movie_outlined,
  });

  final String title;
  final String? posterUrl;
  final VoidCallback? onSelect;

  /// Called with the focus state and the tile's context, for example to
  /// scroll it into a position.
  final void Function(bool focused, BuildContext context)? onFocusChange;
  final bool autofocus;

  /// Progress between 0 and 1 of a started item.
  final double? progress;
  final bool watched;
  final bool favorite;
  final IconData icon;

  static const _titleHeight = 30.0;

  /// Height of a grid cell for a poster [width] wide (2:3 plus title).
  static double extentFor(double width) => width * 1.5 + _titleHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = this.progress;
    final onFocusChange = this.onFocusChange;

    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      onFocusChange: onFocusChange == null
          ? null
          : (focused) => onFocusChange(focused, context),
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
                        url: posterUrl,
                        width: constraints.maxWidth,
                        icon: icon,
                      ),
                      if (favorite)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.star,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ),
                      if (watched)
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
                  title,
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
