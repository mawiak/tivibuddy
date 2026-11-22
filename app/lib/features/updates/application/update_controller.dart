import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/data/settings_data_providers.dart';
import '../data/update_data_providers.dart';
import '../domain/app_release.dart';

part 'update_controller.g.dart';

sealed class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate(this.version);

  final String version;
}

class UpdateAvailable extends UpdateState {
  const UpdateAvailable(this.release, this.asset, {required this.automatic});

  final AppRelease release;
  final ReleaseAsset asset;

  /// Found by the check on start rather than asked for in the settings.
  final bool automatic;
}

class UpdateDownloading extends UpdateState {
  const UpdateDownloading(this.release, this.progress);

  final AppRelease release;

  /// 0 to 1.
  final double progress;
}

/// Downloaded, but the app may not install packages yet; the user allows
/// it in the system setting and tries again.
class UpdateNeedsPermission extends UpdateState {
  const UpdateNeedsPermission(this.release, this.path);

  final AppRelease release;
  final String path;
}

/// The system installer is open with the downloaded update.
class UpdateInstalling extends UpdateState {
  const UpdateInstalling(this.release);

  final AppRelease release;
}

class UpdateFailed extends UpdateState {
  const UpdateFailed(this.error);

  final String error;
}

/// In-app updates on Android: checks the GitHub releases, downloads the APK
/// of the device's ABI and opens the system installer. Other platforms
/// follow later (see the roadmap); there the controller stays idle.
@Riverpod(keepAlive: true)
class UpdateController extends _$UpdateController {
  static const _autoCheckKey = 'updates.autoCheck';
  static const _lastCheckKey = 'updates.lastCheck';

  /// Automatic checks run at most this often.
  static const checkInterval = Duration(hours: 6);

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  UpdateState build() => const UpdateIdle();

  Future<bool> autoCheckEnabled() async =>
      await ref
          .read(deviceSettingsRepositoryProvider)
          .getValue(_autoCheckKey) !=
      'off';

  Future<void> setAutoCheck(bool on) => ref
      .read(deviceSettingsRepositoryProvider)
      .setValue(_autoCheckKey, on ? null : 'off');

  /// The check on start: only when switched on and the last check is older
  /// than [checkInterval].
  Future<void> autoCheck() async {
    if (!supported || !await autoCheckEnabled()) return;
    final last = int.tryParse(
      await ref
              .read(deviceSettingsRepositoryProvider)
              .getValue(_lastCheckKey) ??
          '',
    );
    final now = DateTime.now();
    if (last != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(last)) <
            checkInterval) {
      return;
    }
    await check(automatic: true);
  }

  Future<void> check({bool automatic = false}) async {
    if (!supported || state is UpdateChecking || state is UpdateDownloading) {
      return;
    }
    state = const UpdateChecking();
    try {
      final installed = (await PackageInfo.fromPlatform()).version;
      final release = await ref.read(updateSourceProvider).latest();
      await ref
          .read(deviceSettingsRepositoryProvider)
          .setValue(_lastCheckKey, '${DateTime.now().millisecondsSinceEpoch}');
      if (release == null || !release.isNewerThan(installed)) {
        debugPrint('update: $installed is the newest version');
        state = UpdateUpToDate(installed);
        return;
      }
      final abis = await ref.read(updateInstallerProvider).supportedAbis();
      final asset = release.apkFor(abis);
      if (asset == null) {
        debugPrint('update: ${release.version} has no APK for $abis');
        state = UpdateUpToDate(installed);
        return;
      }
      debugPrint(
        'update: ${release.version} available (installed $installed), '
        '${asset.name}',
      );
      state = UpdateAvailable(release, asset, automatic: automatic);
    } on Exception catch (error) {
      debugPrint('update: check failed: $error');
      state = UpdateFailed('$error');
    }
  }

  /// Downloads the available update and opens the installer.
  Future<void> download() async {
    final available = state;
    if (available is! UpdateAvailable) return;
    final release = available.release;
    state = UpdateDownloading(release, 0);
    try {
      final installer = ref.read(updateInstallerProvider);
      var reported = 0.0;
      final path = await installer.download(
        available.asset,
        progress: (progress) {
          // Fewer rebuilds: one per percent.
          if (progress - reported < 0.01 && progress < 1) return;
          reported = progress;
          state = UpdateDownloading(release, progress);
        },
      );
      debugPrint('update: downloaded ${available.asset.name}');
      await _install(release, path);
    } on Exception catch (error) {
      debugPrint('update: download failed: $error');
      state = UpdateFailed('$error');
    }
  }

  /// Again after the user allowed installing packages.
  Future<void> retryInstall() async {
    final waiting = state;
    if (waiting is UpdateNeedsPermission) {
      await _install(waiting.release, waiting.path);
    }
  }

  Future<void> openInstallPermission() =>
      ref.read(updateInstallerProvider).openInstallPermission();

  Future<void> _install(AppRelease release, String path) async {
    final installer = ref.read(updateInstallerProvider);
    if (!await installer.canInstall()) {
      debugPrint('update: installing packages is not allowed yet');
      state = UpdateNeedsPermission(release, path);
      return;
    }
    await installer.install(path);
    debugPrint('update: installer opened for ${release.version}');
    state = UpdateInstalling(release);
  }

  /// "Later": hides the update until the next check.
  void dismiss() => state = const UpdateIdle();
}
