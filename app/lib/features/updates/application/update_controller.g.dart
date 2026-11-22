// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// In-app updates on Android: checks the GitHub releases, downloads the APK
/// of the device's ABI and opens the system installer. Other platforms
/// follow later (see the roadmap); there the controller stays idle.

@ProviderFor(UpdateController)
final updateControllerProvider = UpdateControllerProvider._();

/// In-app updates on Android: checks the GitHub releases, downloads the APK
/// of the device's ABI and opens the system installer. Other platforms
/// follow later (see the roadmap); there the controller stays idle.
final class UpdateControllerProvider
    extends $NotifierProvider<UpdateController, UpdateState> {
  /// In-app updates on Android: checks the GitHub releases, downloads the APK
  /// of the device's ABI and opens the system installer. Other platforms
  /// follow later (see the roadmap); there the controller stays idle.
  UpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateControllerHash();

  @$internal
  @override
  UpdateController create() => UpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateState>(value),
    );
  }
}

String _$updateControllerHash() => r'd66004cc0b80142c9efa73760823f24d70ef3415';

/// In-app updates on Android: checks the GitHub releases, downloads the APK
/// of the device's ABI and opens the system installer. Other platforms
/// follow later (see the roadmap); there the controller stays idle.

abstract class _$UpdateController extends $Notifier<UpdateState> {
  UpdateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UpdateState, UpdateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateState, UpdateState>,
              UpdateState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
