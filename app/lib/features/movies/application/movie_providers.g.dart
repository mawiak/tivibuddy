// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Movies the grid shows for a playlist. Starts with all movies.

@ProviderFor(MovieFilterSelection)
final movieFilterSelectionProvider = MovieFilterSelectionFamily._();

/// Movies the grid shows for a playlist. Starts with all movies.
final class MovieFilterSelectionProvider
    extends $NotifierProvider<MovieFilterSelection, VodFilter> {
  /// Movies the grid shows for a playlist. Starts with all movies.
  MovieFilterSelectionProvider._({
    required MovieFilterSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'movieFilterSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieFilterSelectionHash();

  @override
  String toString() {
    return r'movieFilterSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MovieFilterSelection create() => MovieFilterSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VodFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VodFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MovieFilterSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieFilterSelectionHash() =>
    r'd7db0feb579985646f05c65f0e3e6bc739248a9d';

/// Movies the grid shows for a playlist. Starts with all movies.

final class MovieFilterSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          MovieFilterSelection,
          VodFilter,
          VodFilter,
          VodFilter,
          String
        > {
  MovieFilterSelectionFamily._()
    : super(
        retry: null,
        name: r'movieFilterSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Movies the grid shows for a playlist. Starts with all movies.

  MovieFilterSelectionProvider call(String playlistId) =>
      MovieFilterSelectionProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'movieFilterSelectionProvider';
}

/// Movies the grid shows for a playlist. Starts with all movies.

abstract class _$MovieFilterSelection extends $Notifier<VodFilter> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  VodFilter build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VodFilter, VodFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VodFilter, VodFilter>,
              VodFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(movieCategories)
final movieCategoriesProvider = MovieCategoriesFamily._();

final class MovieCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MovieCategory>>,
          List<MovieCategory>,
          Stream<List<MovieCategory>>
        >
    with
        $FutureModifier<List<MovieCategory>>,
        $StreamProvider<List<MovieCategory>> {
  MovieCategoriesProvider._({
    required MovieCategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'movieCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieCategoriesHash();

  @override
  String toString() {
    return r'movieCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MovieCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MovieCategory>> create(Ref ref) {
    final argument = this.argument as String;
    return movieCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieCategoriesHash() => r'bf4f3f82c862b25141924fe9fe9f78ca4d352be6';

final class MovieCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MovieCategory>>, String> {
  MovieCategoriesFamily._()
    : super(
        retry: null,
        name: r'movieCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovieCategoriesProvider call(String playlistId) =>
      MovieCategoriesProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'movieCategoriesProvider';
}

/// Movies of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

@ProviderFor(movieList)
final movieListProvider = MovieListFamily._();

/// Movies of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

final class MovieListProvider
    extends
        $FunctionalProvider<
          AsyncValue<PagedList<Movie>>,
          PagedList<Movie>,
          FutureOr<PagedList<Movie>>
        >
    with $FutureModifier<PagedList<Movie>>, $FutureProvider<PagedList<Movie>> {
  /// Movies of a filter as a lazily loaded list, rebuilt when their number
  /// changes and stays stable (see `liveChannelList`).
  MovieListProvider._({
    required MovieListFamily super.from,
    required (String, VodFilter) super.argument,
  }) : super(
         retry: null,
         name: r'movieListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieListHash();

  @override
  String toString() {
    return r'movieListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PagedList<Movie>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PagedList<Movie>> create(Ref ref) {
    final argument = this.argument as (String, VodFilter);
    return movieList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieListHash() => r'58709869b652e7d5ff7013dbed4a88816f9f0a23';

/// Movies of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

final class MovieListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PagedList<Movie>>,
          (String, VodFilter)
        > {
  MovieListFamily._()
    : super(
        retry: null,
        name: r'movieListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Movies of a filter as a lazily loaded list, rebuilt when their number
  /// changes and stays stable (see `liveChannelList`).

  MovieListProvider call(String playlistId, VodFilter filter) =>
      MovieListProvider._(argument: (playlistId, filter), from: this);

  @override
  String toString() => r'movieListProvider';
}

/// Details from the provider, cached for a few minutes.

@ProviderFor(movieDetails)
final movieDetailsProvider = MovieDetailsFamily._();

/// Details from the provider, cached for a few minutes.

final class MovieDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MovieDetails>,
          MovieDetails,
          FutureOr<MovieDetails>
        >
    with $FutureModifier<MovieDetails>, $FutureProvider<MovieDetails> {
  /// Details from the provider, cached for a few minutes.
  MovieDetailsProvider._({
    required MovieDetailsFamily super.from,
    required Movie super.argument,
  }) : super(
         retry: null,
         name: r'movieDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieDetailsHash();

  @override
  String toString() {
    return r'movieDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MovieDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MovieDetails> create(Ref ref) {
    final argument = this.argument as Movie;
    return movieDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieDetailsHash() => r'62fecf0616dfc7baa02625766922f5b9c46f7efb';

/// Details from the provider, cached for a few minutes.

final class MovieDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MovieDetails>, Movie> {
  MovieDetailsFamily._()
    : super(
        retry: null,
        name: r'movieDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Details from the provider, cached for a few minutes.

  MovieDetailsProvider call(Movie movie) =>
      MovieDetailsProvider._(argument: movie, from: this);

  @override
  String toString() => r'movieDetailsProvider';
}

/// What the active profile did with a movie.

@ProviderFor(movieState)
final movieStateProvider = MovieStateFamily._();

/// What the active profile did with a movie.

final class MovieStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MovieState>,
          MovieState,
          Stream<MovieState>
        >
    with $FutureModifier<MovieState>, $StreamProvider<MovieState> {
  /// What the active profile did with a movie.
  MovieStateProvider._({
    required MovieStateFamily super.from,
    required Movie super.argument,
  }) : super(
         retry: null,
         name: r'movieStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieStateHash();

  @override
  String toString() {
    return r'movieStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<MovieState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<MovieState> create(Ref ref) {
    final argument = this.argument as Movie;
    return movieState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieStateHash() => r'e91eb96d25b9a9d1c772ce6f3c921ce8714a6231';

/// What the active profile did with a movie.

final class MovieStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<MovieState>, Movie> {
  MovieStateFamily._()
    : super(
        retry: null,
        name: r'movieStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the active profile did with a movie.

  MovieStateProvider call(Movie movie) =>
      MovieStateProvider._(argument: movie, from: this);

  @override
  String toString() => r'movieStateProvider';
}

/// Playback URL of a movie.

@ProviderFor(movieStreamUrl)
final movieStreamUrlProvider = MovieStreamUrlFamily._();

/// Playback URL of a movie.

final class MovieStreamUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Playback URL of a movie.
  MovieStreamUrlProvider._({
    required MovieStreamUrlFamily super.from,
    required Movie super.argument,
  }) : super(
         retry: null,
         name: r'movieStreamUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieStreamUrlHash();

  @override
  String toString() {
    return r'movieStreamUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as Movie;
    return movieStreamUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieStreamUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieStreamUrlHash() => r'585489d53163650b39d3c5d941d22a66ebe26794';

/// Playback URL of a movie.

final class MovieStreamUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, Movie> {
  MovieStreamUrlFamily._()
    : super(
        retry: null,
        name: r'movieStreamUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Playback URL of a movie.

  MovieStreamUrlProvider call(Movie movie) =>
      MovieStreamUrlProvider._(argument: movie, from: this);

  @override
  String toString() => r'movieStreamUrlProvider';
}
