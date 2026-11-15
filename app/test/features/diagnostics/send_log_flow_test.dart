import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tivibuddy/core/logging/app_log.dart';
import 'package:tivibuddy/features/diagnostics/data/diagnostics_data_providers.dart';
import 'package:tivibuddy/features/diagnostics/domain/log_report_sender.dart';
import 'package:tivibuddy/features/home/application/home_section.dart';
import 'package:tivibuddy/features/profiles/data/drift_profile_repository.dart';
import 'package:tivibuddy/features/profiles/domain/profile.dart';
import 'package:tivibuddy/features/settings/data/drift_device_settings_repository.dart';

import '../../helpers/test_app.dart';

class FakeLogReportSender implements LogReportSender {
  final sent = <({String fileName, String report, String caption})>[];
  bool fail = false;

  @override
  bool get isConfigured => true;

  @override
  Future<void> send({
    required String fileName,
    required String report,
    required String caption,
  }) async {
    if (fail) throw const LogReportException('offline');
    sent.add((fileName: fileName, report: report, caption: caption));
  }
}

void main() {
  testWidgets('a tester sends the log with a description', (tester) async {
    final sender = FakeLogReportSender();
    PackageInfo.setMockInitialValues(
      appName: 'TiviBuddy',
      packageName: 'io.github.mawiak.tivibuddy',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final db = createTestDatabase();
    await tester.runAsync(() async {
      final profile = await DriftProfileRepository(db)
          .create(name: 'Anna', avatar: const PresetAvatar(0));
      await DriftDeviceSettingsRepository(db).setDefaultProfileId(profile.id);
    });
    final container = await pumpFullApp(
      tester,
      database: db,
      overrides: [logReportSenderProvider.overrideWithValue(sender)],
    );
    container
        .read(selectedHomeSectionProvider.notifier)
        .select(HomeSection.settings);
    await settle(tester);
    appLog.add('player open: http://tv/live/anna/s3cret/1.ts');

    await tester.scrollUntilVisible(find.text('Send log to developer'), 100);
    await tester.ensureVisible(find.text('Send log to developer'));
    await settle(tester);
    await tester.tap(find.text('Send log to developer'));
    await settle(tester);

    await tester.enterText(find.byType(EditableText), 'ZDF stutters');
    await tester.tap(find.text('Send'));
    // Device details come from platform plugins, outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await settle(tester);

    expect(find.text('Log sent. Thank you!'), findsOneWidget);
    expect(sender.sent, hasLength(1));
    final report = sender.sent.single;
    expect(report.caption, 'ZDF stutters');
    expect(report.fileName, startsWith('tivibuddy-'));
    expect(report.report, contains('description: ZDF stutters'));
    expect(report.report, contains('decoder: hardware'));
    expect(report.report, contains('/live/***/***/1.ts'));
    expect(report.report, isNot(contains('s3cret')));
  });
}
