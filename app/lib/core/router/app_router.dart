import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/home_shell.dart';
import '../../features/profiles/application/profile_providers.dart';
import '../../features/profiles/presentation/profile_edit_screen.dart';
import '../../features/profiles/presentation/profile_picker_screen.dart';
import '../../features/startup/application/app_startup.dart';
import '../../features/startup/presentation/startup_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Re-evaluates the redirect whenever startup or profile state changes.
  final refresh = ValueNotifier(0);
  ref
    ..listen(appStartupProvider, (_, _) => refresh.value++)
    ..listen(profilesProvider, (_, _) => refresh.value++)
    ..listen(activeProfileIdProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.startup,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      startupDone: ref.read(appStartupProvider).hasValue,
      profileCount: ref.read(profilesProvider).value?.length ?? 0,
      hasActiveProfile: ref.read(activeProfileProvider) != null,
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
String? resolveRedirect({
  required String location,
  required bool startupDone,
  required int profileCount,
  required bool hasActiveProfile,
}) {
  if (!startupDone) {
    return location == AppRoutes.startup ? null : AppRoutes.startup;
  }
  // First start: the user has to create a profile (PROF-2).
  if (profileCount == 0) {
    return location == AppRoutes.newProfile ? null : AppRoutes.newProfile;
  }
  final inProfiles = location.startsWith(AppRoutes.profiles);
  if (!hasActiveProfile && !inProfiles) return AppRoutes.profiles;
  if (location == AppRoutes.startup) return AppRoutes.home;
  return null;
}
