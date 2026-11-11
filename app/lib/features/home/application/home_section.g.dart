// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_section.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedHomeSection)
final selectedHomeSectionProvider = SelectedHomeSectionProvider._();

final class SelectedHomeSectionProvider
    extends $NotifierProvider<SelectedHomeSection, HomeSection> {
  SelectedHomeSectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedHomeSectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedHomeSectionHash();

  @$internal
  @override
  SelectedHomeSection create() => SelectedHomeSection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeSection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeSection>(value),
    );
  }
}

String _$selectedHomeSectionHash() =>
    r'508b229157745e83d94daa8141a88ba112d307a4';

abstract class _$SelectedHomeSection extends $Notifier<HomeSection> {
  HomeSection build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeSection, HomeSection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeSection, HomeSection>,
              HomeSection,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
