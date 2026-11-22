import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/app_release.dart';
import '../domain/update_source.dart';

/// Releases of the public GitHub repository. Unauthenticated requests are
/// limited to 60 per hour and address, far above one check every hours.
class GitHubUpdateSource implements UpdateSource {
  GitHubUpdateSource(this._client);

  final http.Client _client;

  static final _latest = Uri.https(
    'api.github.com',
    '/repos/mawiak/tivibuddy/releases/latest',
  );

  @override
  Future<AppRelease?> latest() async {
    final response = await _client
        .get(_latest, headers: {'Accept': 'application/vnd.github+json'})
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw http.ClientException('GitHub answered ${response.statusCode}');
    }
    return parseRelease(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Reads the fields of a release from the GitHub API.
  static AppRelease parseRelease(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String? ?? '';
    return AppRelease(
      version: tag.startsWith('v') ? tag.substring(1) : tag,
      notes: json['body'] as String? ?? '',
      assets: [
        for (final asset in json['assets'] as List<dynamic>? ?? const [])
          if (asset case {
            'name': final String name,
            'browser_download_url': final String url,
          })
            ReleaseAsset(
              name: name,
              url: Uri.parse(url),
              size: asset['size'] as int? ?? 0,
            ),
      ],
    );
  }
}
