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
    r'8ccf58fb20bb5702e48d46d5f2b74b02bb73eb97';

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

/// What the audio output accepts for passthrough right now; null where the
/// platform does not tell.

@ProviderFor(passthroughSupport)
final passthroughSupportProvider = PassthroughSupportProvider._();

/// What the audio output accepts for passthrough right now; null where the
/// platform does not tell.

final class PassthroughSupportProvider
    extends
        $FunctionalProvider<
          AsyncValue<PassthroughSupport?>,
          PassthroughSupport?,
          FutureOr<PassthroughSupport?>
        >
    with
        $FutureModifier<PassthroughSupport?>,
        $FutureProvider<PassthroughSupport?> {
  /// What the audio output accepts for passthrough right now; null where the
  /// platform does not tell.
  PassthroughSupportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passthroughSupportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passthroughSupportHash();

  @$internal
  @override
  $FutureProviderElement<PassthroughSupport?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PassthroughSupport?> create(Ref ref) {
    return passthroughSupport(ref);
  }
}

String _$passthroughSupportHash() =>
    r'47e1147eaf0dbd4dfadd4571190097fc300f2021';
