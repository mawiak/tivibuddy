/// A published version of the app (a GitHub release).
class AppRelease {
  const AppRelease({
    required this.version,
    required this.notes,
    required this.assets,
  });

  /// Version without the leading `v` of the tag, for example `0.1.2`.
  final String version;

  /// Release notes (the changelog section of the version, Markdown).
  final String notes;

  final List<ReleaseAsset> assets;

  bool isNewerThan(String installed) => compareVersions(version, installed) > 0;

  /// The APK for [abis] (the device's supported ABIs, preferred first),
  /// falling back to the universal APK. Null without any APK.
  ReleaseAsset? apkFor(List<String> abis) {
    for (final abi in abis) {
      final match = assets.where((a) => a.name.endsWith('-$abi.apk'));
      if (match.isNotEmpty) return match.first;
    }
    return assets.where((a) => a.name == 'tivibuddy.apk').firstOrNull ??
        assets.where((a) => a.name.endsWith('-universal.apk')).firstOrNull;
  }
}

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.url,
    required this.size,
  });

  final String name;
  final Uri url;

  /// Bytes.
  final int size;
}

/// Compares semantic versions `X.Y.Z`; a pre-release suffix (`-beta.1`)
/// sorts before the plain version. Negative when [a] is older than [b].
int compareVersions(String a, String b) {
  List<int> numbers(String version) => [
    for (final part in version.split('-').first.split('.'))
      int.tryParse(part) ?? 0,
  ];
  final left = numbers(a);
  final right = numbers(b);
  for (var i = 0; i < 3; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l.compareTo(r);
  }
  final leftPre = a.contains('-');
  final rightPre = b.contains('-');
  if (leftPre == rightPre) return 0;
  return leftPre ? -1 : 1;
}
