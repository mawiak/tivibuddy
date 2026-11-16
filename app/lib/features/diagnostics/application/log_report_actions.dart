import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/logging/app_log.dart';
import '../../../core/logging/redact.dart';
import '../../player/application/player_settings_providers.dart';
import '../data/device_description.dart';
import '../data/diagnostics_data_providers.dart';

part 'log_report_actions.g.dart';

@Riverpod(keepAlive: true)
LogReportActions logReportActions(Ref ref) => LogReportActions(ref);

/// Sends a diagnostic report on request of a tester, so problems on devices
/// we do not have can be analysed without asking back.
class LogReportActions {
  LogReportActions(this._ref);

  final Ref _ref;

  bool get canSend => _ref.read(logReportSenderProvider).isConfigured;

  /// Sends the report with the tester's [description] of the problem.
  /// Throws a `LogReportException` when it could not be delivered.
  Future<void> send(String description) async {
    final report = await buildReport(description);
    final now = DateTime.now();
    final stamp = now
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(RegExp('[-:]'), '')
        .replaceFirst('T', '-');
    await _ref
        .read(logReportSenderProvider)
        .send(
          fileName: 'tivibuddy-$stamp.log',
          report: report,
          caption: description.trim().isEmpty
              ? 'TiviBuddy log'
              : redactCredentials(description.trim()),
        );
  }

  Future<String> buildReport(String description) async {
    final package = await PackageInfo.fromPlatform();
    final player = _ref.read(playerSettingsControllerProvider);
    final lines = [
      'TiviBuddy ${package.version}+${package.buildNumber}',
      'time: ${DateTime.now().toIso8601String()}',
      'description: ${redactCredentials(description.trim())}',
      ...await describeDevice(),
      'decoder: ${player.decoder.name}',
      'passthrough: ${player.passthrough.map((f) => f.mpvName).join(',')}',
      '',
      '--- log ---',
      ...appLog.lines,
      '',
      '--- platform log (warnings, errors, renderer) ---',
      ...(await platformLogExcerpt()).map(redactCredentials),
    ];
    return lines.join('\n');
  }
}
