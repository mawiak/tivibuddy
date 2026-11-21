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
  FallbackPlaybackEngine(
    this.options, {
    required this.platform,
    this.startTimeout = const Duration(seconds: 20),
  }) : assert(options.isNotEmpty, 'at least one engine') {
    debugPrint(
      'player engines for $platform: '
      '${options.map((option) => option.name).join(' -> ')}',
    );
  }

  final List<EngineOption> options;

  /// Platform name for the log, for example `android`.
  final String platform;

  /// An engine that neither plays nor fails within this time counts as
  /// failed, so a hanging engine does not leave the user at a spinner.
  final Duration startTimeout;
  Timer? _startTimer;

  /// The engine currently playing, for the video surface.
  final active = ValueNotifier<PlaybackEngine?>(null);
  int _index = -1;

  final _states = StreamController<PlaybackState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _tracks = StreamController<MediaTracks>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];

  String? _url;
  Duration? _start;
  bool _live = false;

  /// Whether the current stream is a TV channel.
  bool get live => _live;

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

  void _watchStart() {
    _startTimer?.cancel();
    if (_index + 1 >= options.length) return;
    _startTimer = Timer(startTimeout, () {
      if (_played) return;
      unawaited(_fallBack('no start within ${startTimeout.inSeconds} s'));
      _emit(const PlaybackState(status: PlaybackStatus.opening));
    });
  }

  void _onState(PlaybackState state) {
    if (state.status == PlaybackStatus.playing) {
      _played = true;
      _startTimer?.cancel();
    }
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
    _watchStart();
    await active.value!.open(url, start: _start, live: _live);
  }

  void _emit(PlaybackState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  PlaybackState _state = PlaybackState.idle;

  @override
  Future<void> open(String url, {Duration? start, bool live = false}) async {
    _url = url;
    _start = start;
    _live = live;
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
    _watchStart();
    await active.value!.open(url, start: start, live: live);
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
  Future<void> setPaused(bool paused) async => _engine?.setPaused(paused);

  bool _suspendedLive = false;

  /// The app went to the background: native engines would keep playing
  /// sound. Live TV stops and starts again at the live edge on [resume];
  /// films and episodes pause where they are.
  Future<void> suspend() async {
    final playing =
        _state.status == PlaybackStatus.playing ||
        _state.status == PlaybackStatus.buffering;
    if (!playing) return;
    debugPrint('player suspended in the background');
    if (_live) {
      _suspendedLive = true;
      await _engine?.stop();
    } else {
      await _engine?.setPaused(true);
    }
  }

  /// The app is visible again.
  Future<void> resume() async {
    final url = _url;
    if (!_suspendedLive || url == null) return;
    _suspendedLive = false;
    debugPrint('player resumes live TV');
    await open(url, live: true);
  }

  @override
  Future<void> refreshAudioOutput() async => _engine?.refreshAudioOutput();

  @override
  Future<void> stop() async => _engine?.stop();

  @override
  Future<void> dispose() async {
    _startTimer?.cancel();
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
