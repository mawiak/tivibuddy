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
