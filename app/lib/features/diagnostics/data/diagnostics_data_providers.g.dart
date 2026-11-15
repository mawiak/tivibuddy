// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnostics_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(logReportSender)
final logReportSenderProvider = LogReportSenderProvider._();

final class LogReportSenderProvider
    extends
        $FunctionalProvider<LogReportSender, LogReportSender, LogReportSender>
    with $Provider<LogReportSender> {
  LogReportSenderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logReportSenderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logReportSenderHash();

  @$internal
  @override
  $ProviderElement<LogReportSender> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogReportSender create(Ref ref) {
    return logReportSender(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogReportSender value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogReportSender>(value),
    );
  }
}

String _$logReportSenderHash() => r'70b28b8c99e25fa92b701d13b1e0d1f9a53deb95';
