import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/screen_class.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../profiles/application/profile_providers.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/profile_avatar_view.dart';
import '../application/home_section.dart';
import 'home_section_display.dart';
import 'section_placeholder.dart';
import 'side_menu.dart';

/// Main screen: navigation menu plus the content of the selected section.
///
/// Back key behaviour on TV follows the common IPTV player pattern: back from
/// the content moves focus to the menu, back from the menu leaves the app.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final Map<HomeSection, FocusNode> _menuFocusNodes = {
    for (final section in HomeSection.values)
      section: FocusNode(debugLabel: 'menu.${section.name}'),
  };
  bool _menuHasFocus = false;

  @override
  void dispose() {
    for (final node in _menuFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(HomeSection section) {
    ref.read(selectedHomeSectionProvider.notifier).select(section);
  }

  void _focusMenu() {
    final selected = ref.read(selectedHomeSectionProvider);
    _menuFocusNodes[selected]?.requestFocus();
  }

  void _switchProfile() => context.go(AppRoutes.profiles);

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedHomeSectionProvider);
    final profile = ref.watch(activeProfileProvider);
    final content = SectionPlaceholder(
      key: ValueKey(selected),
      section: selected,
    );

    if (ScreenClass.of(context).isPhone) {
      return _PhoneLayout(
        selected: selected,
        onSelect: _select,
        profile: profile,
        onProfileSelect: _switchProfile,
        content: content,
      );
    }

    return PopScope(
      canPop: _menuHasFocus,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _focusMenu();
      },
      child: Scaffold(
        body: Row(
          children: [
            SideMenu(
              selected: selected,
              onSelect: _select,
              itemFocusNodes: _menuFocusNodes,
              profile: profile,
              onProfileSelect: _switchProfile,
              onFocusChange: (hasFocus) =>
                  setState(() => _menuHasFocus = hasFocus),
            ),
            Expanded(child: FocusTraversalGroup(child: content)),
          ],
        ),
      ),
    );
  }
}

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({
    required this.selected,
    required this.onSelect,
    required this.onProfileSelect,
    required this.content,
    this.profile,
  });

  final HomeSection selected;
  final ValueChanged<HomeSection> onSelect;
  final Profile? profile;
  final VoidCallback onProfileSelect;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = this.profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (profile != null)
            IconButton(
              tooltip: l10n.profilesSwitch,
              onPressed: onProfileSelect,
              icon: ProfileAvatarView(avatar: profile.avatar, size: 32),
            ),
        ],
      ),
      body: SafeArea(child: content),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected.index,
        onDestinationSelected: (index) => onSelect(HomeSection.values[index]),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          for (final section in HomeSection.values)
            NavigationDestination(
              icon: Icon(section.icon),
              label: section.label(l10n),
            ),
        ],
      ),
    );
  }
}
