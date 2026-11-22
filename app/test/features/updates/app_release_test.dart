import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/updates/data/github_update_source.dart';
import 'package:tivibuddy/features/updates/domain/app_release.dart';

void main() {
  test('compares versions', () {
    expect(compareVersions('0.1.2', '0.1.1'), greaterThan(0));
    expect(compareVersions('0.2.0', '0.10.0'), lessThan(0));
    expect(compareVersions('1.0.0', '1.0.0'), 0);
    expect(compareVersions('1.0.0-beta.1', '1.0.0'), lessThan(0));
    expect(compareVersions('1.0', '1.0.0'), 0);
  });

  test('reads a GitHub release and picks the APK for the device', () {
    final release = GitHubUpdateSource.parseRelease({
      'tag_name': 'v0.1.2',
      'body': '### Fixed\n\n- Something',
      'assets': [
        for (final name in [
          'tivibuddy-0.1.2-arm64-v8a.apk',
          'tivibuddy-0.1.2-armeabi-v7a.apk',
          'tivibuddy-0.1.2-universal.apk',
          'tivibuddy.apk',
        ])
          {
            'name': name,
            'browser_download_url': 'https://example.org/$name',
            'size': 100,
          },
      ],
    });
    expect(release.version, '0.1.2');
    expect(release.isNewerThan('0.1.1'), isTrue);
    expect(release.isNewerThan('0.1.2'), isFalse);
    expect(
      release.apkFor(['armeabi-v7a', 'armeabi'])?.name,
      'tivibuddy-0.1.2-armeabi-v7a.apk',
    );
    expect(
      release.apkFor(['arm64-v8a', 'armeabi-v7a'])?.name,
      'tivibuddy-0.1.2-arm64-v8a.apk',
    );
    expect(release.apkFor(['x86'])?.name, 'tivibuddy.apk');
  });
}
