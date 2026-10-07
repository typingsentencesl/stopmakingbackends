import '../data/repos/history_repo.dart';

/// Measures how much of the current track was actually heard (seeks don't
/// count) and decides whether the listen counts as a play or a skip.
///
/// A listen counts once ≥ 30 s or ≥ 50 % of the track was heard. Moving on
/// by user action before that is a skip. Anything else (the queue was
/// replaced, the app closed) is recorded with neither flag so listening time
/// still shows up in stats.
class PlayTracker {
  static const countAfter = Duration(seconds: 30);

  String? _trackId;
  DateTime? _startedAt;
  Duration _heard = Duration.zero;
  Duration? _last;
  Duration _duration = Duration.zero;

  String? get trackId => _trackId;
  Duration get heard => _heard;

  void start(String trackId, Duration duration, DateTime now) {
    _trackId = trackId;
    _startedAt = now;
    _heard = Duration.zero;
    _last = null;
    _duration = duration;
  }

  set duration(Duration d) => _duration = d;

  void onPosition(Duration p) {
    final last = _last;
    _last = p;
    if (last == null) return;
    final diff = p - last;
    // Position ticks arrive every ~100 ms; a bigger jump is a seek.
    if (diff > Duration.zero && diff < const Duration(seconds: 2)) {
      _heard += diff;
    }
  }

  /// Forget the last position so the next tick after a seek isn't counted.
  void onSeek() => _last = null;

  bool get counts =>
      _heard >= countAfter ||
      (_duration > Duration.zero && _heard * 2 >= _duration);

  /// Ends the current listen. [userSkipped] is true when the user pressed
  /// next, picked another entry, or removed the playing one.
  Listen? finish({required bool userSkipped}) {
    final id = _trackId;
    final started = _startedAt;
    if (id == null || started == null) return null;
    final counted = counts;
    final l = Listen(
      trackId: id,
      startedAt: started,
      played: _heard,
      counted: counted,
      skipped: userSkipped && !counted,
    );
    _trackId = null;
    _startedAt = null;
    return l;
  }
}
