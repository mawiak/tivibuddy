// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_sort_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sort order of one list of a VOD section, like common IPTV players sort
/// per category. Kept as a device setting.

@ProviderFor(VodSortSelection)
final vodSortSelectionProvider = VodSortSelectionFamily._();

/// Sort order of one list of a VOD section, like common IPTV players sort
/// per category. Kept as a device setting.
final class VodSortSelectionProvider
    extends $NotifierProvider<VodSortSelection, VodSort> {
  /// Sort order of one list of a VOD section, like common IPTV players sort
  /// per category. Kept as a device setting.
  VodSortSelectionProvider._({
    required VodSortSelectionFamily super.from,
    required (VodSection, String) super.argument,
  }) : super(
         retry: null,
         name: r'vodSortSelectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vodSortSelectionHash();

  @override
  String toString() {
    return r'vodSortSelectionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VodSortSelection create() => VodSortSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VodSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VodSort>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VodSortSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vodSortSelectionHash() => r'0219cb174a14e623501aa18bb25206e01bdc7bb9';

/// Sort order of one list of a VOD section, like common IPTV players sort
/// per category. Kept as a device setting.

final class VodSortSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          VodSortSelection,
          VodSort,
          VodSort,
          VodSort,
          (VodSection, String)
        > {
  VodSortSelectionFamily._()
    : super(
        retry: null,
        name: r'vodSortSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Sort order of one list of a VOD section, like common IPTV players sort
  /// per category. Kept as a device setting.

  VodSortSelectionProvider call(VodSection section, String listKey) =>
      VodSortSelectionProvider._(argument: (section, listKey), from: this);

  @override
  String toString() => r'vodSortSelectionProvider';
}

/// Sort order of one list of a VOD section, like common IPTV players sort
/// per category. Kept as a device setting.

abstract class _$VodSortSelection extends $Notifier<VodSort> {
  late final _$args = ref.$arg as (VodSection, String);
  VodSection get section => _$args.$1;
  String get listKey => _$args.$2;

  VodSort build(VodSection section, String listKey);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VodSort, VodSort>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VodSort, VodSort>,
              VodSort,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
