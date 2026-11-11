// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(seriesActions)
final seriesActionsProvider = SeriesActionsProvider._();

final class SeriesActionsProvider
    extends $FunctionalProvider<SeriesActions, SeriesActions, SeriesActions>
    with $Provider<SeriesActions> {
  SeriesActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seriesActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seriesActionsHash();

  @$internal
  @override
  $ProviderElement<SeriesActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeriesActions create(Ref ref) {
    return seriesActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeriesActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeriesActions>(value),
    );
  }
}

String _$seriesActionsHash() => r'a7233565514a3fcd610e9f8cf99c4fed7b839007';
