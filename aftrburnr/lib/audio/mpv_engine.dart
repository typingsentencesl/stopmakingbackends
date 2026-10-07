import 'dart:async';
import 'dart:math' as math;

import 'package:media_kit/media_kit.dart' hide Playable;

import '../sources/music_source.dart';
import 'engine.dart';

/// One media_kit player. The engine owns two so it can crossfade.
class _Deck {
  _Deck(String? audioOutput)
    : player = Player(
        configuration: const PlayerConfiguration(
          title: 'AFTRBURNR',
          logLevel: MPVLogLevel.warn,
        ),
      ) {
    ready = _init(audioOutput);
  }

  final Player player;
  late final Future<void> ready;

  NativePlayer get native => player.platform as NativePlayer;

  Object? tag;
  Object? nextTag;
  bool hasNext = false;

  /// Crossfade ramp, amplitude 0–1.
  double ramp = 1;

  Future<void> _init(String? ao) async {
    await native.setProperty('gapless-audio', 'weak');
    await native.setProperty('prefetch-playlist', 'yes');
    await native.setProperty('audio-display', 'no');
    await native.setProperty('replaygain-clip', 'no');
    if (ao != null) await native.setProperty('ao', ao);
  }
}

/// libmpv engine.
///
/// Gapless (crossfade = 0): the active deck holds an mpv playlist of
/// `[current, next]`. mpv prefetches `next` and joins the two with no gap;
/// when it moves on, the finished entry is dropped and the controller is
/// asked for the following one.
///
/// Crossfade: the next track is opened, paused, on the idle deck. When the
/// active deck reaches `duration − fade`, both decks ramp on an equal-power
/// curve and swap roles.
class MpvEngine implements AudioEngine {
  MpvEngine({String? audioOutput})
    : _decks = [_Deck(audioOutput), _Deck(audioOutput)] {
    for (var i = 0; i < 2; i++) {
      _listen(i);
    }
  }

  final List<_Deck> _decks;
  int _active = 0;
  _Deck get _a => _decks[_active];
  _Deck get _idle => _decks[1 - _active];

  final _events = StreamController<EngineEvent>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final List<StreamSubscription<Object?>> _subs = [];

  Duration _crossfade = Duration.zero;
  double _volume = 1;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;

  Playable? _nextPlayable;
  Object? _nextTag;

  /// Set while a crossfade runs; the deck that is fading out.
  _Deck? _outgoing;
  Timer? _fadeTimer;

  /// Guards against reporting the same end twice (mpv may emit
  /// `completed` more than once while kept open at EOF).
  Object? _endedTag;

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Stream<Duration> get position => _position.stream;

  @override
  Duration get currentPosition => _pos;

  bool get _gapless => _crossfade == Duration.zero;

  void _listen(int i) {
    final d = _decks[i];
    final s = d.player.stream;
    bool isActive() => identical(d, _a);
    _subs.add(
      s.position.listen((p) {
        if (!isActive()) return;
        _pos = p;
        _position.add(p);
        _maybeStartFade();
      }),
    );
    _subs.add(
      s.duration.listen((v) {
        if (!isActive() || v == Duration.zero) return;
        _dur = v;
        _events.add(EngineDuration(d.tag, v));
      }),
    );
    _subs.add(
      s.playing.listen((v) {
        if (isActive()) _events.add(EnginePlaying(v));
      }),
    );
    _subs.add(
      s.buffering.listen((v) {
        if (isActive()) _events.add(EngineBuffering(v));
      }),
    );
    _subs.add(
      s.playlist.listen((pl) {
        if (!isActive() || !d.hasNext || pl.index != 1) return;
        // mpv moved on to the preloaded entry: a gapless join.
        d.hasNext = false;
        d.tag = d.nextTag;
        d.nextTag = null;
        _nextPlayable = null;
        _nextTag = null;
        _pos = Duration.zero;
        _dur = Duration.zero;
        _events.add(EngineAdvanced(d.tag));
        unawaited(d.player.remove(0));
      }),
    );
    _subs.add(
      s.completed.listen((done) {
        if (!done) return;
        if (identical(d, _outgoing)) {
          _finishFade();
          return;
        }
        if (!isActive() || d.hasNext) return;
        if (_endedTag == d.tag) return;
        _onActiveEnded();
      }),
    );
    _subs.add(
      s.error.listen((msg) {
        if (!isActive()) return;
        _events.add(EngineError(d.tag, msg));
      }),
    );
  }

  Future<void> _onActiveEnded() async {
    final d = _a;
    if (_nextPlayable != null) {
      // Crossfade mode, but the track was too short to fade (or a seek
      // jumped past the fade point): cut straight to the next one.
      final tag = _nextTag;
      await _swapTo(fade: false);
      _events.add(EngineAdvanced(tag));
      return;
    }
    _endedTag = d.tag;
    _events.add(EngineEnded(d.tag));
  }

  Media _media(Playable p, {Duration start = Duration.zero}) => Media(
    p.uri,
    httpHeaders: p.headers.isEmpty ? null : p.headers,
    start: start > Duration.zero ? start : null,
  );

  Future<void> _applyVolume(_Deck d) async {
    // mpv's volume property is already cubic (perceptual), so the ramp's
    // amplitude is converted back into that scale.
    final v = 100 * _volume * math.pow(d.ramp.clamp(0.0, 1.0), 1 / 3);
    await d.player.setVolume(v.toDouble());
  }

  @override
  Future<void> load(
    Playable p, {
    required Object tag,
    bool play = true,
    Duration start = Duration.zero,
  }) async {
    await Future.wait([_decks[0].ready, _decks[1].ready]);
    _cancelFade();
    await _idle.player.stop();
    _idle
      ..tag = null
      ..hasNext = false;
    final d = _a;
    d
      ..tag = tag
      ..hasNext = false
      ..nextTag = null
      ..ramp = 1;
    _nextPlayable = null;
    _nextTag = null;
    _endedTag = null;
    _pos = start;
    _dur = Duration.zero;
    await _applyVolume(d);
    await d.player.open(Playlist([_media(p, start: start)]), play: play);
  }

  @override
  Future<void> setNext(Playable? p, {Object? tag}) async {
    await Future.wait([_decks[0].ready, _decks[1].ready]);
    final d = _a;
    // Drop whatever was preloaded before.
    if (d.hasNext) {
      d.hasNext = false;
      d.nextTag = null;
      final count = d.player.state.playlist.medias.length;
      if (count > 1) await d.player.remove(count - 1);
    }
    if (_outgoing == null) {
      await _idle.player.stop();
      _idle.tag = null;
    }
    _nextPlayable = p;
    _nextTag = tag;
    if (p == null) return;
    // A new next makes an earlier end no longer final.
    if (_endedTag == d.tag && d.player.state.completed) {
      _endedTag = null;
      await _onActiveEnded();
      return;
    }
    if (_gapless) {
      d.nextTag = tag;
      d.hasNext = true;
      await d.player.add(_media(p));
    } else if (_outgoing == null) {
      // Open on the idle deck now so the fade starts from a warm buffer.
      _idle
        ..tag = tag
        ..ramp = 0;
      await _applyVolume(_idle);
      await _idle.player.open(Playlist([_media(p)]), play: false);
    }
  }

  void _maybeStartFade() {
    if (_gapless || _outgoing != null || _nextPlayable == null) return;
    if (_dur == Duration.zero || !_a.player.state.playing) return;
    final fade = _fadeLength();
    if (_dur - _pos <= fade && _pos > Duration.zero) {
      final tag = _nextTag;
      unawaited(
        _swapTo(fade: true).then((_) {
          _events.add(EngineAdvanced(tag));
        }),
      );
    }
  }

  /// Short tracks get proportionally shorter fades so a 20 s interlude
  /// isn't half crossfade.
  Duration _fadeLength() {
    final third = Duration(milliseconds: _dur.inMilliseconds ~/ 3);
    return _crossfade < third ? _crossfade : third;
  }

  Future<void> _swapTo({required bool fade}) async {
    final next = _nextPlayable;
    if (next == null) return;
    final outgoing = _a;
    final incoming = _idle;
    final tag = _nextTag;
    _nextPlayable = null;
    _nextTag = null;
    _active = 1 - _active;
    _pos = Duration.zero;
    _dur = Duration.zero;
    _endedTag = null;
    incoming
      ..tag = tag
      ..hasNext = false;
    if (incoming.player.state.playlist.medias.isEmpty) {
      await incoming.player.open(Playlist([_media(next)]), play: false);
    }
    if (!fade) {
      incoming.ramp = 1;
      await _applyVolume(incoming);
      await incoming.player.play();
      await outgoing.player.stop();
      outgoing.tag = null;
      return;
    }
    _outgoing = outgoing;
    incoming.ramp = 0;
    await _applyVolume(incoming);
    await incoming.player.play();
    final length = _fadeLength() == Duration.zero ? _crossfade : _fadeLength();
    final sw = Stopwatch()..start();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      final x = (sw.elapsedMilliseconds / math.max(1, length.inMilliseconds))
          .clamp(0.0, 1.0);
      // Equal-power: total energy stays constant through the fade.
      outgoing.ramp = math.cos(x * math.pi / 2);
      incoming.ramp = math.sin(x * math.pi / 2);
      unawaited(_applyVolume(outgoing));
      unawaited(_applyVolume(incoming));
      if (x >= 1) _finishFade();
    });
  }

  void _finishFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    final out = _outgoing;
    _outgoing = null;
    if (out != null) {
      out.tag = null;
      out.ramp = 1;
      unawaited(out.player.stop());
    }
    _a.ramp = 1;
    unawaited(_applyVolume(_a));
  }

  void _cancelFade() {
    if (_outgoing != null) _finishFade();
  }

  @override
  Future<void> play() async {
    final d = _a;
    if (d.player.state.completed && _endedTag == d.tag) {
      // Pressing play at the end of the queue replays the last track.
      _endedTag = null;
      await d.player.seek(Duration.zero);
    }
    await d.player.play();
  }

  @override
  Future<void> pause() async {
    _cancelFade();
    await _a.player.pause();
  }

  @override
  Future<void> seek(Duration to) async {
    _cancelFade();
    _endedTag = null;
    _pos = to;
    _position.add(to);
    await _a.player.seek(to);
  }

  @override
  Future<void> stop() async {
    _cancelFade();
    _nextPlayable = null;
    _nextTag = null;
    for (final d in _decks) {
      d
        ..tag = null
        ..hasNext = false;
      await d.player.stop();
    }
    _pos = Duration.zero;
    _dur = Duration.zero;
    _position.add(Duration.zero);
  }

  @override
  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    for (final d in _decks) {
      await _applyVolume(d);
    }
  }

  @override
  Future<void> setCrossfade(Duration d) async {
    if (d == _crossfade) return;
    _crossfade = d;
    // Re-preload the next track in the new mode.
    final p = _nextPlayable;
    final tag = _nextTag;
    if (p != null) await setNext(p, tag: tag);
  }

  @override
  Future<void> setAudioFilters(String af) async {
    for (final d in _decks) {
      await d.ready;
      await d.native.setProperty('af', af);
    }
  }

  @override
  Future<void> setReplayGain(String mode, {double preampDb = 0}) async {
    for (final d in _decks) {
      await d.ready;
      await d.native.setProperty('replaygain', mode);
      await d.native.setProperty(
        'replaygain-preamp',
        preampDb.toStringAsFixed(1),
      );
    }
  }

  @override
  Future<void> dispose() async {
    _cancelFade();
    for (final s in _subs) {
      await s.cancel();
    }
    for (final d in _decks) {
      await d.player.dispose();
    }
    await _events.close();
    await _position.close();
  }
}
