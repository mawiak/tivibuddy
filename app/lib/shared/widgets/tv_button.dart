import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'tv_focusable.dart';

enum TvButtonStyle { primary, secondary, danger }

class TvButton extends StatelessWidget {
  const TvButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = TvButtonStyle.secondary,
    this.autofocus = false,
    this.focusNode,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TvButtonStyle style;
  final bool autofocus;
  final FocusNode? focusNode;

  Color get _baseColor => switch (style) {
    TvButtonStyle.primary => AppColors.accent,
    TvButtonStyle.secondary => AppColors.surfaceRaised,
    TvButtonStyle.danger => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TvFocusable(
      autofocus: autofocus,
      focusNode: focusNode,
      onSelect: onPressed,
      builder: (context, focused) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: enabled ? _baseColor : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focused ? AppColors.focusBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
