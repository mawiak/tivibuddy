import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/profile_data_providers.dart';
import '../domain/profile.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Profile>> profiles(Ref ref) =>
    ref.watch(profileRepositoryProvider).watchAll();

/// The profile currently using the app. Kept in memory only: after a
/// restart the user picks a profile again unless a default profile is set.
@Riverpod(keepAlive: true)
class ActiveProfileId extends _$ActiveProfileId {
  @override
  String? build() => null;

  void activate(String id) => state = id;

  void clear() => state = null;
}

@riverpod
Profile? activeProfile(Ref ref) {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return null;
  final all = ref.watch(profilesProvider).value ?? const [];
  return all.where((profile) => profile.id == id).firstOrNull;
}
