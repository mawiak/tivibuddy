// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the series catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

@ProviderFor(SeriesCatalogController)
final seriesCatalogControllerProvider = SeriesCatalogControllerFamily._();

/// Loads the series catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.
final class SeriesCatalogControllerProvider
    extends $NotifierProvider<SeriesCatalogController, SeriesCatalogStatus> {
  /// Loads the series catalog of a playlist into the local database (DATA-1,
  /// DATA-2). The previous catalog stays visible while a refresh runs.
  SeriesCatalogControllerProvider._({
    required SeriesCatalogControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'seriesCatalogControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seriesCatalogControllerHash();

  @override
  String toString() {
    return r'seriesCatalogControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeriesCatalogController create() => SeriesCatalogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeriesCatalogStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeriesCatalogStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesCatalogControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seriesCatalogControllerHash() =>
    r'3e321ad4e9e5c1df785d7ab04beb6389aa14ccaa';

/// Loads the series catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

final class SeriesCatalogControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SeriesCatalogController,
          SeriesCatalogStatus,
          SeriesCatalogStatus,
          SeriesCatalogStatus,
          String
        > {
  SeriesCatalogControllerFamily._()
    : super(
        retry: null,
        name: r'seriesCatalogControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Loads the series catalog of a playlist into the local database (DATA-1,
  /// DATA-2). The previous catalog stays visible while a refresh runs.

  SeriesCatalogControllerProvider call(String playlistId) =>
      SeriesCatalogControllerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'seriesCatalogControllerProvider';
}

/// Loads the series catalog of a playlist into the local database (DATA-1,
/// DATA-2). The previous catalog stays visible while a refresh runs.

abstract class _$SeriesCatalogController
    extends $Notifier<SeriesCatalogStatus> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  SeriesCatalogStatus build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SeriesCatalogStatus, SeriesCatalogStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SeriesCatalogStatus, SeriesCatalogStatus>,
              SeriesCatalogStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
