import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_dialogs.dart';
import '../../../shared/widgets/tv_list_tile.dart';
import '../../diagnostics/application/log_report_actions.dart';
import '../../diagnostics/presentation/send_log_dialog.dart';
import '../../player/application/player_settings_providers.dart';
import '../../player/domain/player_settings.dart';
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
    final guideDays = ref.watch(guideDaysProvider).value ?? defaultGuideDays;
    final player = ref.watch(playerSettingsControllerProvider);
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
            title: l10n.settingsGuideDays,
            subtitle: guideDaysLabel(l10n, guideDays),
            leading: Icons.view_timeline_outlined,
            onSelect: () => _chooseGuideDays(context, actions, guideDays),
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
        _SectionHeader(l10n.settingsSectionPlayer),
        _Entry(
          TvListTile(
            title: l10n.settingsDecoder,
            subtitle: decoderLabel(l10n, player.decoder),
            leading: Icons.memory,
            onSelect: () => _chooseDecoder(context, ref),
          ),
        ),
        _Entry(
          TvListTile(
            title: l10n.settingsPassthrough,
            subtitle: player.passthrough.isEmpty
                ? l10n.settingsPassthroughOff
                : [
                    for (final format in AudioPassthrough.values)
                      if (player.passthrough.contains(format))
                        audioFormatLabel(l10n, format),
                  ].join(', '),
            leading: Icons.surround_sound_outlined,
            onSelect: () => _choosePassthrough(context, ref, player),
          ),
        ),
        _SectionHeader(l10n.settingsSectionGeneral),
        if (ref.read(logReportActionsProvider).canSend)
          _Entry(
            TvListTile(
              title: l10n.settingsSendLog,
              subtitle: l10n.settingsSendLogSubtitle,
              leading: Icons.bug_report_outlined,
              onSelect: () => showSendLogDialog(context),
            ),
          ),
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

  Future<void> _chooseGuideDays(
    BuildContext context,
    SettingsActions actions,
    int current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showTvChoiceDialog<int>(
      context,
      title: l10n.settingsGuideDays,
      choices: [
        for (final days in guideDayChoices)
          TvChoice(days, guideDaysLabel(l10n, days)),
      ],
    );
    if (choice != null && choice != current) {
      await actions.setGuideDays(choice);
    }
  }

  Future<void> _chooseDecoder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showTvChoiceDialog<VideoDecoder>(
      context,
      title: l10n.settingsDecoder,
      message: l10n.settingsDecoderHint,
      choices: [
        for (final decoder in VideoDecoder.values)
          TvChoice(decoder, decoderLabel(l10n, decoder)),
      ],
    );
    if (choice == null) return;
    await ref
        .read(playerSettingsControllerProvider.notifier)
        .setDecoder(choice);
  }

  Future<void> _choosePassthrough(
    BuildContext context,
    WidgetRef ref,
    PlayerSettings current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(playerSettingsControllerProvider.notifier);
    // Only formats the output accepts are passed through; the user sees
    // which, so a silent receiver is not a riddle.
    final support = await ref.read(passthroughSupportProvider.future);
    if (!context.mounted) return;
    final accepted = support?.formats;
    final acceptedNote = switch (accepted) {
      null => null,
      final formats when formats.isEmpty => l10n.settingsPassthroughNone,
      final formats => l10n.settingsPassthroughAccepted(
        [
          for (final format in AudioPassthrough.values)
            if (formats.contains(format)) audioFormatLabel(l10n, format),
        ].join(', '),
      ),
    };
    await showTvToggleDialog<AudioPassthrough>(
      context,
      title: l10n.settingsPassthrough,
      message: [l10n.settingsPassthroughHint, ?acceptedNote].join('\n\n'),
      choices: [
        for (final format in AudioPassthrough.values)
          TvChoice(format, audioFormatLabel(l10n, format)),
      ],
      selected: current.passthrough,
      onChanged: (formats) => unawaited(controller.setPassthrough(formats)),
    );
  }

  // Dialog results use sentinels because null means "dismissed".
  static const _system = '';
  static const _none = '';
}

String guideDaysLabel(AppLocalizations l10n, int days) =>
    days == 0 ? l10n.settingsGuideDaysOff : l10n.settingsGuideDaysValue(days);

String decoderLabel(AppLocalizations l10n, VideoDecoder decoder) =>
    switch (decoder) {
      VideoDecoder.hardware => l10n.settingsDecoderHardware,
      VideoDecoder.hardwareCopy => l10n.settingsDecoderHardwareCopy,
      VideoDecoder.software => l10n.settingsDecoderSoftware,
    };

String audioFormatLabel(AppLocalizations l10n, AudioPassthrough format) =>
    switch (format) {
      AudioPassthrough.ac3 => l10n.audioFormatAc3,
      AudioPassthrough.eac3 => l10n.audioFormatEac3,
      AudioPassthrough.dts => l10n.audioFormatDts,
      AudioPassthrough.dtsHd => l10n.audioFormatDtsHd,
      AudioPassthrough.trueHd => l10n.audioFormatTrueHd,
    };

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
