import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../movies/data/movie_data_providers.dart';
import '../../playlists/application/playlist_actions.dart';
import '../../series/data/series_data_providers.dart';
import '../../settings/data/settings_data_providers.dart';
import '../data/profile_data_providers.dart';
import '../domain/profile.dart';
import 'profile_providers.dart';

part 'profile_actions.g.dart';

sealed class PinChange {
  const PinChange();
}

final class PinUnchanged extends PinChange {
  const PinUnchanged();
}

final class PinRemoved extends PinChange {
  const PinRemoved();
}

final class PinSet extends PinChange {
  const PinSet(this.pin);
  final String pin;
}

/// Initial values for the profile form.
class ProfileFormData {
  const ProfileFormData({
    required this.name,
    required this.avatar,
    required this.hasPin,
    required this.startAutomatically,
    required this.isFirstProfile,
    this.otherDefaultProfileName,
  });

  final String name;
  final ProfileAvatar avatar;
  final bool hasPin;
  final bool startAutomatically;
  final bool isFirstProfile;

  /// Name of the current default profile when it is a different profile.
  /// Enabling "start automatically" replaces it, which the user confirms.
  final String? otherDefaultProfileName;
}

/// Use cases around profiles. Widgets call these instead of repositories.
@Riverpod(keepAlive: true)
ProfileActions profileActions(Ref ref) => ProfileActions(ref);

class ProfileActions {
  ProfileActions(this._ref);

  final Ref _ref;

  /// Loads the form for [id], or defaults for a new profile when [id] is
  /// null. Throws [StateError] when the profile does not exist.
  Future<ProfileFormData> loadForm(String? id) async {
    final profiles = _ref.read(profileRepositoryProvider);
    final defaultId = await _ref
        .read(deviceSettingsRepositoryProvider)
        .getDefaultProfileId();

    final existing = await profiles.getAll();
    final otherDefaultName = existing
        .where((profile) => profile.id == defaultId && profile.id != id)
        .firstOrNull
        ?.name;

    if (id == null) {
      return ProfileFormData(
        name: '',
        avatar: PresetAvatar(existing.length),
        hasPin: false,
        startAutomatically: false,
        isFirstProfile: existing.isEmpty,
        otherDefaultProfileName: otherDefaultName,
      );
    }

    final profile = await profiles.findById(id);
    if (profile == null) throw StateError('Profile $id does not exist');
    return ProfileFormData(
      name: profile.name,
      avatar: profile.avatar,
      hasPin: profile.hasPin,
      startAutomatically: defaultId == id,
      isFirstProfile: false,
      otherDefaultProfileName: otherDefaultName,
    );
  }

  /// Creates a profile when [id] is null, otherwise updates it.
  Future<Profile> save({
    String? id,
    required String name,
    required ProfileAvatar avatar,
    required PinChange pinChange,
    required bool startAutomatically,
  }) async {
    final profiles = _ref.read(profileRepositoryProvider);
    final settings = _ref.read(deviceSettingsRepositoryProvider);

    final String savedId;
    if (id == null) {
      final created = await profiles.create(
        name: name,
        avatar: avatar,
        pin: pinChange is PinSet ? pinChange.pin : null,
      );
      savedId = created.id;
    } else {
      await profiles.update(id, name: name, avatar: avatar);
      switch (pinChange) {
        case PinUnchanged():
          break;
        case PinRemoved():
          await profiles.setPin(id, null);
        case PinSet(:final pin):
          await profiles.setPin(id, pin);
      }
      savedId = id;
    }

    final currentDefault = await settings.getDefaultProfileId();
    if (startAutomatically) {
      await settings.setDefaultProfileId(savedId);
    } else if (currentDefault == savedId) {
      await settings.setDefaultProfileId(null);
    }

    return (await profiles.findById(savedId))!;
  }

  /// Deletes the profile together with its settings, playlists and their
  /// passwords, and its watch progress.
  Future<void> delete(String id) async {
    await _ref.read(playlistActionsProvider).deleteAllForProfile(id);
    await _ref.read(movieRepositoryProvider).deleteStatesForProfile(id);
    await _ref.read(seriesRepositoryProvider).deleteStatesForProfile(id);
    await _ref.read(profileSettingsRepositoryProvider).reset(id);
    await _ref.read(profileRepositoryProvider).delete(id);
    final settings = _ref.read(deviceSettingsRepositoryProvider);
    if (await settings.getDefaultProfileId() == id) {
      await settings.setDefaultProfileId(null);
    }
    if (_ref.read(activeProfileIdProvider) == id) {
      _ref.read(activeProfileIdProvider.notifier).clear();
    }
  }

  Future<bool> verifyPin(String id, String pin) =>
      _ref.read(profileRepositoryProvider).verifyPin(id, pin);

  void activate(String id) =>
      _ref.read(activeProfileIdProvider.notifier).activate(id);
}
