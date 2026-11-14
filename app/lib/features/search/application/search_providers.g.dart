// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Text the user searches for (VOD-1). Kept while the section is closed,
/// so returning from a result shows the same results.

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// Text the user searches for (VOD-1). Kept while the section is closed,
/// so returning from a result shows the same results.
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Text the user searches for (VOD-1). Kept while the section is closed,
  /// so returning from a result shows the same results.
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'9ac1b693f68ca91613fa58a6270710e4eb058057';

/// Text the user searches for (VOD-1). Kept while the section is closed,
/// so returning from a result shows the same results.

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(channelSearch)
final channelSearchProvider = ChannelSearchFamily._();

final class ChannelSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LiveChannel>>,
          List<LiveChannel>,
          FutureOr<List<LiveChannel>>
        >
    with
        $FutureModifier<List<LiveChannel>>,
        $FutureProvider<List<LiveChannel>> {
  ChannelSearchProvider._({
    required ChannelSearchFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'channelSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$channelSearchHash();

  @override
  String toString() {
    return r'channelSearchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<LiveChannel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LiveChannel>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return channelSearch(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$channelSearchHash() => r'bc8259aa150349b207237ebe0aee753907675b4b';

final class ChannelSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<LiveChannel>>,
          (String, String)
        > {
  ChannelSearchFamily._()
    : super(
        retry: null,
        name: r'channelSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChannelSearchProvider call(String playlistId, String query) =>
      ChannelSearchProvider._(argument: (playlistId, query), from: this);

  @override
  String toString() => r'channelSearchProvider';
}

@ProviderFor(movieSearch)
final movieSearchProvider = MovieSearchFamily._();

final class MovieSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Movie>>,
          List<Movie>,
          FutureOr<List<Movie>>
        >
    with $FutureModifier<List<Movie>>, $FutureProvider<List<Movie>> {
  MovieSearchProvider._({
    required MovieSearchFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'movieSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieSearchHash();

  @override
  String toString() {
    return r'movieSearchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Movie>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Movie>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return movieSearch(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MovieSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieSearchHash() => r'daf85ea3be3dda495636b9f2b9e758ffc2f91cb6';

final class MovieSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Movie>>, (String, String)> {
  MovieSearchFamily._()
    : super(
        retry: null,
        name: r'movieSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovieSearchProvider call(String playlistId, String query) =>
      MovieSearchProvider._(argument: (playlistId, query), from: this);

  @override
  String toString() => r'movieSearchProvider';
}

@ProviderFor(seriesSearch)
final seriesSearchProvider = SeriesSearchFamily._();

final class SeriesSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Series>>,
          List<Series>,
          FutureOr<List<Series>>
        >
    with $FutureModifier<List<Series>>, $FutureProvider<List<Series>> {
  SeriesSearchProvider._({
    required SeriesSearchFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'seriesSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesSearchHash();

  @override
  String toString() {
    return r'seriesSearchProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Series>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Series>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return seriesSearch(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesSearchHash() => r'171ddaa43cf2f7c7bf93f460bb598fe5c61c5713';

final class SeriesSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Series>>, (String, String)> {
  SeriesSearchFamily._()
    : super(
        retry: null,
        name: r'seriesSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesSearchProvider call(String playlistId, String query) =>
      SeriesSearchProvider._(argument: (playlistId, query), from: this);

  @override
  String toString() => r'seriesSearchProvider';
}
