// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Player settings of this device, kept as device settings (SET-1). Kept
/// alive and listened to from the app root, so the playback engine finds the
/// stored values when it is created.

@ProviderFor(PlayerSettingsController)
final playerSettingsControllerProvider = PlayerSettingsControllerProvider._();

/// Player settings of this device, kept as device settings (SET-1). Kept
/// alive and listened to from the app root, so the playback engine finds the
/// stored values when it is created.
final class PlayerSettingsControllerProvider
    extends $NotifierProvider<PlayerSettingsController, PlayerSettings> {
  /// Player settings of this device, kept as device settings (SET-1). Kept
  /// alive and listened to from the app root, so the playback engine finds the
  /// stored values when it is created.
  PlayerSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerSettingsControllerHash();

  @$internal
  @override
  PlayerSettingsController create() => PlayerSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayerSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayerSettings>(value),
    );
  }
}

String _$playerSettingsControllerHash() =>
    r'81cd70fd01e2bb82e08301491da3db224b6a8d4d';

/// Player settings of this device, kept as device settings (SET-1). Kept
/// alive and listened to from the app root, so the playback engine finds the
/// stored values when it is created.

abstract class _$PlayerSettingsController extends $Notifier<PlayerSettings> {
  PlayerSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlayerSettings, PlayerSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlayerSettings, PlayerSettings>,
              PlayerSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
