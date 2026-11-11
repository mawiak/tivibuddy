// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the live catalog of a playlist from the provider into the local
/// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
/// while a refresh runs.

@ProviderFor(LiveCatalogController)
final liveCatalogControllerProvider = LiveCatalogControllerFamily._();

/// Loads the live catalog of a playlist from the provider into the local
/// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
/// while a refresh runs.
final class LiveCatalogControllerProvider
    extends $NotifierProvider<LiveCatalogController, LiveCatalogStatus> {
  /// Loads the live catalog of a playlist from the provider into the local
  /// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
  /// while a refresh runs.
  LiveCatalogControllerProvider._({
    required LiveCatalogControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveCatalogControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveCatalogControllerHash();

  @override
  String toString() {
    return r'liveCatalogControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveCatalogController create() => LiveCatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveCatalogStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveCatalogStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveCatalogControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveCatalogControllerHash() =>
    r'48b7d59b8a3a9793b3177da43475f2332f9a9a94';

/// Loads the live catalog of a playlist from the provider into the local
/// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
/// while a refresh runs.

final class LiveCatalogControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveCatalogController,
          LiveCatalogStatus,
          LiveCatalogStatus,
          LiveCatalogStatus,
          String
        > {
  LiveCatalogControllerFamily._()
    : super(
        retry: null,
        name: r'liveCatalogControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Loads the live catalog of a playlist from the provider into the local
  /// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
  /// while a refresh runs.

  LiveCatalogControllerProvider call(String playlistId) =>
      LiveCatalogControllerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'liveCatalogControllerProvider';
}

/// Loads the live catalog of a playlist from the provider into the local
/// database (DATA-1, DATA-2). The UI keeps showing the previous catalog
/// while a refresh runs.

abstract class _$LiveCatalogController extends $Notifier<LiveCatalogStatus> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  LiveCatalogStatus build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LiveCatalogStatus, LiveCatalogStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveCatalogStatus, LiveCatalogStatus>,
              LiveCatalogStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
