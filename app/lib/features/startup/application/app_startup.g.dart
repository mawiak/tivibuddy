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
/// a PIN. In that case the profile picker is shown with the default profile
/// focused, so the PIN is never bypassed.

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// Opens the database and decides the initial profile.
///
/// A default profile is activated directly (PROF-5) unless it is protected by
/// a PIN. In that case the profile picker is shown with the default profile
/// focused, so the PIN is never bypassed.

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Opens the database and decides the initial profile.
  ///
  /// A default profile is activated directly (PROF-5) unless it is protected by
  /// a PIN. In that case the profile picker is shown with the default profile
  /// focused, so the PIN is never bypassed.
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

String _$appStartupHash() => r'59512f7c893d3921595cf138a938e743430cc240';
