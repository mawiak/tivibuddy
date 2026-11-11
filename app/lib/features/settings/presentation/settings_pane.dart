import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_list_tile.dart';
import '../../playlists/application/playlist_actions.dart';

/// Settings section of the home screen. Each entry opens its own screen.
/// Extended in the settings milestone.
class SettingsPane extends ConsumerWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlistCount =
        ref.watch(activeProfilePlaylistsProvider).value?.length ?? 0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          l10n.navSettings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        TvListTile(
          title: l10n.settingsPlaylists,
          subtitle: l10n.settingsPlaylistsSubtitle(playlistCount),
          leading: Icons.playlist_play,
          autofocus: true,
          onSelect: () => context.push(AppRoutes.playlists),
        ),
        const SizedBox(height: 8),
        TvListTile(
          title: l10n.settingsProfiles,
          subtitle: l10n.settingsProfilesSubtitle,
          leading: Icons.people_outline,
          onSelect: () => context.go(AppRoutes.profiles),
        ),
      ],
    );
  }
}
