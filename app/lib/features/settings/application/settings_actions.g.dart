// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsActions)
final settingsActionsProvider = SettingsActionsProvider._();

final class SettingsActionsProvider
    extends
        $FunctionalProvider<SettingsActions, SettingsActions, SettingsActions>
    with $Provider<SettingsActions> {
  SettingsActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsActionsHash();

  @$internal
  @override
  $ProviderElement<SettingsActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsActions create(Ref ref) {
    return settingsActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsActions>(value),
    );
  }
}

String _$settingsActionsHash() => r'24ad85c2ed0dbf727511fda6962e2ec90bbae954';
