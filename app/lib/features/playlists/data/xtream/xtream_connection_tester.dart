import 'dart:async';

import 'package:http/http.dart' as http;

import '../../domain/connection_test.dart';
import '../../domain/playlist.dart';
import 'xtream_api_client.dart';

class XtreamConnectionTester implements ConnectionTester {
  XtreamConnectionTester(this._client, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final XtreamApiClient _client;
  final DateTime Function() _clock;

  @override
  Future<ConnectionResult> test({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      final info = await _client.getUserInfo(
        serverUrl: serverUrl,
        username: username,
        password: password,
      );
      return ConnectionOk(
        AccountInfo(
          status: info.status,
          checkedAt: _clock().toUtc(),
          expiresAt: info.expiresAt,
          maxConnections: info.maxConnections,
          activeConnections: info.activeConnections,
        ),
      );
    } on XtreamUnauthorizedException {
      return const ConnectionUnauthorized();
    } on XtreamFormatException {
      return const ConnectionFailed(ConnectionFailure.invalidResponse);
    } on TimeoutException {
      return const ConnectionFailed(ConnectionFailure.timeout);
    } on http.ClientException {
      return const ConnectionFailed(ConnectionFailure.unreachable);
    } on Exception {
      // TLS and platform-specific socket errors are not always wrapped in
      // ClientException.
      return const ConnectionFailed(ConnectionFailure.unreachable);
    }
  }
}
