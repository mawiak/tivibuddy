import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/log_report_sender.dart';

/// Sends reports as documents to a Telegram bot chat of the developer.
///
/// Bot token and chat id are only compiled into tester builds
/// (`--dart-define=TELEGRAM_BOT_TOKEN=... --dart-define=TELEGRAM_CHAT_ID=...`,
/// see `tool/build_tester_apk.sh`); they never live in the repository.
class TelegramLogReportSender implements LogReportSender {
  TelegramLogReportSender(this._client);

  final http.Client _client;

  static const _token = String.fromEnvironment('TELEGRAM_BOT_TOKEN');
  static const _chatId = String.fromEnvironment('TELEGRAM_CHAT_ID');

  @override
  bool get isConfigured => _token.isNotEmpty && _chatId.isNotEmpty;

  @override
  Future<void> send({
    required String fileName,
    required String report,
    required String caption,
  }) async {
    if (!isConfigured) throw const LogReportException('not configured');
    final request =
        http.MultipartRequest(
            'POST',
            Uri.https('api.telegram.org', '/bot$_token/sendDocument'),
          )
          ..fields['chat_id'] = _chatId
          // Telegram limits captions to 1024 characters.
          ..fields['caption'] = caption.length > 1000
              ? '${caption.substring(0, 1000)}...'
              : caption
          ..files.add(
            http.MultipartFile.fromBytes(
              'document',
              utf8.encode(report),
              filename: fileName,
            ),
          );
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 30)),
      );
    } on Exception catch (error) {
      throw LogReportException('$error');
    }
    if (response.statusCode != 200) {
      throw LogReportException('HTTP ${response.statusCode}');
    }
  }
}
