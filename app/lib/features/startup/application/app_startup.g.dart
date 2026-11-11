// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opens the database and decides the initial profile.
///
/// A default profile is activated directly (PROF-5) unless it is protected by
/// a PIN. In that case the profile picker opens and asks for the PIN of the
/// default profile right away (see [StartupPinRequest]), so the PIN is never
/// bypassed.

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// Opens the database and decides the initial profile.
///
/// A default profile is activated directly (PROF-5) unless it is protected by
/// a PIN. In that case the profile picker opens and asks for the PIN of the
/// default profile right away (see [StartupPinRequest]), so the PIN is never
/// bypassed.

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Opens the database and decides the initial profile.
  ///
  /// A default profile is activated directly (PROF-5) unless it is protected by
  /// a PIN. In that case the profile picker opens and asks for the PIN of the
  /// default profile right away (see [StartupPinRequest]), so the PIN is never
  /// bypassed.
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appStartup(ref);
  }
}

String _$appStartupHash() => r'e03920c7bcba7f98a843d9787fd3f69f31e47181';

/// Profile whose PIN the picker asks for as soon as it opens after startup.
/// Consumed once, so returning to the picker later does not ask again.

@ProviderFor(StartupPinRequest)
final startupPinRequestProvider = StartupPinRequestProvider._();

/// Profile whose PIN the picker asks for as soon as it opens after startup.
/// Consumed once, so returning to the picker later does not ask again.
final class StartupPinRequestProvider
    extends $NotifierProvider<StartupPinRequest, String?> {
  /// Profile whose PIN the picker asks for as soon as it opens after startup.
  /// Consumed once, so returning to the picker later does not ask again.
  StartupPinRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupPinRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupPinRequestHash();

  @$internal
  @override
  StartupPinRequest create() => StartupPinRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$startupPinRequestHash() => r'e1d0f1e2e1ac80fc68d6f1f72dac9e8f0345659c';

/// Profile whose PIN the picker asks for as soon as it opens after startup.
/// Consumed once, so returning to the picker later does not ask again.

abstract class _$StartupPinRequest extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
