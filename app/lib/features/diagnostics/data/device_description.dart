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
    // Harmless messages some systems print many times a second; they would
    // push the useful lines out.
    final noise = RegExp(
      'Access denied finding property|updateAcquireFence|/flutter',
    );
    final renderers = <String>[];
    final problems = <String>[];
    for (final line in (result.stdout as String).split('\n')) {
      if (renderer.hasMatch(line)) {
        renderers.add(line.trim());
      } else if (problem.hasMatch(line) && !noise.hasMatch(line)) {
        problems.add(line.trim());
      }
    }
    // The renderer is reported once at start; keep it even when many
    // problems follow.
    final kept = renderers.take(10).toList();
    final room = maxLines - kept.length;
    return [
      ...kept,
      ...problems.length > room
          ? problems.sublist(problems.length - room)
          : problems,
    ];
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
