import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_list_tile.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../profiles/application/profile_providers.dart';
import '../../profiles/domain/profile.dart';
import '../application/settings_actions.dart';
import '../application/settings_providers.dart';

/// Settings section of the home screen, split into the active profile, this
/// device and general information (SET-1 to SET-3).
class SettingsPane extends ConsumerWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final actions = ref.read(settingsActionsProvider);
    final profile = ref.watch(activeProfileProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final settings = ref.watch(activeProfileSettingsProvider).value;
    final startProfileId = ref.watch(defaultProfileIdProvider).value;
    final playlistCount =
        ref.watch(activeProfilePlaylistsProvider).value?.length ?? 0;

    final startProfile = profiles
        .where((p) => p.id == startProfileId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.navSettings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        _SectionHeader(l10n.settingsSectionProfile(profile?.name ?? '')),
        _Entry(
          TvListTile(
            title: l10n.settingsPlaylists,
            subtitle: l10n.settingsPlaylistsSubtitle(playlistCount),
            leading: Icons.playlist_play,
            autofocus: true,
            onSelect: () => context.push(AppRoutes.playlists),
          ),
        ),
        _Entry(
          TvListTile(
            title: l10n.settingsLanguage,
            subtitle: languageLabel(context, settings?.languageCode),
            leading: Icons.translate,
            onSelect: () => _chooseLanguage(context, actions),
          ),
        ),
        _Entry(
          TvListTile(
            title: l10n.settingsResetProfile,
            leading: Icons.restart_alt,
            onSelect: () async {
              final confirmed = await showTvConfirmDialog(
                context,
                title: l10n.settingsResetProfile,
                message: l10n.settingsResetProfileMessage(profile?.name ?? ''),
                confirmLabel: l10n.settingsReset,
                destructive: true,
              );
              if (confirmed) await actions.resetProfileSettings();
            },
          ),
        ),
        _SectionHeader(l10n.settingsSectionDevice),
        _Entry(
          TvListTile(
            title: l10n.settingsStartProfile,
            subtitle: startProfile?.name ?? l10n.settingsStartProfileNone,
            leading: Icons.play_circle_outline,
            onSelect: () => _chooseStartProfile(context, actions, profiles),
          ),
        ),
        _Entry(
          TvListTile(
            title: l10n.settingsProfiles,
            subtitle: l10n.settingsProfilesSubtitle,
            leading: Icons.people_outline,
            onSelect: () => context.go(AppRoutes.profiles),
          ),
        ),
        _Entry(
          TvListTile(
            title: l10n.settingsResetDevice,
            leading: Icons.restart_alt,
            onSelect: () async {
              final confirmed = await showTvConfirmDialog(
                context,
                title: l10n.settingsResetDevice,
                message: l10n.settingsResetDeviceMessage,
                confirmLabel: l10n.settingsReset,
                destructive: true,
              );
              if (confirmed) await actions.resetDeviceSettings();
            },
          ),
        ),
        _SectionHeader(l10n.settingsSectionGeneral),
        _Entry(
          TvListTile(
            title: l10n.settingsAbout,
            leading: Icons.info_outline,
            onSelect: () => context.push(AppRoutes.about),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    SettingsActions actions,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Every ARB file becomes a supported locale, so new translations appear
    // here without code changes (I18N-2).
    final choice = await showTvChoiceDialog<String>(
      context,
      title: l10n.settingsLanguage,
      choices: [
        TvChoice(_system, l10n.settingsLanguageSystem),
        for (final locale in AppLocalizations.supportedLocales)
          TvChoice(
            locale.toLanguageTag(),
            lookupAppLocalizations(locale).languageName,
          ),
      ],
    );
    if (choice == null) return;
    await actions.setLanguage(choice == _system ? null : choice);
  }

  Future<void> _chooseStartProfile(
    BuildContext context,
    SettingsActions actions,
    List<Profile> profiles,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showTvChoiceDialog<String>(
      context,
      title: l10n.settingsStartProfile,
      choices: [
        TvChoice(_none, l10n.settingsStartProfileNone),
        for (final profile in profiles)
          TvChoice(
            profile.id,
            profile.name,
            icon: profile.hasPin ? Icons.lock : Icons.person_outline,
          ),
      ],
    );
    if (choice == null) return;
    await actions.setStartProfile(choice == _none ? null : choice);
  }

  // Dialog results use sentinels because null means "dismissed".
  static const _system = '';
  static const _none = '';
}

/// Display name of a stored language tag.
String languageLabel(BuildContext context, String? languageCode) {
  final l10n = AppLocalizations.of(context);
  if (languageCode == null) return l10n.settingsLanguageSystem;
  final locale = AppLocalizations.supportedLocales
      .where((l) => l.toLanguageTag() == languageCode)
      .firstOrNull;
  return locale == null
      ? languageCode
      : lookupAppLocalizations(locale).languageName;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: AppColors.accent),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: child);
}
