// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(epgLoadedAt)
final epgLoadedAtProvider = EpgLoadedAtFamily._();

final class EpgLoadedAtProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  EpgLoadedAtProvider._({
    required EpgLoadedAtFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'epgLoadedAtProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$epgLoadedAtHash();

  @override
  String toString() {
    return r'epgLoadedAtProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    final argument = this.argument as String;
    return epgLoadedAt(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpgLoadedAtProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$epgLoadedAtHash() => r'030d5af4cd42f7ffe1c236337fd85b3ec9ac2063';

final class EpgLoadedAtFamily extends $Family
    with $FunctionalFamilyOverride<Stream<DateTime?>, String> {
  EpgLoadedAtFamily._()
    : super(
        retry: null,
        name: r'epgLoadedAtProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EpgLoadedAtProvider call(String playlistId) =>
      EpgLoadedAtProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'epgLoadedAtProvider';
}

/// Programmes of a channel in the window starting at [chunkStart]. Reloaded
/// when a guide load completes.

@ProviderFor(guideProgrammes)
final guideProgrammesProvider = GuideProgrammesFamily._();

/// Programmes of a channel in the window starting at [chunkStart]. Reloaded
/// when a guide load completes.

final class GuideProgrammesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EpgEntry>>,
          List<EpgEntry>,
          FutureOr<List<EpgEntry>>
        >
    with $FutureModifier<List<EpgEntry>>, $FutureProvider<List<EpgEntry>> {
  /// Programmes of a channel in the window starting at [chunkStart]. Reloaded
  /// when a guide load completes.
  GuideProgrammesProvider._({
    required GuideProgrammesFamily super.from,
    required (String, String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'guideProgrammesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideProgrammesHash();

  @override
  String toString() {
    return r'guideProgrammesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<EpgEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EpgEntry>> create(Ref ref) {
    final argument = this.argument as (String, String, DateTime);
    return guideProgrammes(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is GuideProgrammesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideProgrammesHash() => r'507d1e345186d36297f6658720f7e0eeb3aa946a';

/// Programmes of a channel in the window starting at [chunkStart]. Reloaded
/// when a guide load completes.

final class GuideProgrammesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<EpgEntry>>,
          (String, String, DateTime)
        > {
  GuideProgrammesFamily._()
    : super(
        retry: null,
        name: r'guideProgrammesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Programmes of a channel in the window starting at [chunkStart]. Reloaded
  /// when a guide load completes.

  GuideProgrammesProvider call(
    String playlistId,
    String channelKey,
    DateTime chunkStart,
  ) => GuideProgrammesProvider._(
    argument: (playlistId, channelKey, chunkStart),
    from: this,
  );

  @override
  String toString() => r'guideProgrammesProvider';
}
