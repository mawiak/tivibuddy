// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceSettingsRepository)
final deviceSettingsRepositoryProvider = DeviceSettingsRepositoryProvider._();

final class DeviceSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          DeviceSettingsRepository,
          DeviceSettingsRepository,
          DeviceSettingsRepository
        >
    with $Provider<DeviceSettingsRepository> {
  DeviceSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeviceSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceSettingsRepository create(Ref ref) {
    return deviceSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceSettingsRepository>(value),
    );
  }
}

String _$deviceSettingsRepositoryHash() =>
    r'c2b20c7ba48c3522cc1e6268b7910aca00faee2b';

@ProviderFor(profileSettingsRepository)
final profileSettingsRepositoryProvider = ProfileSettingsRepositoryProvider._();

final class ProfileSettingsRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileSettingsRepository,
          ProfileSettingsRepository,
          ProfileSettingsRepository
        >
    with $Provider<ProfileSettingsRepository> {
  ProfileSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSettingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileSettingsRepository create(Ref ref) {
    return profileSettingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileSettingsRepository>(value),
    );
  }
}

String _$profileSettingsRepositoryHash() =>
    r'3d0d694a3310d181a97f28cc16581be71c39b4e8';
