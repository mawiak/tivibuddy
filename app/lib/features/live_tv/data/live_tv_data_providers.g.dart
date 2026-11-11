// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tv_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveTvRepository)
final liveTvRepositoryProvider = LiveTvRepositoryProvider._();

final class LiveTvRepositoryProvider
    extends
        $FunctionalProvider<
          LiveTvRepository,
          LiveTvRepository,
          LiveTvRepository
        >
    with $Provider<LiveTvRepository> {
  LiveTvRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTvRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTvRepositoryHash();

  @$internal
  @override
  $ProviderElement<LiveTvRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LiveTvRepository create(Ref ref) {
    return liveTvRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveTvRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveTvRepository>(value),
    );
  }
}

String _$liveTvRepositoryHash() => r'b6cb5f5a629c9860f5fba40cac4ee4869fa9bef5';

/// Catalog source for each playlist type (PL-3).

@ProviderFor(liveCatalogSource)
final liveCatalogSourceProvider = LiveCatalogSourceFamily._();

/// Catalog source for each playlist type (PL-3).

final class LiveCatalogSourceProvider
    extends
        $FunctionalProvider<
          LiveCatalogSource,
          LiveCatalogSource,
          LiveCatalogSource
        >
    with $Provider<LiveCatalogSource> {
  /// Catalog source for each playlist type (PL-3).
  LiveCatalogSourceProvider._({
    required LiveCatalogSourceFamily super.from,
    required PlaylistType super.argument,
  }) : super(
         retry: null,
         name: r'liveCatalogSourceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveCatalogSourceHash();

  @override
  String toString() {
    return r'liveCatalogSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<LiveCatalogSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveCatalogSource create(Ref ref) {
    final argument = this.argument as PlaylistType;
    return liveCatalogSource(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveCatalogSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveCatalogSource>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveCatalogSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveCatalogSourceHash() => r'9e916b3b5a9b91f181ddcf9457bfb8f7561ad110';

/// Catalog source for each playlist type (PL-3).

final class LiveCatalogSourceFamily extends $Family
    with $FunctionalFamilyOverride<LiveCatalogSource, PlaylistType> {
  LiveCatalogSourceFamily._()
    : super(
        retry: null,
        name: r'liveCatalogSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Catalog source for each playlist type (PL-3).

  LiveCatalogSourceProvider call(PlaylistType type) =>
      LiveCatalogSourceProvider._(argument: type, from: this);

  @override
  String toString() => r'liveCatalogSourceProvider';
}
