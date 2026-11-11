import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/core/router/app_router.dart';
import 'package:tivibuddy/core/router/app_routes.dart';

String? redirect(
  String location, {
  bool startupDone = true,
  int profiles = 1,
  bool active = false,
}) => resolveRedirect(location, (
  startupDone: startupDone,
  hasProfiles: profiles > 0,
  hasActiveProfile: active,
));

void main() {
  test('stays on the startup screen until startup is done', () {
    expect(redirect(AppRoutes.home, startupDone: false), AppRoutes.startup);
    expect(redirect(AppRoutes.startup, startupDone: false), isNull);
  });

  test('forces creating a profile when none exists', () {
    expect(redirect(AppRoutes.startup, profiles: 0), AppRoutes.newProfile);
    expect(redirect(AppRoutes.home, profiles: 0), AppRoutes.newProfile);
    expect(redirect(AppRoutes.newProfile, profiles: 0), isNull);
  });

  test('requires picking a profile without an active one', () {
    expect(redirect(AppRoutes.startup), AppRoutes.profiles);
    expect(redirect(AppRoutes.home), AppRoutes.profiles);
    expect(redirect(AppRoutes.profiles), isNull);
    expect(redirect(AppRoutes.editProfile('x')), isNull);
  });

  test('opens home directly with an active profile', () {
    expect(redirect(AppRoutes.startup, active: true), AppRoutes.home);
    expect(redirect(AppRoutes.home, active: true), isNull);
    expect(redirect(AppRoutes.profiles, active: true), isNull);
  });
}
