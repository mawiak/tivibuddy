// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tv_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Playlist shown in the live section. Defaults to the first playlist of the
/// active profile.

@ProviderFor(LivePlaylistSelection)
final livePlaylistSelectionProvider = LivePlaylistSelectionProvider._();

/// Playlist shown in the live section. Defaults to the first playlist of the
/// active profile.
final class LivePlaylistSelectionProvider
    extends $NotifierProvider<LivePlaylistSelection, Playlist?> {
  /// Playlist shown in the live section. Defaults to the first playlist of the
  /// active profile.
  LivePlaylistSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'livePlaylistSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$livePlaylistSelectionHash();

  @$internal
  @override
  LivePlaylistSelection create() => LivePlaylistSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Playlist? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Playlist?>(value),
    );
  }
}

String _$livePlaylistSelectionHash() =>
    r'c7fbe932365f214faa10d97d0a231dfc9349cea9';

/// Playlist shown in the live section. Defaults to the first playlist of the
/// active profile.

abstract class _$LivePlaylistSelection extends $Notifier<Playlist?> {
  Playlist? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Playlist?, Playlist?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Playlist?, Playlist?>,
              Playlist?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Selected category of a playlist, or null for all channels.

@ProviderFor(LiveCategorySelection)
final liveCategorySelectionProvider = LiveCategorySelectionFamily._();

/// Selected category of a playlist, or null for all channels.
final class LiveCategorySelectionProvider
    extends $NotifierProvider<LiveCategorySelection, String?> {
  /// Selected category of a playlist, or null for all channels.
  LiveCategorySelectionProvider._({
    required LiveCategorySelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveCategorySelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveCategorySelectionHash();

  @override
  String toString() {
    return r'liveCategorySelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveCategorySelection create() => LiveCategorySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveCategorySelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveCategorySelectionHash() =>
    r'7df0bc3bb8851c8a18502771c4c6b094f3fc5747';

/// Selected category of a playlist, or null for all channels.

final class LiveCategorySelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveCategorySelection,
          String?,
          String?,
          String?,
          String
        > {
  LiveCategorySelectionFamily._()
    : super(
        retry: null,
        name: r'liveCategorySelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Selected category of a playlist, or null for all channels.

  LiveCategorySelectionProvider call(String playlistId) =>
      LiveCategorySelectionProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'liveCategorySelectionProvider';
}

/// Selected category of a playlist, or null for all channels.

abstract class _$LiveCategorySelection extends $Notifier<String?> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  String? build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(liveCategories)
final liveCategoriesProvider = LiveCategoriesFamily._();

final class LiveCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LiveCategory>>,
          List<LiveCategory>,
          Stream<List<LiveCategory>>
        >
    with
        $FutureModifier<List<LiveCategory>>,
        $StreamProvider<List<LiveCategory>> {
  LiveCategoriesProvider._({
    required LiveCategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveCategoriesHash();

  @override
  String toString() {
    return r'liveCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LiveCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LiveCategory>> create(Ref ref) {
    final argument = this.argument as String;
    return liveCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveCategoriesHash() => r'e63af991be92d038069ba6d04294c38db13eb5c1';

final class LiveCategoriesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LiveCategory>>, String> {
  LiveCategoriesFamily._()
    : super(
        retry: null,
        name: r'liveCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveCategoriesProvider call(String playlistId) =>
      LiveCategoriesProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'liveCategoriesProvider';
}

/// Channels of a category (or all channels) as a lazily loaded list. A new
/// list is created when the number of channels changes, for example while
/// the catalog is loading.

@ProviderFor(liveChannelList)
final liveChannelListProvider = LiveChannelListFamily._();

/// Channels of a category (or all channels) as a lazily loaded list. A new
/// list is created when the number of channels changes, for example while
/// the catalog is loading.

final class LiveChannelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<PagedList<LiveChannel>>,
          PagedList<LiveChannel>,
          FutureOr<PagedList<LiveChannel>>
        >
    with
        $FutureModifier<PagedList<LiveChannel>>,
        $FutureProvider<PagedList<LiveChannel>> {
  /// Channels of a category (or all channels) as a lazily loaded list. A new
  /// list is created when the number of channels changes, for example while
  /// the catalog is loading.
  LiveChannelListProvider._({
    required LiveChannelListFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'liveChannelListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveChannelListHash();

  @override
  String toString() {
    return r'liveChannelListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PagedList<LiveChannel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PagedList<LiveChannel>> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return liveChannelList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveChannelListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveChannelListHash() => r'8e6eaac05c5b1dc61afa8e244173542e0945f7d4';

/// Channels of a category (or all channels) as a lazily loaded list. A new
/// list is created when the number of channels changes, for example while
/// the catalog is loading.

final class LiveChannelListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PagedList<LiveChannel>>,
          (String, String?)
        > {
  LiveChannelListFamily._()
    : super(
        retry: null,
        name: r'liveChannelListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Channels of a category (or all channels) as a lazily loaded list. A new
  /// list is created when the number of channels changes, for example while
  /// the catalog is loading.

  LiveChannelListProvider call(String playlistId, String? categoryId) =>
      LiveChannelListProvider._(argument: (playlistId, categoryId), from: this);

  @override
  String toString() => r'liveChannelListProvider';
}

/// Playlist data plus password from secure storage.

@ProviderFor(playlistAccess)
final playlistAccessProvider = PlaylistAccessFamily._();

/// Playlist data plus password from secure storage.

final class PlaylistAccessProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaylistAccess>,
          PlaylistAccess,
          FutureOr<PlaylistAccess>
        >
    with $FutureModifier<PlaylistAccess>, $FutureProvider<PlaylistAccess> {
  /// Playlist data plus password from secure storage.
  PlaylistAccessProvider._({
    required PlaylistAccessFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playlistAccessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistAccessHash();

  @override
  String toString() {
    return r'playlistAccessProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlaylistAccess> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlaylistAccess> create(Ref ref) {
    final argument = this.argument as String;
    return playlistAccess(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaylistAccessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistAccessHash() => r'0118a02fae33eeb33df533a5b5251936f8b739d3';

/// Playlist data plus password from secure storage.

final class PlaylistAccessFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlaylistAccess>, String> {
  PlaylistAccessFamily._()
    : super(
        retry: null,
        name: r'playlistAccessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Playlist data plus password from secure storage.

  PlaylistAccessProvider call(String playlistId) =>
      PlaylistAccessProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'playlistAccessProvider';
}

/// Current and next programme of a channel. Cached for a few minutes and
/// refreshed when the current programme ends.

@ProviderFor(nowNext)
final nowNextProvider = NowNextFamily._();

/// Current and next programme of a channel. Cached for a few minutes and
/// refreshed when the current programme ends.

final class NowNextProvider
    extends $FunctionalProvider<AsyncValue<NowNext>, NowNext, FutureOr<NowNext>>
    with $FutureModifier<NowNext>, $FutureProvider<NowNext> {
  /// Current and next programme of a channel. Cached for a few minutes and
  /// refreshed when the current programme ends.
  NowNextProvider._({
    required NowNextFamily super.from,
    required LiveChannel super.argument,
  }) : super(
         retry: null,
         name: r'nowNextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nowNextHash();

  @override
  String toString() {
    return r'nowNextProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NowNext> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NowNext> create(Ref ref) {
    final argument = this.argument as LiveChannel;
    return nowNext(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NowNextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nowNextHash() => r'0454a75f1f36a3d63462effdddf9169458989592';

/// Current and next programme of a channel. Cached for a few minutes and
/// refreshed when the current programme ends.

final class NowNextFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NowNext>, LiveChannel> {
  NowNextFamily._()
    : super(
        retry: null,
        name: r'nowNextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Current and next programme of a channel. Cached for a few minutes and
  /// refreshed when the current programme ends.

  NowNextProvider call(LiveChannel channel) =>
      NowNextProvider._(argument: channel, from: this);

  @override
  String toString() => r'nowNextProvider';
}

/// Playback URL of a channel.

@ProviderFor(liveStreamUrl)
final liveStreamUrlProvider = LiveStreamUrlFamily._();

/// Playback URL of a channel.

final class LiveStreamUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Playback URL of a channel.
  LiveStreamUrlProvider._({
    required LiveStreamUrlFamily super.from,
    required LiveChannel super.argument,
  }) : super(
         retry: null,
         name: r'liveStreamUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveStreamUrlHash();

  @override
  String toString() {
    return r'liveStreamUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as LiveChannel;
    return liveStreamUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveStreamUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveStreamUrlHash() => r'502c53e7e90430ccba1d6e253e50e5bdb9144dce';

/// Playback URL of a channel.

final class LiveStreamUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, LiveChannel> {
  LiveStreamUrlFamily._()
    : super(
        retry: null,
        name: r'liveStreamUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Playback URL of a channel.

  LiveStreamUrlProvider call(LiveChannel channel) =>
      LiveStreamUrlProvider._(argument: channel, from: this);

  @override
  String toString() => r'liveStreamUrlProvider';
}
