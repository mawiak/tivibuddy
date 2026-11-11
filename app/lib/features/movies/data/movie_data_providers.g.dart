// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(movieRepository)
final movieRepositoryProvider = MovieRepositoryProvider._();

final class MovieRepositoryProvider
    extends
        $FunctionalProvider<MovieRepository, MovieRepository, MovieRepository>
    with $Provider<MovieRepository> {
  MovieRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movieRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movieRepositoryHash();

  @$internal
  @override
  $ProviderElement<MovieRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MovieRepository create(Ref ref) {
    return movieRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovieRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovieRepository>(value),
    );
  }
}

String _$movieRepositoryHash() => r'41b49d3c58e1492b7c0258574ca6cdc9e0cc6731';

/// Movie source for each playlist type (PL-3).

@ProviderFor(movieCatalogSource)
final movieCatalogSourceProvider = MovieCatalogSourceFamily._();

/// Movie source for each playlist type (PL-3).

final class MovieCatalogSourceProvider
    extends
        $FunctionalProvider<
          MovieCatalogSource,
          MovieCatalogSource,
          MovieCatalogSource
        >
    with $Provider<MovieCatalogSource> {
  /// Movie source for each playlist type (PL-3).
  MovieCatalogSourceProvider._({
    required MovieCatalogSourceFamily super.from,
    required PlaylistType super.argument,
  }) : super(
         retry: null,
         name: r'movieCatalogSourceProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieCatalogSourceHash();

  @override
  String toString() {
    return r'movieCatalogSourceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<MovieCatalogSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MovieCatalogSource create(Ref ref) {
    final argument = this.argument as PlaylistType;
    return movieCatalogSource(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovieCatalogSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovieCatalogSource>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MovieCatalogSourceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieCatalogSourceHash() =>
    r'6272458c97ed646bc6f6d040b11e2cfbeeb97016';

/// Movie source for each playlist type (PL-3).

final class MovieCatalogSourceFamily extends $Family
    with $FunctionalFamilyOverride<MovieCatalogSource, PlaylistType> {
  MovieCatalogSourceFamily._()
    : super(
        retry: null,
        name: r'movieCatalogSourceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Movie source for each playlist type (PL-3).

  MovieCatalogSourceProvider call(PlaylistType type) =>
      MovieCatalogSourceProvider._(argument: type, from: this);

  @override
  String toString() => r'movieCatalogSourceProvider';
}
