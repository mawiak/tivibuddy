import 'app_release.dart';

/// Where releases are published.
abstract interface class UpdateSource {
  /// The newest release, or null when none can be found.
  Future<AppRelease?> latest();
}

/// Downloads and installs an update on the device.
abstract interface class UpdateInstaller {
  /// ABIs of the device, preferred first, for picking the APK.
  Future<List<String>> supportedAbis();

  /// Downloads [asset] to a local file and returns its path. [progress]
  /// receives values from 0 to 1.
  Future<String> download(
    ReleaseAsset asset, {
    required void Function(double progress) progress,
  });

  /// Whether the app may install packages (Android "install unknown apps").
  Future<bool> canInstall();

  /// Opens the system setting that allows installing packages.
  Future<void> openInstallPermission();

  /// Starts the system installer for the downloaded file.
  Future<void> install(String path);
}
