// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_settings_providers.dart';

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
