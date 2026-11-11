// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profiles)
final profilesProvider = ProfilesProvider._();

final class ProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          Stream<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $StreamProvider<List<Profile>> {
  ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  $StreamProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Profile>> create(Ref ref) {
    return profiles(ref);
  }
}

String _$profilesHash() => r'44e192fd10645ad8bb0a6a96197d421f2e23b4e2';

/// The profile currently using the app. Kept in memory only: after a
/// restart the user picks a profile again unless a default profile is set.

@ProviderFor(ActiveProfileId)
final activeProfileIdProvider = ActiveProfileIdProvider._();

/// The profile currently using the app. Kept in memory only: after a
/// restart the user picks a profile again unless a default profile is set.
final class ActiveProfileIdProvider
    extends $NotifierProvider<ActiveProfileId, String?> {
  /// The profile currently using the app. Kept in memory only: after a
  /// restart the user picks a profile again unless a default profile is set.
  ActiveProfileIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProfileIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProfileIdHash();

  @$internal
  @override
  ActiveProfileId create() => ActiveProfileId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeProfileIdHash() => r'10ff0347b8c809609bd5fc7ce9d92f8f054fe28f';

/// The profile currently using the app. Kept in memory only: after a
/// restart the user picks a profile again unless a default profile is set.

abstract class _$ActiveProfileId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(activeProfile)
final activeProfileProvider = ActiveProfileProvider._();

final class ActiveProfileProvider
    extends $FunctionalProvider<Profile?, Profile?, Profile?>
    with $Provider<Profile?> {
  ActiveProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeProfileHash();

  @$internal
  @override
  $ProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Profile? create(Ref ref) {
    return activeProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Profile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Profile?>(value),
    );
  }
}

String _$activeProfileHash() => r'e311014fae917f89cae375a6ff8d649c32b5f307';
