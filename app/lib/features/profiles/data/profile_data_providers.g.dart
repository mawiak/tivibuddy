// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'9f979afb3a9ca342b2a8f56235f5efc5fab09483';

@ProviderFor(avatarImageSource)
final avatarImageSourceProvider = AvatarImageSourceProvider._();

final class AvatarImageSourceProvider
    extends
        $FunctionalProvider<
          AvatarImageSource,
          AvatarImageSource,
          AvatarImageSource
        >
    with $Provider<AvatarImageSource> {
  AvatarImageSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarImageSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarImageSourceHash();

  @$internal
  @override
  $ProviderElement<AvatarImageSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AvatarImageSource create(Ref ref) {
    return avatarImageSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarImageSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarImageSource>(value),
    );
  }
}

String _$avatarImageSourceHash() => r'93f56b47c0a65f488faef78d7580c6a7675fa089';
