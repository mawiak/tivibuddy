import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profiles/application/profile_providers.dart';
import '../../settings/data/settings_data_providers.dart';

part 'app_startup.g.dart';

/// Opens the database and decides the initial profile.
///
/// A default profile is activated directly (PROF-5) unless it is protected by
/// a PIN. In that case the profile picker is shown with the default profile
/// focused, so the PIN is never bypassed.
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  final profiles = await ref.watch(profilesProvider.future);
  final defaultId = await ref
      .read(deviceSettingsRepositoryProvider)
      .getDefaultProfileId();

  final defaultProfile = profiles
      .where((profile) => profile.id == defaultId)
      .firstOrNull;
  if (defaultProfile != null && !defaultProfile.hasPin) {
    ref.read(activeProfileIdProvider.notifier).activate(defaultProfile.id);
  }
}
