// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateSource)
final updateSourceProvider = UpdateSourceProvider._();

final class UpdateSourceProvider
    extends $FunctionalProvider<UpdateSource, UpdateSource, UpdateSource>
    with $Provider<UpdateSource> {
  UpdateSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateSourceHash();

  @$internal
  @override
  $ProviderElement<UpdateSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateSource create(Ref ref) {
    return updateSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateSource>(value),
    );
  }
}

String _$updateSourceHash() => r'f6a997c4b05db335b77240598cff37d335be35ae';

@ProviderFor(updateInstaller)
final updateInstallerProvider = UpdateInstallerProvider._();

final class UpdateInstallerProvider
    extends
        $FunctionalProvider<UpdateInstaller, UpdateInstaller, UpdateInstaller>
    with $Provider<UpdateInstaller> {
  UpdateInstallerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateInstallerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateInstallerHash();

  @$internal
  @override
  $ProviderElement<UpdateInstaller> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateInstaller create(Ref ref) {
    return updateInstaller(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateInstaller value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateInstaller>(value),
    );
  }
}

String _$updateInstallerHash() => r'2ed01cf0cd3ae189c6a6816bea86c5a66ec9c308';
