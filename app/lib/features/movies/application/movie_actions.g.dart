// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(movieActions)
final movieActionsProvider = MovieActionsProvider._();

final class MovieActionsProvider
    extends $FunctionalProvider<MovieActions, MovieActions, MovieActions>
    with $Provider<MovieActions> {
  MovieActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movieActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movieActionsHash();

  @$internal
  @override
  $ProviderElement<MovieActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MovieActions create(Ref ref) {
    return movieActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovieActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovieActions>(value),
    );
  }
}

String _$movieActionsHash() => r'dc334708f1c812b986eb9162be5d36412dc1b241';
