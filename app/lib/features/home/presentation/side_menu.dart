import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../application/home_section.dart';
import 'home_section_display.dart';

/// Left navigation menu. Collapsed to icons while the content has focus and
/// expanded with labels while the menu itself has focus.
class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.itemFocusNodes,
    this.onFocusChange,
  });

  static const collapsedWidth = 64.0;
  static const expandedWidth = 220.0;

  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;
  final Map<HomeSection, FocusNode> itemFocusNodes;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _expanded = false;

  void _handleFocusChange(bool hasFocus) {
    setState(() => _expanded = hasFocus);
    widget.onFocusChange?.call(hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: FocusTraversalGroup(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: _expanded ? SideMenu.expandedWidth : SideMenu.collapsedWidth,
          color: AppColors.rail,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            children: [
              for (final section in HomeSection.values)
                _SideMenuItem(
                  icon: section.icon,
                  label: section.label(l10n),
                  selected: section == widget.selected,
                  expanded: _expanded,
                  focusNode: widget.itemFocusNodes[section],
                  onSelect: () => widget.onSelect(section),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideMenuItem extends StatelessWidget {
  const _SideMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onSelect,
    this.focusNode,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onSelect;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      focusNode: focusNode,
      onSelect: onSelect,
      builder: (context, focused) {
        final color = selected || focused
            ? AppColors.textPrimary
            : AppColors.textSecondary;
        return Container(
          height: 48,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: focused ? AppColors.focusFill : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.accent : color, size: 24),
              // The label appears while the menu is still animating from its
              // collapsed width, so the gap must shrink with the free space.
              if (expanded)
                Expanded(
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: color),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
