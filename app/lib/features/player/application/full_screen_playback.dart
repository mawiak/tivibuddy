import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'full_screen_playback.g.dart';

/// Whether a full screen player is open. The display only follows the
/// frame rate of the video then (PLAY-6): switching for the guide preview
/// would turn the TV black on every channel browsed.
@Riverpod(keepAlive: true)
class FullScreenPlayback extends _$FullScreenPlayback {
  int _open = 0;

  @override
  bool build() => false;

  /// Counts nested players, for example a film started from search while
  /// another player was open.
  void opened() => state = ++_open > 0;

  void closed() => state = --_open > 0;
}
