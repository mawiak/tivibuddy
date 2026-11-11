// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Only the facts the redirect depends on. Refreshing the router on every
/// profile change (for example a rename) would race with screens popping
/// themselves and restore the popped route.

@ProviderFor(redirectInputs)
final redirectInputsProvider = RedirectInputsProvider._();

/// Only the facts the redirect depends on. Refreshing the router on every
/// profile change (for example a rename) would race with screens popping
/// themselves and restore the popped route.

final class RedirectInputsProvider
    extends $FunctionalProvider<RedirectInputs, RedirectInputs, RedirectInputs>
    with $Provider<RedirectInputs> {
  /// Only the facts the redirect depends on. Refreshing the router on every
  /// profile change (for example a rename) would race with screens popping
  /// themselves and restore the popped route.
  RedirectInputsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'redirectInputsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$redirectInputsHash();

  @$internal
  @override
  $ProviderElement<RedirectInputs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RedirectInputs create(Ref ref) {
    return redirectInputs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RedirectInputs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RedirectInputs>(value),
    );
  }
}

String _$redirectInputsHash() => r'0b2cf1c4145711ad9e7aed96645d715e10b5af8a';

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'3a95f4bcdb4886ac14225282d793a269f51f4966';
