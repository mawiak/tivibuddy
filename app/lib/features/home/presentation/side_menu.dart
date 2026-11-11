import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_focusable.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/profile_avatar_view.dart';
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
    this.profile,
    this.onProfileSelect,
    this.onFocusChange,
    this.onExitRight,
  });

  static const collapsedWidth = 64.0;
  static const expandedWidth = 220.0;

  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;
  final Map<HomeSection, FocusNode> itemFocusNodes;

  /// Active profile, shown on top. Selecting it opens the profile picker.
  final Profile? profile;
  final VoidCallback? onProfileSelect;
  final ValueChanged<bool>? onFocusChange;

  /// Called when the user presses right inside the menu. The owner moves
  /// focus into the content.
  final VoidCallback? onExitRight;

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
    final profile = widget.profile;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      onKeyEvent: (node, event) {
        final onExitRight = widget.onExitRight;
        if (onExitRight == null ||
            event is! KeyDownEvent ||
            event.logicalKey != LogicalKeyboardKey.arrowRight) {
          return KeyEventResult.ignored;
        }
        onExitRight();
        return KeyEventResult.handled;
      },
      child: FocusTraversalGroup(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: _expanded ? SideMenu.expandedWidth : SideMenu.collapsedWidth,
          color: AppColors.rail,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            children: [
              if (profile != null) ...[
                _SideMenuItem(
                  leading: ProfileAvatarView(avatar: profile.avatar, size: 24),
                  label: profile.name,
                  tooltip: l10n.profilesSwitch,
                  expanded: _expanded,
                  onSelect: widget.onProfileSelect ?? () {},
                ),
                const SizedBox(height: 16),
              ],
              for (final section in HomeSection.values)
                _SideMenuItem(
                  leading: Icon(
                    section.icon,
                    size: 24,
                    color: section == widget.selected ? AppColors.accent : null,
                  ),
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
    required this.leading,
    required this.label,
    required this.expanded,
    required this.onSelect,
    this.selected = false,
    this.tooltip,
    this.focusNode,
  });

  final Widget leading;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onSelect;
  final String? tooltip;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final item = TvFocusable(
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
          child: IconTheme.merge(
            data: IconThemeData(color: color),
            child: Row(
              children: [
                SizedBox(width: 24, child: Center(child: leading)),
                // The label appears while the menu is still animating from
                // its collapsed width, so the gap must shrink with the free
                // space.
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
          ),
        );
      },
    );
    return tooltip == null ? item : Semantics(hint: tooltip, child: item);
  }
}
