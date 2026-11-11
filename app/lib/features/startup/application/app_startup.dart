import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../../profiles/domain/profile.dart';
import '../../settings/data/settings_data_providers.dart';

part 'app_startup.g.dart';

/// Opens the database and decides the initial profile.
///
/// A default profile is activated directly (PROF-5) unless it is protected by
/// a PIN. In that case the profile picker opens and asks for the PIN of the
/// default profile right away (see [StartupPinRequest]), so the PIN is never
/// bypassed.
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  // Listen instead of watch: startup must run exactly once. Watching the
  // profile list would re-run it on every profile change and re-activate
  // the default profile while another profile is in use. The listener keeps
  // the list active while it loads, since unlistened providers are paused.
  final subscription = ref.listen(profilesProvider, (_, _) {});
  final List<Profile> profiles;
  try {
    profiles = await ref.read(profilesProvider.future);
  } finally {
    subscription.close();
  }
  final defaultId = await ref
      .read(deviceSettingsRepositoryProvider)
      .getDefaultProfileId();

  final defaultProfile = profiles
      .where((profile) => profile.id == defaultId)
      .firstOrNull;
  if (defaultProfile == null) return;
  if (defaultProfile.hasPin) {
    ref.read(startupPinRequestProvider.notifier).request(defaultProfile.id);
  } else {
    ref.read(activeProfileIdProvider.notifier).activate(defaultProfile.id);
  }
}

/// Profile whose PIN the picker asks for as soon as it opens after startup.
/// Consumed once, so returning to the picker later does not ask again.
@Riverpod(keepAlive: true)
class StartupPinRequest extends _$StartupPinRequest {
  @override
  String? build() => null;

  void request(String profileId) => state = profileId;

  /// Returns the requested profile id and clears the request.
  String? take() {
    final profileId = state;
    state = null;
    return profileId;
  }
}
