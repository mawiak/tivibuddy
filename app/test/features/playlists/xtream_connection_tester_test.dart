import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tivibuddy/features/playlists/data/xtream/xtream_api_client.dart';
import 'package:tivibuddy/features/playlists/data/xtream/xtream_connection_tester.dart';
import 'package:tivibuddy/features/playlists/domain/connection_test.dart';

final _checkedAt = DateTime.utc(2026, 11, 11);

Future<ConnectionResult> _test(MockClientHandler handler) {
  final client = XtreamApiClient(
    MockClient(handler),
    timeout: const Duration(milliseconds: 200),
  );
  return XtreamConnectionTester(client, clock: () => _checkedAt).test(
    serverUrl: 'http://example.com:8080',
    username: 'anna',
    password: 'secret',
  );
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status);

void main() {
  test('calls player_api.php with the credentials', () async {
    late Uri requested;
    await _test((request) async {
      requested = request.url;
      return _json({});
    });

    expect(requested.path, '/player_api.php');
    expect(requested.queryParameters, {
      'username': 'anna',
      'password': 'secret',
    });
  });

  test('parses account details with string values', () async {
    final result = await _test(
      (_) async => _json({
        'user_info': {
          'auth': 1,
          'status': 'Active',
          'exp_date': '1798761600',
          'max_connections': '2',
          'active_cons': '0',
        },
        'server_info': {'url': 'example.com'},
      }),
    );

    final account = (result as ConnectionOk).account;
    expect(account.isActive, isTrue);
    expect(account.expiresAt, DateTime.utc(2027));
    expect(account.maxConnections, 2);
    expect(account.activeConnections, 0);
    expect(account.checkedAt, _checkedAt);
  });

  test('treats missing expiry as unlimited', () async {
    final result = await _test(
      (_) async => _json({
        'user_info': {'auth': '1', 'status': 'Active', 'exp_date': null},
      }),
    );

    expect((result as ConnectionOk).account.expiresAt, isNull);
  });

  for (final (name, response) in [
    (
      'auth 0',
      _json({
        'user_info': {'auth': 0},
      }),
    ),
    ('empty list', _json([])),
    ('HTTP 401', http.Response('', 401)),
  ]) {
    test('reports wrong credentials for $name', () async {
      expect(await _test((_) async => response), isA<ConnectionUnauthorized>());
    });
  }

  test('reports non-Xtream responses', () async {
    final result = await _test((_) async => http.Response('<html>', 200));

    expect(
      (result as ConnectionFailed).reason,
      ConnectionFailure.invalidResponse,
    );
  });

  test('reports unreachable servers', () async {
    final result = await _test(
      (_) async => throw http.ClientException('Connection refused'),
    );

    expect((result as ConnectionFailed).reason, ConnectionFailure.unreachable);
  });

  test('reports timeouts', () async {
    final result = await _test((_) => Completer<http.Response>().future);

    expect((result as ConnectionFailed).reason, ConnectionFailure.timeout);
  });
}
