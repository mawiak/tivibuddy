import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/playback_engine.dart';

/// A playback engine the fallback chain can create on demand.
typedef EngineOption = ({String name, PlaybackEngine Function() create});

/// Plays every stream with the first engine of [options] and moves on to the
/// next one when an engine cannot start a stream (PLAY-5). Each choice and
/// fallback is logged, so a diagnostic report shows which engine played
/// what. Only one engine exists at a time to save memory (RES-1).
class FallbackPlaybackEngine implements PlaybackEngine {
  FallbackPlaybackEngine(this.options, {required this.platform})
    : assert(options.isNotEmpty, 'at least one engine') {
    debugPrint(
      'player engines for $platform: '
      '${options.map((option) => option.name).join(' -> ')}',
    );
  }

  final List<EngineOption> options;

  /// Platform name for the log, for example `android`.
  final String platform;

  /// The engine currently playing, for the video surface.
  final active = ValueNotifier<PlaybackEngine?>(null);
  int _index = -1;

  final _states = StreamController<PlaybackState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _tracks = StreamController<MediaTracks>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];

  String? _url;
  Duration? _start;

  /// Whether the stream of the current open played already; failures after
  /// that are errors of the stream, not of the engine.
  bool _played = false;

  String get activeName => _index < 0 ? '-' : options[_index].name;

  Future<void> _use(int index) async {
    if (index == _index) return;
    final previous = active.value;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _index = index;
    final engine = options[index].create();
    _subscriptions.addAll([
      engine.states.listen(_onState),
      engine.positions.listen(_positions.add),
      engine.tracks.listen(_tracks.add),
    ]);
    active.value = engine;
    await previous?.dispose();
  }

  void _onState(PlaybackState state) {
    if (state.status == PlaybackStatus.playing) _played = true;
    if (state.status == PlaybackStatus.failed &&
        !_played &&
        _index + 1 < options.length) {
      unawaited(_fallBack(state.error));
      // Opening, not failed: the next engine is about to try.
      _emit(const PlaybackState(status: PlaybackStatus.opening));
      return;
    }
    _emit(state);
  }

  Future<void> _fallBack(String? error) async {
    final url = _url;
    if (url == null) return;
    final next = _index + 1;
    debugPrint(
      'player engine ${options[_index].name} failed (${error ?? 'unknown'}), '
      'falling back to ${options[next].name}',
    );
    await _use(next);
    await active.value!.open(url, start: _start);
  }

  void _emit(PlaybackState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  PlaybackState _state = PlaybackState.idle;

  @override
  Future<void> open(String url, {Duration? start}) async {
    _url = url;
    _start = start;
    _played = false;
    // Every stream gets the preferred engine first; a fallback for one
    // stream says nothing about the next.
    if (_index != 0) {
      if (_index > 0) {
        debugPrint('player engine back to ${options.first.name}');
      }
      await _use(0);
    }
    debugPrint('player engine ${options.first.name} opens the stream');
    await active.value!.open(url, start: start);
  }

  PlaybackEngine? get _engine => active.value;

  @override
  Stream<PlaybackState> get states => _states.stream;

  @override
  PlaybackState get state => _state;

  @override
  Stream<Duration> get positions => _positions.stream;

  @override
  Duration get position => _engine?.position ?? Duration.zero;

  @override
  Stream<MediaTracks> get tracks => _tracks.stream;

  @override
  MediaTracks get currentTracks => _engine?.currentTracks ?? MediaTracks.none;

  @override
  Future<void> seek(Duration position) async => _engine?.seek(position);

  @override
  Future<void> selectTrack(MediaTrackType type, String? id) async =>
      _engine?.selectTrack(type, id);

  @override
  Future<void> togglePause() async => _engine?.togglePause();

  @override
  Future<void> stop() async => _engine?.stop();

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _engine?.dispose();
    active.dispose();
    await _states.close();
    await _positions.close();
    await _tracks.close();
  }
}
