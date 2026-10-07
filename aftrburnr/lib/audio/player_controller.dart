import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/services.dart';
import '../core/models/track.dart';
import '../sources/music_source.dart';
import 'engine.dart';
import 'play_tracker.dart';
import 'queue.dart';
import 'shuffle.dart';

class PlayerState {
  const PlayerState({
    this.queue = PlayQueue.empty,
    this.tracks = const {},
    this.playing = false,
    this.buffering = false,
    this.duration = Duration.zero,
    this.volume = 0.8,
    this.error,
    this.restored = false,
  });

  final PlayQueue queue;

  /// Every track referenced by [queue], by id.
  final Map<String, Track> tracks;
  final bool playing;
  final bool buffering;
  final Duration duration;
  final double volume;

  /// Last playback problem, phrased for the user. Cleared on the next
  /// successful load.
  final String? error;

  /// False until the saved queue has been read back on startup.
  final bool restored;

  Track? get current {
    final e = queue.currentEntry;
    return e == null ? null : tracks[e.trackId];
  }

  Track? trackOf(QueueEntry e) => tracks[e.trackId];

  PlayerState copyWith({
    PlayQueue? queue,
    Map<String, Track>? tracks,
    bool? playing,
    bool? buffering,
    Duration? duration,
    double? volume,
    String? error,
    bool clearError = false,
    bool? restored,
  }) {
    return PlayerState(
      queue: queue ?? this.queue,
      tracks: tracks ?? this.tracks,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      error: clearError ? null : (error ?? this.error),
      restored: restored ?? this.restored,
    );
  }
}

final playerProvider = NotifierProvider<PlayerController, PlayerState>(
  PlayerController.new,
);

/// Position of the current track, separate from [playerProvider] so only
/// widgets that show progress rebuild ten times a second.
final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(servicesProvider).engine.position;
});

/// Joins the queue model, the engine, play counting and persistence.
class PlayerController extends Notifier<PlayerState> {
  late Services _s;
  AudioEngine get _engine => _s.engine;
  final _tracker = PlayTracker();
  final List<StreamSubscription<Object?>> _subs = [];
  Random random = secureRandom;

  /// Uid of the entry the engine has preloaded as next, if any.
  int? _preloadedUid;

  /// The queue state to switch to when the preloaded entry starts.
  PlayQueue? _queueAfterAdvance;

  int _failuresInARow = 0;
  Timer? _saveTimer;
  DateTime _lastPositionSave = DateTime.fromMillisecondsSinceEpoch(0);
  Duration _position = Duration.zero;

  /// Serialises queue mutations that touch the engine.
  Future<void> _op = Future.value();

  @override
  PlayerState build() {
    _s = ref.watch(servicesProvider);
    _subs.add(_engine.events.listen(_onEngineEvent));
    _subs.add(_engine.position.listen(_onPosition));
    ref.onDispose(() {
      for (final s in _subs) {
        unawaited(s.cancel());
      }
      _saveTimer?.cancel();
      final l = _tracker.finish(userSkipped: false);
      if (l != null) unawaited(_s.history.record(l));
    });
    // Restore runs through the same serial queue as every other queue
    // change, so a command-line "open" can't race it.
    Future.microtask(() => _serial(_restore));
    return const PlayerState();
  }

  /// Completes once every queued queue operation has finished.
  Future<void> get idle async {
    Future<void> seen;
    do {
      seen = _op;
      await seen;
    } while (!identical(seen, _op));
  }

  Future<T> _serial<T>(Future<T> Function() f) {
    final c = Completer<T>();
    _op = _op.then((_) async {
      try {
        c.complete(await f());
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    return c.future;
  }

  // ---------------------------------------------------------------- restore

  Future<void> _restore() async {
    try {
      final vol = await _s.settings.read('volume');
      final volume = vol is num ? vol.toDouble().clamp(0.0, 1.0) : 0.8;
      await _engine.setVolume(volume);
      final saved = await _s.settings.read('queue');
      if (saved is! Map) {
        state = state.copyWith(volume: volume, restored: true);
        return;
      }
      var q = PlayQueue.fromJson(
        Map<String, dynamic>.from(saved['queue'] as Map),
      );
      final tracks = await _s.tracks.byIds(q.entries.map((e) => e.trackId));
      // Drop entries whose track row no longer exists.
      final missing = {
        for (final e in q.entries)
          if (!tracks.containsKey(e.trackId)) e.uid,
      };
      q = q.remove(missing);
      final pos = Duration(
        milliseconds: (saved['positionMs'] as num?)?.toInt() ?? 0,
      );
      state = state.copyWith(
        queue: q,
        tracks: tracks,
        volume: volume,
        restored: true,
      );
      if (q.currentEntry != null) {
        await _loadCurrent(play: false, start: pos);
      }
    } catch (e) {
      state = state.copyWith(
        restored: true,
        error: 'Couldn’t restore the last queue: $e',
      );
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), save);
  }

  Future<void> save() async {
    await _s.settings.write('queue', {
      'queue': state.queue.toJson(),
      'positionMs': _position.inMilliseconds,
    });
  }

  // ---------------------------------------------------------------- loading

  Future<Map<String, DateTime?>> _lastPlayed(PlayQueue q) =>
      _s.history.lastPlayed(q.entries.map((e) => e.trackId));

  /// Where the queue goes when the current track ends on its own. A
  /// least-recently-played queue that wraps (repeat all) is re-ordered with
  /// fresh play dates.
  Future<Advance> _naturalNext() async {
    final q = state.queue;
    final wraps =
        q.repeat == QueueRepeat.all &&
        q.shuffle == ShuffleMode.leastRecent &&
        q.current == q.entries.length - 1;
    return q.next(
      random: random,
      lastPlayed: wraps ? await _lastPlayed(q) : const {},
    );
  }

  void _setQueue(PlayQueue q, {Map<String, Track>? addTracks}) {
    state = state.copyWith(
      queue: q,
      tracks: addTracks == null ? null : {...state.tracks, ...addTracks},
    );
    _scheduleSave();
  }

  Future<void> _loadCurrent({
    bool play = true,
    Duration start = Duration.zero,
    bool userSkipped = false,
    bool clearError = true,
  }) async {
    _finishListen(userSkipped: userSkipped);
    final entry = state.queue.currentEntry;
    _preloadedUid = null;
    _queueAfterAdvance = null;
    if (entry == null) {
      await _engine.stop();
      state = state.copyWith(playing: false, duration: Duration.zero);
      return;
    }
    final track = state.tracks[entry.trackId];
    if (track == null) return;
    try {
      final p = await _s.registry.resolve(track);
      _position = start;
      state = state.copyWith(duration: track.duration, clearError: clearError);
      _tracker.start(track.id, track.duration, DateTime.now());
      await _engine.load(p, tag: entry.uid, play: play, start: start);
      await _preloadNext();
    } on UnplayableException catch (e) {
      await _skipBroken(e.message);
    }
  }

  /// Tells the engine which entry follows the current one, so it can join
  /// gaplessly or crossfade. Called after every queue change.
  Future<void> _preloadNext() async {
    final a = await _naturalNext();
    final nextEntry = a.ended ? null : a.queue.currentEntry;
    if (nextEntry == null) {
      if (_preloadedUid != null) await _engine.setNext(null);
      _preloadedUid = null;
      _queueAfterAdvance = null;
      return;
    }
    _queueAfterAdvance = a.queue;
    if (_preloadedUid == nextEntry.uid) return;
    final track = state.tracks[nextEntry.trackId];
    if (track == null) return;
    try {
      final p = await _s.registry.resolve(track);
      _preloadedUid = nextEntry.uid;
      await _engine.setNext(p, tag: nextEntry.uid);
    } on UnplayableException {
      // It will be reported when the queue actually reaches it.
      _preloadedUid = null;
      await _engine.setNext(null);
    }
  }

  Future<void> _skipBroken(String message) async {
    _failuresInARow++;
    state = state.copyWith(error: message);
    if (_failuresInARow >= max(1, state.queue.entries.length)) {
      _failuresInARow = 0;
      await _engine.stop();
      state = state.copyWith(playing: false);
      return;
    }
    final a = state.queue.next(user: true, random: random);
    if (a.ended) {
      await _engine.stop();
      state = state.copyWith(playing: false);
      return;
    }
    _setQueue(a.queue);
    // Keep the message up: the user should see what was skipped and why.
    await _loadCurrent(clearError: false);
  }

  void _finishListen({required bool userSkipped}) {
    final l = _tracker.finish(userSkipped: userSkipped);
    if (l != null) unawaited(_s.history.record(l));
  }

  // ----------------------------------------------------------- engine events

  void _onEngineEvent(EngineEvent e) {
    switch (e) {
      case EnginePlaying(:final playing):
        state = state.copyWith(playing: playing);
      case EngineBuffering(:final buffering):
        state = state.copyWith(buffering: buffering);
      case EngineDuration(:final tag, :final duration):
        if (tag != state.queue.currentEntry?.uid) return;
        _tracker.duration = duration;
        state = state.copyWith(duration: duration);
        final t = state.current;
        // Tag durations can be missing or estimated (VBR MP3 without a
        // Xing header); trust what the decoder measured.
        if (t != null &&
            (t.duration - duration).abs() > const Duration(milliseconds: 500)) {
          unawaited(_s.tracks.setDuration(t.id, duration));
          state = state.copyWith(
            tracks: {
              ...state.tracks,
              t.id: t.copyWith(duration: duration),
            },
          );
        }
      case EngineAdvanced(:final tag):
        unawaited(_serial(() => _onAdvanced(tag)));
      case EngineEnded(:final tag):
        unawaited(_serial(() => _onEnded(tag)));
      case EngineError(:final tag, :final message):
        if (tag != state.queue.currentEntry?.uid) return;
        unawaited(_serial(() => _skipBroken(_describe(message))));
    }
  }

  String _describe(String mpvMessage) {
    final t = state.current;
    final name = t == null ? 'This track' : '“${t.title}”';
    return '$name couldn’t be played ($mpvMessage). Skipped to the next one.';
  }

  Future<void> _onAdvanced(Object? tag) async {
    final next = _queueAfterAdvance;
    if (tag != _preloadedUid || next == null) return;
    _finishListen(userSkipped: false);
    _failuresInARow = 0;
    _preloadedUid = null;
    _queueAfterAdvance = null;
    _position = Duration.zero;
    _setQueue(next);
    final t = state.current;
    state = state.copyWith(
      duration: t?.duration ?? Duration.zero,
      clearError: true,
    );
    if (t != null) _tracker.start(t.id, t.duration, DateTime.now());
    await _preloadNext();
  }

  Future<void> _onEnded(Object? tag) async {
    if (tag != state.queue.currentEntry?.uid) return;
    final a = await _naturalNext();
    if (a.ended) {
      _finishListen(userSkipped: false);
      state = state.copyWith(playing: false);
      return;
    }
    _setQueue(a.queue);
    await _loadCurrent();
  }

  void _onPosition(Duration p) {
    _position = p;
    _tracker.onPosition(p);
    final now = DateTime.now();
    if (state.playing && now.difference(_lastPositionSave).inSeconds >= 5) {
      _lastPositionSave = now;
      unawaited(save());
    }
  }

  // ------------------------------------------------------------- public API

  Future<void> _ensureTracks(List<Track> tracks) async {
    await _s.tracks.upsertAll(tracks);
  }

  /// Replace the queue with [tracks] and start playing at [startIndex].
  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) =>
      _serial(() async {
        if (tracks.isEmpty) return;
        await _ensureTracks(tracks);
        final ids = [for (final t in tracks) t.id];
        final q = state.queue.replace(
          ids,
          startIndex: startIndex,
          random: random,
          lastPlayed: state.queue.shuffle == ShuffleMode.leastRecent
              ? await _s.history.lastPlayed(ids)
              : const {},
        );
        _failuresInARow = 0;
        _setQueue(q, addTracks: {for (final t in tracks) t.id: t});
        await _loadCurrent(userSkipped: true);
      });

  Future<void> playNext(List<Track> tracks) => _serial(() async {
    if (tracks.isEmpty) return;
    await _ensureTracks(tracks);
    final wasEmpty = state.queue.currentEntry == null;
    _setQueue(
      state.queue.playNext([for (final t in tracks) t.id]),
      addTracks: {for (final t in tracks) t.id: t},
    );
    if (wasEmpty) {
      await _loadCurrent();
    } else {
      await _preloadNext();
    }
  });

  Future<void> playLast(List<Track> tracks) => _serial(() async {
    if (tracks.isEmpty) return;
    await _ensureTracks(tracks);
    final wasEmpty = state.queue.currentEntry == null;
    _setQueue(
      state.queue.playLast([for (final t in tracks) t.id], random: random),
      addTracks: {for (final t in tracks) t.id: t},
    );
    if (wasEmpty) {
      await _loadCurrent();
    } else {
      await _preloadNext();
    }
  });

  Future<void> togglePlay() async {
    if (state.queue.currentEntry == null) return;
    if (state.playing) {
      await _engine.pause();
    } else {
      await _engine.play();
    }
  }

  Future<void> play() => _engine.play();
  Future<void> pause() => _engine.pause();

  Future<void> next() => _serial(() async {
    final a = state.queue.next(user: true, random: random);
    if (a.ended) return;
    _failuresInARow = 0;
    _setQueue(a.queue);
    await _loadCurrent(userSkipped: true);
  });

  /// Restarts the track when more than 3 s in, like every hardware player.
  Future<void> previous() => _serial(() async {
    if (_position > const Duration(seconds: 3)) {
      _tracker.onSeek();
      await _engine.seek(Duration.zero);
      return;
    }
    final a = state.queue.previous();
    if (a.ended) {
      await _engine.seek(Duration.zero);
      return;
    }
    _setQueue(a.queue);
    await _loadCurrent(userSkipped: true);
  });

  Future<void> seek(Duration to) async {
    _tracker.onSeek();
    _position = to;
    await _engine.seek(to);
  }

  Future<void> seekBy(Duration d) {
    final dur = state.duration;
    var to = _position + d;
    if (to < Duration.zero) to = Duration.zero;
    if (dur > Duration.zero && to > dur) to = dur;
    return seek(to);
  }

  Future<void> setVolume(double v) async {
    final vol = v.clamp(0.0, 1.0);
    state = state.copyWith(volume: vol);
    await _engine.setVolume(vol);
    await _s.settings.write('volume', vol);
  }

  double _unmuted = 0.8;

  Future<void> toggleMute() async {
    if (state.volume > 0) {
      _unmuted = state.volume;
      await setVolume(0);
    } else {
      await setVolume(_unmuted == 0 ? 0.8 : _unmuted);
    }
  }

  Future<void> jumpTo(int uid) => _serial(() async {
    if (uid == state.queue.currentEntry?.uid) {
      await _engine.seek(Duration.zero);
      await _engine.play();
      return;
    }
    _failuresInARow = 0;
    _setQueue(state.queue.jumpTo(uid));
    await _loadCurrent(userSkipped: true);
  });

  Future<void> remove(Set<int> uids) => _serial(() async {
    final cur = state.queue.currentEntry?.uid;
    final wasPlaying = state.playing;
    _setQueue(state.queue.remove(uids));
    if (cur != null && uids.contains(cur)) {
      await _loadCurrent(play: wasPlaying, userSkipped: true);
    } else {
      await _preloadNext();
    }
  });

  /// Removes every upcoming entry, keeping what's playing and what played.
  Future<void> clearUpcoming() =>
      remove({for (final e in state.queue.upcoming) e.uid});

  /// Removes entries that already played this session.
  Future<void> clearPlayed() =>
      remove({for (final e in state.queue.played) e.uid});

  Future<void> move(Set<int> uids, int toIndex) => _serial(() async {
    _setQueue(state.queue.move(uids, toIndex));
    await _preloadNext();
  });

  /// "Play next" for rows already in the queue.
  Future<void> makeNext(Set<int> uids) => _serial(() async {
    _setQueue(state.queue.makeNext(uids));
    await _preloadNext();
  });

  Future<void> setShuffle(ShuffleMode mode) => _serial(() async {
    final q = state.queue.withShuffle(
      mode,
      random: random,
      lastPlayed: mode == ShuffleMode.leastRecent
          ? await _lastPlayed(state.queue)
          : const {},
    );
    _setQueue(q);
    await _preloadNext();
  });

  /// off → random → least recently played → off.
  Future<void> cycleShuffle() => setShuffle(switch (state.queue.shuffle) {
    ShuffleMode.off => ShuffleMode.random,
    ShuffleMode.random => ShuffleMode.leastRecent,
    ShuffleMode.leastRecent => ShuffleMode.off,
  });

  Future<void> cycleRepeat() => _serial(() async {
    final next = switch (state.queue.repeat) {
      QueueRepeat.off => QueueRepeat.all,
      QueueRepeat.all => QueueRepeat.one,
      QueueRepeat.one => QueueRepeat.off,
    };
    _setQueue(state.queue.withRepeat(next));
    await _preloadNext();
  });

  void dismissError() => state = state.copyWith(clearError: true);
}
