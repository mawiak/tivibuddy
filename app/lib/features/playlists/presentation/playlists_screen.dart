import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/tv_button.dart';
import '../../../shared/widgets/tv_list_tile.dart';
import '../../profiles/application/profile_providers.dart';
import '../application/playlist_actions.dart';
import 'account_info_text.dart';

/// Playlists of the active profile (PL-1).
class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(activeProfileProvider);
    final playlists = ref.watch(activeProfilePlaylistsProvider).value ?? [];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.playlistsTitle(profile?.name ?? ''),
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TvButton(
                    label: l10n.playlistAdd,
                    icon: Icons.add,
                    style: TvButtonStyle.primary,
                    autofocus: playlists.isEmpty,
                    onPressed: () => context.push(AppRoutes.newPlaylist),
                  ),
                ),
                const SizedBox(height: 16),
                if (playlists.isEmpty)
                  Text(l10n.playlistsEmpty, style: textTheme.bodyMedium),
                for (final (index, playlist) in playlists.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TvListTile(
                      key: ValueKey(playlist.id),
                      title: playlist.name,
                      subtitle:
                          '${playlist.username} @ '
                          '${Uri.parse(playlist.serverUrl).host}  ·  '
                          '${describeAccount(context, playlist.account)}',
                      leading: Icons.playlist_play,
                      autofocus: index == 0,
                      trailing: const Icon(Icons.chevron_right),
                      onSelect: () =>
                          context.push(AppRoutes.editPlaylist(playlist.id)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
