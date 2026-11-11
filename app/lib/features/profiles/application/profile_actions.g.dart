// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Use cases around profiles. Widgets call these instead of repositories.

@ProviderFor(profileActions)
final profileActionsProvider = ProfileActionsProvider._();

/// Use cases around profiles. Widgets call these instead of repositories.

final class ProfileActionsProvider
    extends $FunctionalProvider<ProfileActions, ProfileActions, ProfileActions>
    with $Provider<ProfileActions> {
  /// Use cases around profiles. Widgets call these instead of repositories.
  ProfileActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileActionsHash();

  @$internal
  @override
  $ProviderElement<ProfileActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileActions create(Ref ref) {
    return profileActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileActions>(value),
    );
  }
}

String _$profileActionsHash() => r'533121528e4ba1082ebe1b552d2ab1cd745199e9';
