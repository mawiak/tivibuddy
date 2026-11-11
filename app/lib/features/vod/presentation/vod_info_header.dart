import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'poster_tile.dart';

/// Details of the focused title above a VOD grid: backdrop, list name,
/// title, a line of facts and the plot.
class VodInfoHeader extends StatelessWidget {
  const VodInfoHeader({
    super.key,
    required this.listTitle,
    this.title,
    this.meta,
    this.plot,
    this.backdropUrl,
  });

  final String listTitle;
  final String? title;

  /// For example year, duration, genre and rating.
  final String? meta;
  final String? plot;
  final String? backdropUrl;

  static const height = 220.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final meta = this.meta;
    final plot = this.plot;
    final backdrop = backdropUrl;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backdrop != null)
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.6,
                heightFactor: 1,
                child: ShaderMask(
                  // Fades the backdrop into the background towards the text.
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0x00FFFFFF), Color(0x99FFFFFF)],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: PosterImage(url: backdrop, width: 560),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: FractionallySizedBox(
              widthFactor: 0.62,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listTitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title ?? '',
                    style: textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (meta != null && meta.isNotEmpty)
                    Text(
                      meta,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  if (plot != null)
                    Text(
                      plot,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
