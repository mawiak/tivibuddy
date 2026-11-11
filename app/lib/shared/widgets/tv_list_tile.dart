import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'marquee_text.dart';
import 'tv_focusable.dart';

/// Focusable row with a title, optional subtitle and trailing widget. Used
/// for settings-like lists.
class TvListTile extends StatelessWidget {
  const TvListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onSelect,
    this.autofocus = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onSelect;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onSelect,
      builder: (context, focused) => Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            if (leading != null) ...[
              Icon(leading, color: AppColors.textSecondary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MarqueeText(
                    title,
                    active: focused,
                    style: textTheme.titleMedium,
                  ),
                  if (subtitle != null)
                    MarqueeText(
                      subtitle!,
                      active: focused,
                      style: textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
  }
}

/// [TvListTile] with an on/off switch toggled by select.
class TvSwitchTile extends StatelessWidget {
  const TvSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TvListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      onSelect: () => onChanged(!value),
      trailing: ExcludeFocus(
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
