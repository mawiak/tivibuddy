// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(httpClient)
final httpClientProvider = HttpClientProvider._();

final class HttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  HttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return httpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$httpClientHash() => r'7ec49beae0f15115de79f9aa98dbd250130e26d8';

@ProviderFor(playlistRepository)
final playlistRepositoryProvider = PlaylistRepositoryProvider._();

final class PlaylistRepositoryProvider
    extends
        $FunctionalProvider<
          PlaylistRepository,
          PlaylistRepository,
          PlaylistRepository
        >
    with $Provider<PlaylistRepository> {
  PlaylistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlaylistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaylistRepository create(Ref ref) {
    return playlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaylistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaylistRepository>(value),
    );
  }
}

String _$playlistRepositoryHash() =>
    r'2ff2b093d55756e17b1b183bf7f1f9f31bccb67d';

@ProviderFor(credentialStore)
final credentialStoreProvider = CredentialStoreProvider._();

final class CredentialStoreProvider
    extends
        $FunctionalProvider<CredentialStore, CredentialStore, CredentialStore>
    with $Provider<CredentialStore> {
  CredentialStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialStoreHash();

  @$internal
  @override
  $ProviderElement<CredentialStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CredentialStore create(Ref ref) {
    return credentialStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CredentialStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CredentialStore>(value),
    );
  }
}

String _$credentialStoreHash() => r'ee074e01b4db4369f8af6b3e5831be356bbf3f80';

@ProviderFor(xtreamApiClient)
final xtreamApiClientProvider = XtreamApiClientProvider._();

final class XtreamApiClientProvider
    extends
        $FunctionalProvider<XtreamApiClient, XtreamApiClient, XtreamApiClient>
    with $Provider<XtreamApiClient> {
  XtreamApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xtreamApiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xtreamApiClientHash();

  @$internal
  @override
  $ProviderElement<XtreamApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  XtreamApiClient create(Ref ref) {
    return xtreamApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XtreamApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XtreamApiClient>(value),
    );
  }
}

String _$xtreamApiClientHash() => r'aa3ab41ec6780156c93c68b74c80fcc95a7d7db6';

/// Connection tester for each source type (PL-3).

@ProviderFor(connectionTester)
final connectionTesterProvider = ConnectionTesterFamily._();

/// Connection tester for each source type (PL-3).

final class ConnectionTesterProvider
    extends
        $FunctionalProvider<
          ConnectionTester,
          ConnectionTester,
          ConnectionTester
        >
    with $Provider<ConnectionTester> {
  /// Connection tester for each source type (PL-3).
  ConnectionTesterProvider._({
    required ConnectionTesterFamily super.from,
    required PlaylistType super.argument,
  }) : super(
         retry: null,
         name: r'connectionTesterProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$connectionTesterHash();

  @override
  String toString() {
    return r'connectionTesterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ConnectionTester> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectionTester create(Ref ref) {
    final argument = this.argument as PlaylistType;
    return connectionTester(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionTester value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionTester>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectionTesterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$connectionTesterHash() => r'524608b3c7da9340dac9a5580c01b7943e28aad4';

/// Connection tester for each source type (PL-3).

final class ConnectionTesterFamily extends $Family
    with $FunctionalFamilyOverride<ConnectionTester, PlaylistType> {
  ConnectionTesterFamily._()
    : super(
        retry: null,
        name: r'connectionTesterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Connection tester for each source type (PL-3).

  ConnectionTesterProvider call(PlaylistType type) =>
      ConnectionTesterProvider._(argument: type, from: this);

  @override
  String toString() => r'connectionTesterProvider';
}
