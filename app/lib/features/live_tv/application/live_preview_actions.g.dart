// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_preview_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(livePreviewActions)
final livePreviewActionsProvider = LivePreviewActionsProvider._();

final class LivePreviewActionsProvider
    extends
        $FunctionalProvider<
          LivePreviewActions,
          LivePreviewActions,
          LivePreviewActions
        >
    with $Provider<LivePreviewActions> {
  LivePreviewActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'livePreviewActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$livePreviewActionsHash();

  @$internal
  @override
  $ProviderElement<LivePreviewActions> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LivePreviewActions create(Ref ref) {
    return livePreviewActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LivePreviewActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LivePreviewActions>(value),
    );
  }
}

String _$livePreviewActionsHash() =>
    r'4648d114e2051b776dbf5fcba8db57ac27ae67eb';
