import '../sources/music_source.dart';

/// Events the engine reports about the *current* track. Every event that
/// concerns a specific load carries the tag that load was given, so the
/// controller can ignore late events from a track it already moved past.
sealed class EngineEvent {
  const EngineEvent();
}

class EnginePlaying extends EngineEvent {
  const EnginePlaying(this.playing);
  final bool playing;
}

class EngineBuffering extends EngineEvent {
  const EngineBuffering(this.buffering);
  final bool buffering;
}

class EngineDuration extends EngineEvent {
  const EngineDuration(this.tag, this.duration);
  final Object? tag;
  final Duration duration;
}

/// The preloaded next track (given with [AudioEngine.setNext]) is now the
/// current track — either through a gapless join or the start of a
/// crossfade.
class EngineAdvanced extends EngineEvent {
  const EngineAdvanced(this.tag);
  final Object? tag;
}

/// The current track reached its end and nothing was preloaded after it.
class EngineEnded extends EngineEvent {
  const EngineEnded(this.tag);
  final Object? tag;
}

class EngineError extends EngineEvent {
  const EngineError(this.tag, this.message);
  final Object? tag;
  final String message;
}

/// Playback backend. One implementation drives libmpv through media_kit;
/// tests use a scripted fake.
abstract interface class AudioEngine {
  Stream<EngineEvent> get events;

  /// Position of the current track. Emits often while playing.
  Stream<Duration> get position;
  Duration get currentPosition;

  /// Replace whatever is playing with [p]. [tag] identifies this load in
  /// later events.
  Future<void> load(
    Playable p, {
    required Object tag,
    bool play = true,
    Duration start = Duration.zero,
  });

  /// Preload the track that follows the current one, or clear it with null.
  /// Gapless mode joins it with no gap; crossfade mode fades into it.
  Future<void> setNext(Playable? p, {Object? tag});

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration to);
  Future<void> stop();

  /// 0.0–1.0, perceptual.
  Future<void> setVolume(double v);

  /// Zero means gapless.
  Future<void> setCrossfade(Duration d);

  /// An mpv `af` filter chain (EQ, preamp, loudness), applied live.
  Future<void> setAudioFilters(String af);

  /// `no`, `track` or `album`: ReplayGain from file tags.
  Future<void> setReplayGain(String mode, {double preampDb = 0});

  Future<void> dispose();
}
