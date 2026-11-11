// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the movie catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

@ProviderFor(MovieCatalogController)
final movieCatalogControllerProvider = MovieCatalogControllerFamily._();

/// Loads the movie catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.
final class MovieCatalogControllerProvider
    extends $NotifierProvider<MovieCatalogController, MovieCatalogStatus> {
  /// Loads the movie catalog of a playlist into the local database (DATA-1,
  /// DATA-2). The previous catalog stays visible while a refresh runs.
  MovieCatalogControllerProvider._({
    required MovieCatalogControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'movieCatalogControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieCatalogControllerHash();

  @override
  String toString() {
    return r'movieCatalogControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MovieCatalogController create() => MovieCatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovieCatalogStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovieCatalogStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MovieCatalogControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieCatalogControllerHash() =>
    r'f8fbeca0f575749271ae909ee80db7e682c07cf1';

/// Loads the movie catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

final class MovieCatalogControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MovieCatalogController,
          MovieCatalogStatus,
          MovieCatalogStatus,
          MovieCatalogStatus,
          String
        > {
  MovieCatalogControllerFamily._()
    : super(
        retry: null,
        name: r'movieCatalogControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Loads the movie catalog of a playlist into the local database (DATA-1,
  /// DATA-2). The previous catalog stays visible while a refresh runs.

  MovieCatalogControllerProvider call(String playlistId) =>
      MovieCatalogControllerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'movieCatalogControllerProvider';
}

/// Loads the movie catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

abstract class _$MovieCatalogController extends $Notifier<MovieCatalogStatus> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  MovieCatalogStatus build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MovieCatalogStatus, MovieCatalogStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MovieCatalogStatus, MovieCatalogStatus>,
              MovieCatalogStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
