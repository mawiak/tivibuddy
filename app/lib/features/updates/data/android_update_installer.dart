import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/app_release.dart';
import '../domain/update_source.dart';

/// Installs APKs through the Android package installer (`UpdateInstaller.kt`).
class AndroidUpdateInstaller implements UpdateInstaller {
  AndroidUpdateInstaller(this._client);

  final http.Client _client;

  static const _channel = MethodChannel('io.github.mawiak.tivibuddy/updates');

  @override
  Future<List<String>> supportedAbis() async =>
      (await DeviceInfoPlugin().androidInfo).supportedAbis;

  @override
  Future<String> download(
    ReleaseAsset asset, {
    required void Function(double progress) progress,
  }) async {
    // The cache directory is shared with the installer through the file
    // provider (res/xml/update_paths.xml); older downloads are replaced.
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/updates',
    );
    if (directory.existsSync()) directory.deleteSync(recursive: true);
    directory.createSync(recursive: true);
    final file = File('${directory.path}/${asset.name}');

    final response = await _client.send(http.Request('GET', asset.url));
    if (response.statusCode != 200) {
      throw http.ClientException('Download answered ${response.statusCode}');
    }
    final total = response.contentLength ?? asset.size;
    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) progress(received / total);
      }
    } finally {
      await sink.close();
    }
    return file.path;
  }

  @override
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;

  @override
  Future<void> openInstallPermission() =>
      _channel.invokeMethod<void>('openInstallPermission');

  @override
  Future<void> install(String path) =>
      _channel.invokeMethod<void>('install', {'path': path});
}
