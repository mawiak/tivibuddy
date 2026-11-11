// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epg_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads the programme guide of a playlist into the local database
/// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
/// from shortly before now up to the configured number of days ahead.

@ProviderFor(EpgController)
final epgControllerProvider = EpgControllerFamily._();

/// Loads the programme guide of a playlist into the local database
/// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
/// from shortly before now up to the configured number of days ahead.
final class EpgControllerProvider
    extends $NotifierProvider<EpgController, GuideStatus> {
  /// Loads the programme guide of a playlist into the local database
  /// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
  /// from shortly before now up to the configured number of days ahead.
  EpgControllerProvider._({
    required EpgControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'epgControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$epgControllerHash();

  @override
  String toString() {
    return r'epgControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EpgController create() => EpgController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EpgControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$epgControllerHash() => r'5caecb37fdc340d12c96c494ed4d2c0f21304222';

/// Loads the programme guide of a playlist into the local database
/// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
/// from shortly before now up to the configured number of days ahead.

final class EpgControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EpgController,
          GuideStatus,
          GuideStatus,
          GuideStatus,
          String
        > {
  EpgControllerFamily._()
    : super(
        retry: null,
        name: r'epgControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Loads the programme guide of a playlist into the local database
  /// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
  /// from shortly before now up to the configured number of days ahead.

  EpgControllerProvider call(String playlistId) =>
      EpgControllerProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'epgControllerProvider';
}

/// Loads the programme guide of a playlist into the local database
/// (LIVE-2, DATA-1). Only programmes of channels in the catalog are kept,
/// from shortly before now up to the configured number of days ahead.

abstract class _$EpgController extends $Notifier<GuideStatus> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  GuideStatus build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GuideStatus, GuideStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GuideStatus, GuideStatus>,
              GuideStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
