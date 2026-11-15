// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_report_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(logReportActions)
final logReportActionsProvider = LogReportActionsProvider._();

final class LogReportActionsProvider
    extends
        $FunctionalProvider<
          LogReportActions,
          LogReportActions,
          LogReportActions
        >
    with $Provider<LogReportActions> {
  LogReportActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logReportActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logReportActionsHash();

  @$internal
  @override
  $ProviderElement<LogReportActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogReportActions create(Ref ref) {
    return logReportActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogReportActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogReportActions>(value),
    );
  }
}

String _$logReportActionsHash() => r'48b1be22e2e9c8dc30bacb20adc3b93f71ccad71';
