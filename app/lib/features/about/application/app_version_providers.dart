import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version_providers.g.dart';

/// Short commit id the build was made from, passed in by the build scripts
/// and the release workflow (`--dart-define=GIT_COMMIT=...`); empty for
/// plain `flutter run` builds.
const gitCommit = String.fromEnvironment('GIT_COMMIT');

/// Version shown to users, with the commit when known: `0.1.0 (6845e0e)`.
/// The build number stays out: split APKs add an ABI offset to it.
String versionLabel(String version, [String commit = gitCommit]) =>
    commit.isEmpty ? version : '$version ($commit)';

/// Empty where the platform cannot tell the version (tests); a failure
/// would make Riverpod retry it on a timer.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  try {
    return versionLabel((await PackageInfo.fromPlatform()).version);
  } on Exception {
    return versionLabel('').trim();
  }
}
