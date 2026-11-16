import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Lines describing the device and its memory right now, for a diagnostic
/// report.
Future<List<String>> describeDevice() async {
  final lines = <String>[];
  try {
    final info = DeviceInfoPlugin();
    if (!kIsWeb && Platform.isAndroid) {
      final android = await info.androidInfo;
      lines
        ..add(
          'device: ${android.manufacturer} ${android.model} '
          '(${android.device}, ${android.hardware})',
        )
        ..add(
          'android: ${android.version.release} '
          '(sdk ${android.version.sdkInt}), build ${android.display}',
        )
        ..add('abis: ${android.supportedAbis.join(', ')}')
        ..add(
          'tv: ${android.systemFeatures.contains('android.software.leanback')}',
        );
    } else {
      final data = (await info.deviceInfo).data;
      lines.add('device: ${data['model'] ?? data['name'] ?? '-'}');
      lines.add(
        'os: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      );
    }
  } on Object catch (error) {
    lines.add('device: unknown ($error)');
  }
  if (!kIsWeb && (Platform.isAndroid || Platform.isLinux)) {
    lines
      ..addAll(
        await _procLines('/proc/meminfo', const [
          'MemTotal',
          'MemAvailable',
          'SwapTotal',
          'SwapFree',
        ]),
      )
      ..addAll(await _procLines('/proc/self/status', const ['VmRSS', 'VmHWM']))
      ..addAll(await _procLines('/proc/loadavg', const []));
  }
  return lines;
}

/// Lines of the platform log (logcat) of this app that matter for playback
/// problems: the renderer Flutter chose, warnings and errors, for example of
/// the hardware decoder or the audio output. Apps may read their own log
/// without extra permissions. Empty where there is no logcat.
Future<List<String>> platformLogExcerpt({int maxLines = 200}) async {
  if (kIsWeb || !Platform.isAndroid) return const [];
  try {
    final result = await Process.run('logcat', [
      '-d',
      '-v',
      'time',
      '--pid=$pid',
    ]);
    final renderer = RegExp(
      'impeller|vulkan|opengl|skia|rendering backend',
      caseSensitive: false,
    );
    final problem = RegExp(r'^\S+ \S+ [WEF]/');
    final lines = [
      for (final line in (result.stdout as String).split('\n'))
        // Other Dart output is already in the app log.
        if (renderer.hasMatch(line) ||
            (problem.hasMatch(line) && !line.contains('/flutter')))
          line.trim(),
    ];
    return lines.length > maxLines
        ? lines.sublist(lines.length - maxLines)
        : lines;
  } on Object catch (error) {
    return ['platform log unavailable: $error'];
  }
}

/// Lines of a proc file starting with one of [keys], or all lines when
/// [keys] is empty.
Future<List<String>> _procLines(String path, List<String> keys) async {
  try {
    final lines = await File(path).readAsLines();
    return [
      for (final line in lines)
        if (keys.isEmpty || keys.any(line.startsWith))
          '${path.split('/').last}: ${line.replaceAll(RegExp(r'\s+'), ' ')}',
    ];
  } on Object {
    return const [];
  }
}
