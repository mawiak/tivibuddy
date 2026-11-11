import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when an Xtream server rejects the credentials.
class XtreamUnauthorizedException implements Exception {
  const XtreamUnauthorizedException();
}

/// Thrown when a response is not what an Xtream server returns.
class XtreamFormatException implements Exception {
  const XtreamFormatException(this.message);
  final String message;

  @override
  String toString() => 'XtreamFormatException: $message';
}

/// `user_info` block of the Xtream `player_api.php` response.
///
/// Providers are inconsistent: numbers arrive as strings or ints, dates as
/// epoch seconds in strings, missing values as null or empty strings. The
/// parsing here accepts all of them.
class XtreamUserInfo {
  const XtreamUserInfo({
    required this.authenticated,
    required this.status,
    this.expiresAt,
    this.maxConnections,
    this.activeConnections,
  });

  factory XtreamUserInfo.fromJson(Map<String, Object?> json) {
    final expSeconds = _int(json['exp_date']);
    return XtreamUserInfo(
      authenticated: _int(json['auth']) == 1,
      status: json['status']?.toString() ?? 'Unknown',
      expiresAt: expSeconds == null || expSeconds <= 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true),
      maxConnections: _int(json['max_connections']),
      activeConnections: _int(json['active_cons']),
    );
  }

  final bool authenticated;
  final String status;
  final DateTime? expiresAt;
  final int? maxConnections;
  final int? activeConnections;

  static int? _int(Object? value) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v.trim()),
    final bool v => v ? 1 : 0,
    _ => null,
  };
}

/// Low-level access to the Xtream Codes player API.
class XtreamApiClient {
  XtreamApiClient(this._http, {this.timeout = const Duration(seconds: 15)});

  final http.Client _http;
  final Duration timeout;

  static const headers = {'User-Agent': 'TiviBuddy', 'Accept': '*/*'};

  /// URL of the player API, optionally with an `action` and parameters.
  static Uri apiUri(
    String serverUrl,
    String username,
    String password, [
    Map<String, String> extra = const {},
  ]) => Uri.parse('$serverUrl/player_api.php').replace(
    queryParameters: {'username': username, 'password': password, ...extra},
  );

  /// Full programme guide of the account as XMLTV.
  static Uri xmltvUri(String serverUrl, String username, String password) =>
      Uri.parse(
        '$serverUrl/xmltv.php',
      ).replace(queryParameters: {'username': username, 'password': password});

  /// Throws the matching exception for responses that are not usable.
  static void checkStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      throw const XtreamUnauthorizedException();
    }
    if (statusCode != 200) throw XtreamFormatException('HTTP $statusCode');
  }

  /// Fetches and decodes a small JSON response. Large catalogs are streamed
  /// instead (see `JsonArraySplitter`).
  Future<Object?> getJson({
    required String serverUrl,
    required String username,
    required String password,
    Map<String, String> parameters = const {},
  }) async {
    final response = await _http
        .get(
          apiUri(serverUrl, username, password, parameters),
          headers: headers,
        )
        .timeout(timeout);
    checkStatus(response.statusCode);
    try {
      return jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } on FormatException {
      throw const XtreamFormatException('Response is not JSON');
    }
  }

  /// Calls the API without an action, which returns account and server info.
  Future<XtreamUserInfo> getUserInfo({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final body = await getJson(
      serverUrl: serverUrl,
      username: username,
      password: password,
    );
    // Some servers answer wrong credentials with an empty list.
    if (body is List && body.isEmpty) throw const XtreamUnauthorizedException();
    if (body is! Map<String, Object?>) {
      throw const XtreamFormatException('Unexpected JSON structure');
    }
    final userInfo = body['user_info'];
    if (userInfo is! Map<String, Object?>) {
      throw const XtreamFormatException('Missing user_info');
    }

    final info = XtreamUserInfo.fromJson(userInfo);
    if (!info.authenticated) throw const XtreamUnauthorizedException();
    return info;
  }
}
