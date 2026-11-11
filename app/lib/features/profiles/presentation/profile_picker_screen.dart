import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../settings/application/settings_providers.dart';
import '../application/profile_actions.dart';
import '../application/profile_providers.dart';
import '../domain/profile.dart';
import 'pin_dialog.dart';
import 'profile_card.dart';

/// "Who is watching?" screen (PROF-1). In manage mode selecting a profile
/// opens its editor instead of activating it.
class ProfilePickerScreen extends ConsumerStatefulWidget {
  const ProfilePickerScreen({super.key});

  @override
  ConsumerState<ProfilePickerScreen> createState() =>
      _ProfilePickerScreenState();
}

class _ProfilePickerScreenState extends ConsumerState<ProfilePickerScreen> {
  bool _managing = false;

  Future<void> _open(Profile profile) async {
    if (_managing) {
      await context.push(AppRoutes.editProfile(profile.id));
      return;
    }

    final actions = ref.read(profileActionsProvider);
    if (profile.hasPin) {
      final l10n = AppLocalizations.of(context);
      final pin = await showPinDialog(
        context,
        title: l10n.profilePinEnter(profile.name),
        validate: (pin) async => await actions.verifyPin(profile.id, pin)
            ? null
            : l10n.profilePinWrong,
      );
      if (pin == null) return;
    }
    actions.activate(profile.id);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final activeId = ref.watch(activeProfileIdProvider);
    final defaultId = ref.watch(defaultProfileIdProvider).value;
    final focusId = activeId ?? defaultId ?? profiles.firstOrNull?.id;

    return PopScope(
      // Without an active profile there is nothing to go back to, so back
      // leaves the app. Otherwise it returns to the active profile.
      canPop: activeId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _managing
                        ? l10n.profilesManage
                        : l10n.profilesWhoIsWatching,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final profile in profiles)
                        ProfileCard(
                          key: ValueKey(profile.id),
                          label: profile.name,
                          avatar: profile.avatar,
                          autofocus: profile.id == focusId,
                          badge: _managing
                              ? Icons.edit
                              : profile.hasPin
                              ? Icons.lock
                              : null,
                          onSelect: () => _open(profile),
                        ),
                      ProfileCard(
                        label: l10n.profilesAdd,
                        icon: Icons.add,
                        onSelect: () => context.push(AppRoutes.newProfile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  TvButton(
                    label: _managing ? l10n.commonDone : l10n.profilesManage,
                    icon: _managing ? Icons.check : Icons.edit_outlined,
                    onPressed: () => setState(() => _managing = !_managing),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
