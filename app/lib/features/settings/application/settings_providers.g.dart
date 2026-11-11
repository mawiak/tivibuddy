// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultProfileId)
final defaultProfileIdProvider = DefaultProfileIdProvider._();

final class DefaultProfileIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  DefaultProfileIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultProfileIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultProfileIdHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return defaultProfileId(ref);
  }
}

String _$defaultProfileIdHash() => r'73d94977cd442dc8045429079502a1a8d8e1679c';

/// Settings of the active profile, or the defaults without one.

@ProviderFor(activeProfileSettings)
final activeProfileSettingsProvider = ActiveProfileSettingsProvider._();

/// Settings of the active profile, or the defaults without one.

final class ActiveProfileSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileSettings>,
          ProfileSettings,
          Stream<ProfileSettings>
        >
    with $FutureModifier<ProfileSettings>, $StreamProvider<ProfileSettings> {
  /// Settings of the active profile, or the defaults without one.
  ActiveProfileSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProfileSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProfileSettingsHash();

  @$internal
  @override
  $StreamProviderElement<ProfileSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProfileSettings> create(Ref ref) {
    return activeProfileSettings(ref);
  }
}

String _$activeProfileSettingsHash() =>
    r'06f9c0e7c30d505af50da8907a0b5259dd595b96';

/// Language tag the app is shown in, or null for the device language.

@ProviderFor(appLanguage)
final appLanguageProvider = AppLanguageProvider._();

/// Language tag the app is shown in, or null for the device language.

final class AppLanguageProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Language tag the app is shown in, or null for the device language.
  AppLanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLanguageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLanguageHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return appLanguage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appLanguageHash() => r'c12deed7ce7960aebb82baa8f787ef1ae28e751f';
