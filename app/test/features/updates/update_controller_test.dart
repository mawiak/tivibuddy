import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tivibuddy/core/database/app_database.dart';
import 'package:tivibuddy/features/updates/application/update_controller.dart';
import 'package:tivibuddy/features/updates/data/update_data_providers.dart';
import 'package:tivibuddy/features/updates/domain/app_release.dart';
import 'package:tivibuddy/features/updates/domain/update_source.dart';

import '../../helpers/test_app.dart';

class _FakeSource implements UpdateSource {
  AppRelease? release;
  int calls = 0;

  @override
  Future<AppRelease?> latest() async {
    calls++;
    return release;
  }
}

class _FakeInstaller implements UpdateInstaller {
  bool allowed = false;
  final installed = <String>[];
  int permissionOpened = 0;

  @override
  Future<List<String>> supportedAbis() async => ['armeabi-v7a'];

  @override
  Future<String> download(
    ReleaseAsset asset, {
    required void Function(double progress) progress,
  }) async {
    progress(0.5);
    progress(1);
    return '/cache/updates/${asset.name}';
  }

  @override
  Future<bool> canInstall() async => allowed;

  @override
  Future<void> openInstallPermission() async => permissionOpened++;

  @override
  Future<void> install(String path) async => installed.add(path);
}

AppRelease _release(String version) => AppRelease(
  version: version,
  notes: '',
  assets: [
    ReleaseAsset(
      name: 'tivibuddy-$version-armeabi-v7a.apk',
      url: Uri.parse('https://example.org/a.apk'),
      size: 10,
    ),
  ],
);

void main() {
  late _FakeSource source;
  late _FakeInstaller installer;
  late ProviderContainer container;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'TiviBuddy',
      packageName: 'io.github.mawiak.tivibuddy',
      version: '0.1.1',
      buildNumber: '1',
      buildSignature: '',
    );
    source = _FakeSource();
    installer = _FakeInstaller();
    final db = createTestDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        updateSourceProvider.overrideWithValue(source),
        updateInstallerProvider.overrideWithValue(installer),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  UpdateController controller() =>
      container.read(updateControllerProvider.notifier);
  UpdateState state() => container.read(updateControllerProvider);

  test('reports the installed version when nothing newer exists', () async {
    source.release = _release('0.1.1');
    await controller().check();
    expect(state(), isA<UpdateUpToDate>());
  });

  test('downloads, asks for the install permission and installs', () async {
    source.release = _release('0.1.2');
    await controller().check();
    final available = state() as UpdateAvailable;
    expect(available.asset.name, 'tivibuddy-0.1.2-armeabi-v7a.apk');
    expect(available.automatic, isFalse);

    await controller().download();
    expect(state(), isA<UpdateNeedsPermission>());
    await controller().openInstallPermission();
    expect(installer.permissionOpened, 1);

    installer.allowed = true;
    await controller().retryInstall();
    expect(state(), isA<UpdateInstalling>());
    expect(installer.installed, [
      '/cache/updates/tivibuddy-0.1.2-armeabi-v7a.apk',
    ]);
  });

  test(
    'checks automatically at most every few hours and not when off',
    () async {
      source.release = _release('0.1.2');
      await controller().autoCheck();
      expect(source.calls, 1);
      expect((state() as UpdateAvailable).automatic, isTrue);

      controller().dismiss();
      await controller().autoCheck();
      expect(source.calls, 1, reason: 'checked recently');

      await controller().setAutoCheck(false);
      expect(await controller().autoCheckEnabled(), isFalse);
    },
  );
}
