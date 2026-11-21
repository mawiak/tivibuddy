import 'package:flutter_test/flutter_test.dart';
import 'package:tivibuddy/features/about/application/app_version_providers.dart';

void main() {
  test('shows the commit next to the version when known', () {
    expect(versionLabel('0.1.0', '6845e0e'), '0.1.0 (6845e0e)');
    expect(versionLabel('0.1.0', '6845e0e-dirty'), '0.1.0 (6845e0e-dirty)');
    expect(versionLabel('0.1.0'), '0.1.0', reason: 'plain flutter run');
  });
}
