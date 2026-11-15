import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../playlists/data/playlist_data_providers.dart';
import '../domain/log_report_sender.dart';
import 'telegram_log_report_sender.dart';

part 'diagnostics_data_providers.g.dart';

@Riverpod(keepAlive: true)
LogReportSender logReportSender(Ref ref) =>
    TelegramLogReportSender(ref.watch(httpClientProvider));
