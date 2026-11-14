// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Series the grid shows for a playlist. Starts with all series.

@ProviderFor(SeriesFilterSelection)
final seriesFilterSelectionProvider = SeriesFilterSelectionFamily._();

/// Series the grid shows for a playlist. Starts with all series.
final class SeriesFilterSelectionProvider
    extends $NotifierProvider<SeriesFilterSelection, VodFilter> {
  /// Series the grid shows for a playlist. Starts with all series.
  SeriesFilterSelectionProvider._({
    required SeriesFilterSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'seriesFilterSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesFilterSelectionHash();

  @override
  String toString() {
    return r'seriesFilterSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesFilterSelection create() => SeriesFilterSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VodFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VodFilter>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesFilterSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesFilterSelectionHash() =>
    r'4bb8c0048b631d64620c2c32ac39bcfe01e5711a';

/// Series the grid shows for a playlist. Starts with all series.

final class SeriesFilterSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesFilterSelection,
          VodFilter,
          VodFilter,
          VodFilter,
          String
        > {
  SeriesFilterSelectionFamily._()
    : super(
        retry: null,
        name: r'seriesFilterSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Series the grid shows for a playlist. Starts with all series.

  SeriesFilterSelectionProvider call(String playlistId) =>
      SeriesFilterSelectionProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'seriesFilterSelectionProvider';
}

/// Series the grid shows for a playlist. Starts with all series.

abstract class _$SeriesFilterSelection extends $Notifier<VodFilter> {
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

@ProviderFor(seriesCategories)
final seriesCategoriesProvider = SeriesCategoriesFamily._();

final class SeriesCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SeriesCategory>>,
          List<SeriesCategory>,
          Stream<List<SeriesCategory>>
        >
    with
        $FutureModifier<List<SeriesCategory>>,
        $StreamProvider<List<SeriesCategory>> {
  SeriesCategoriesProvider._({
    required SeriesCategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'seriesCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesCategoriesHash();

  @override
  String toString() {
    return r'seriesCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SeriesCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SeriesCategory>> create(Ref ref) {
    final argument = this.argument as String;
    return seriesCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesCategoriesHash() => r'6a5ad33fc3c1271f6e94216ff62486065aa84e93';

final class SeriesCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SeriesCategory>>, String> {
  SeriesCategoriesFamily._()
    : super(
        retry: null,
        name: r'seriesCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeriesCategoriesProvider call(String playlistId) =>
      SeriesCategoriesProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'seriesCategoriesProvider';
}

/// Series of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

@ProviderFor(seriesList)
final seriesListProvider = SeriesListFamily._();

/// Series of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

final class SeriesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<PagedList<Series>>,
          PagedList<Series>,
          FutureOr<PagedList<Series>>
        >
    with
        $FutureModifier<PagedList<Series>>,
        $FutureProvider<PagedList<Series>> {
  /// Series of a filter as a lazily loaded list, rebuilt when their number
  /// changes and stays stable (see `liveChannelList`).
  SeriesListProvider._({
    required SeriesListFamily super.from,
    required (String, VodFilter) super.argument,
  }) : super(
         retry: null,
         name: r'seriesListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesListHash();

  @override
  String toString() {
    return r'seriesListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PagedList<Series>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PagedList<Series>> create(Ref ref) {
    final argument = this.argument as (String, VodFilter);
    return seriesList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesListHash() => r'8778d2f25a6733a5633713e02f571dc9826f38be';

/// Series of a filter as a lazily loaded list, rebuilt when their number
/// changes and stays stable (see `liveChannelList`).

final class SeriesListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PagedList<Series>>,
          (String, VodFilter)
        > {
  SeriesListFamily._()
    : super(
        retry: null,
        name: r'seriesListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Series of a filter as a lazily loaded list, rebuilt when their number
  /// changes and stays stable (see `liveChannelList`).

  SeriesListProvider call(String playlistId, VodFilter filter) =>
      SeriesListProvider._(argument: (playlistId, filter), from: this);

  @override
  String toString() => r'seriesListProvider';
}

/// Seasons and episodes from the provider, cached for a few minutes.

@ProviderFor(seriesDetails)
final seriesDetailsProvider = SeriesDetailsFamily._();

/// Seasons and episodes from the provider, cached for a few minutes.

final class SeriesDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeriesDetails>,
          SeriesDetails,
          FutureOr<SeriesDetails>
        >
    with $FutureModifier<SeriesDetails>, $FutureProvider<SeriesDetails> {
  /// Seasons and episodes from the provider, cached for a few minutes.
  SeriesDetailsProvider._({
    required SeriesDetailsFamily super.from,
    required Series super.argument,
  }) : super(
         retry: null,
         name: r'seriesDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesDetailsHash();

  @override
  String toString() {
    return r'seriesDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SeriesDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SeriesDetails> create(Ref ref) {
    final argument = this.argument as Series;
    return seriesDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesDetailsHash() => r'ef179361cd3985efde03f5fdf17aa7b38e94b140';

/// Seasons and episodes from the provider, cached for a few minutes.

final class SeriesDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SeriesDetails>, Series> {
  SeriesDetailsFamily._()
    : super(
        retry: null,
        name: r'seriesDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Seasons and episodes from the provider, cached for a few minutes.

  SeriesDetailsProvider call(Series series) =>
      SeriesDetailsProvider._(argument: series, from: this);

  @override
  String toString() => r'seriesDetailsProvider';
}

/// Favorite and last episode of a series for the active profile.

@ProviderFor(seriesState)
final seriesStateProvider = SeriesStateFamily._();

/// Favorite and last episode of a series for the active profile.

final class SeriesStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SeriesState>,
          SeriesState,
          Stream<SeriesState>
        >
    with $FutureModifier<SeriesState>, $StreamProvider<SeriesState> {
  /// Favorite and last episode of a series for the active profile.
  SeriesStateProvider._({
    required SeriesStateFamily super.from,
    required Series super.argument,
  }) : super(
         retry: null,
         name: r'seriesStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesStateHash();

  @override
  String toString() {
    return r'seriesStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<SeriesState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SeriesState> create(Ref ref) {
    final argument = this.argument as Series;
    return seriesState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesStateHash() => r'70186ed9c55405989a75961840a56999d2b2af99';

/// Favorite and last episode of a series for the active profile.

final class SeriesStateFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SeriesState>, Series> {
  SeriesStateFamily._()
    : super(
        retry: null,
        name: r'seriesStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Favorite and last episode of a series for the active profile.

  SeriesStateProvider call(Series series) =>
      SeriesStateProvider._(argument: series, from: this);

  @override
  String toString() => r'seriesStateProvider';
}

/// Episode states of a series for the active profile, by episode id.

@ProviderFor(episodeStates)
final episodeStatesProvider = EpisodeStatesFamily._();

/// Episode states of a series for the active profile, by episode id.

final class EpisodeStatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, EpisodeState>>,
          Map<int, EpisodeState>,
          Stream<Map<int, EpisodeState>>
        >
    with
        $FutureModifier<Map<int, EpisodeState>>,
        $StreamProvider<Map<int, EpisodeState>> {
  /// Episode states of a series for the active profile, by episode id.
  EpisodeStatesProvider._({
    required EpisodeStatesFamily super.from,
    required Series super.argument,
  }) : super(
         retry: null,
         name: r'episodeStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeStatesHash();

  @override
  String toString() {
    return r'episodeStatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<int, EpisodeState>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, EpisodeState>> create(Ref ref) {
    final argument = this.argument as Series;
    return episodeStates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeStatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeStatesHash() => r'39cc4967899424ec2546659e59db65c54c622e08';

/// Episode states of a series for the active profile, by episode id.

final class EpisodeStatesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<int, EpisodeState>>, Series> {
  EpisodeStatesFamily._()
    : super(
        retry: null,
        name: r'episodeStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Episode states of a series for the active profile, by episode id.

  EpisodeStatesProvider call(Series series) =>
      EpisodeStatesProvider._(argument: series, from: this);

  @override
  String toString() => r'episodeStatesProvider';
}

/// Playback URL of an episode.

@ProviderFor(episodeStreamUrl)
final episodeStreamUrlProvider = EpisodeStreamUrlFamily._();

/// Playback URL of an episode.

final class EpisodeStreamUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Playback URL of an episode.
  EpisodeStreamUrlProvider._({
    required EpisodeStreamUrlFamily super.from,
    required (Series, Episode) super.argument,
  }) : super(
         retry: null,
         name: r'episodeStreamUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeStreamUrlHash();

  @override
  String toString() {
    return r'episodeStreamUrlProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as (Series, Episode);
    return episodeStreamUrl(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeStreamUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeStreamUrlHash() => r'0d5df8a5e2fd92e05591b1fa1ac5c7570597cfa0';

/// Playback URL of an episode.

final class EpisodeStreamUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, (Series, Episode)> {
  EpisodeStreamUrlFamily._()
    : super(
        retry: null,
        name: r'episodeStreamUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Playback URL of an episode.

  EpisodeStreamUrlProvider call(Series series, Episode episode) =>
      EpisodeStreamUrlProvider._(argument: (series, episode), from: this);

  @override
  String toString() => r'episodeStreamUrlProvider';
}
