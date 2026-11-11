// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(seriesRepository)
final seriesRepositoryProvider = SeriesRepositoryProvider._();

final class SeriesRepositoryProvider
    extends
        $FunctionalProvider<
          SeriesRepository,
          SeriesRepository,
          SeriesRepository
        >
    with $Provider<SeriesRepository> {
  SeriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SeriesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeriesRepository create(Ref ref) {
    return seriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeriesRepository>(value),
    );
  }
}

String _$seriesRepositoryHash() => r'7e6ca6878a657b13470527634d603adecbf3f02a';

/// Series source for each playlist type (PL-3).

@ProviderFor(seriesCatalogSource)
final seriesCatalogSourceProvider = SeriesCatalogSourceFamily._();

/// Series source for each playlist type (PL-3).

final class SeriesCatalogSourceProvider
    extends
        $FunctionalProvider<
          SeriesCatalogSource,
          SeriesCatalogSource,
          SeriesCatalogSource
        >
    with $Provider<SeriesCatalogSource> {
  /// Series source for each playlist type (PL-3).
  SeriesCatalogSourceProvider._({
    required SeriesCatalogSourceFamily super.from,
    required PlaylistType super.argument,
  }) : super(
         retry: null,
         name: r'seriesCatalogSourceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesCatalogSourceHash();

  @override
  String toString() {
    return r'seriesCatalogSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SeriesCatalogSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SeriesCatalogSource create(Ref ref) {
    final argument = this.argument as PlaylistType;
    return seriesCatalogSource(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeriesCatalogSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeriesCatalogSource>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesCatalogSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesCatalogSourceHash() =>
    r'1c0b893b5ce2125ecec80cdad1ca7eb2ad0671fc';

/// Series source for each playlist type (PL-3).

final class SeriesCatalogSourceFamily extends $Family
    with $FunctionalFamilyOverride<SeriesCatalogSource, PlaylistType> {
  SeriesCatalogSourceFamily._()
    : super(
        retry: null,
        name: r'seriesCatalogSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Series source for each playlist type (PL-3).

  SeriesCatalogSourceProvider call(PlaylistType type) =>
      SeriesCatalogSourceProvider._(argument: type, from: this);

  @override
  String toString() => r'seriesCatalogSourceProvider';
}
