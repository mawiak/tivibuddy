import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/live_tv/presentation/live_player_screen.dart';
import '../../features/playlists/presentation/playlist_edit_screen.dart';
import '../../features/playlists/presentation/playlists_screen.dart';
import '../../features/profiles/application/profile_providers.dart';
import '../../features/profiles/presentation/profile_edit_screen.dart';
import '../../features/profiles/presentation/profile_picker_screen.dart';
import '../../features/startup/application/app_startup.dart';
import '../../features/startup/presentation/startup_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

typedef RedirectInputs = ({
  bool startupDone,
  bool hasProfiles,
  bool hasActiveProfile,
});

/// Only the facts the redirect depends on. Refreshing the router on every
/// profile change (for example a rename) would race with screens popping
/// themselves and restore the popped route.
@Riverpod(keepAlive: true)
RedirectInputs redirectInputs(Ref ref) => (
  startupDone: ref.watch(appStartupProvider).hasValue,
  hasProfiles: ref.watch(profilesProvider).value?.isNotEmpty ?? false,
  hasActiveProfile: ref.watch(activeProfileProvider) != null,
);

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier(0);
  ref.listen(redirectInputsProvider, (previous, next) {
    if (previous != next) refresh.value++;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.startup,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      state.matchedLocation,
      ref.read(redirectInputsProvider),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfilePickerScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) =>
                ProfileEditScreen(profileId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.livePlayer,
        builder: (context, state) =>
            LivePlayerScreen(args: state.extra! as LivePlayerArgs),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.playlists,
        builder: (context, state) => const PlaylistsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const PlaylistEditScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) =>
                PlaylistEditScreen(playlistId: state.pathParameters['id']),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}

/// Navigation rules for app start and profile state. Returns the location to
/// redirect to, or null to stay.
@visibleForTesting
String? resolveRedirect(String location, RedirectInputs inputs) {
  final (:startupDone, :hasProfiles, :hasActiveProfile) = inputs;
  if (!startupDone) {
    return location == AppRoutes.startup ? null : AppRoutes.startup;
  }
  // First start: the user has to create a profile (PROF-2).
  if (!hasProfiles) {
    return location == AppRoutes.newProfile ? null : AppRoutes.newProfile;
  }
  final inProfiles = location.startsWith(AppRoutes.profiles);
  if (!hasActiveProfile && !inProfiles) return AppRoutes.profiles;
  if (location == AppRoutes.startup) return AppRoutes.home;
  return null;
}
