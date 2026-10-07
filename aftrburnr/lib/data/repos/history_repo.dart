import 'package:drift/drift.dart';

import '../db/database.dart';

/// A finished listen, as decided by [PlayTracker].
class Listen {
  const Listen({
    required this.trackId,
    required this.startedAt,
    required this.played,
    required this.counted,
    required this.skipped,
  });

  final String trackId;
  final DateTime startedAt;
  final Duration played;
  final bool counted;
  final bool skipped;
}

class HistoryRepo {
  HistoryRepo(this.db);
  final AppDatabase db;

  /// Records the listen and updates the per-track aggregates in one
  /// transaction. Listens shorter than a second are noise (rapid skipping
  /// through a queue) unless they were explicit skips.
  Future<void> record(Listen l) async {
    if (l.played < const Duration(seconds: 1) && !l.skipped) return;
    await db.transaction(() async {
      await db
          .into(db.playEvents)
          .insert(
            PlayEventsCompanion.insert(
              trackId: l.trackId,
              startedAt: l.startedAt,
              msPlayed: l.played.inMilliseconds,
              counted: l.counted,
              skipped: l.skipped,
            ),
          );
      await db.customStatement(
        'INSERT INTO track_stats (track_id, play_count, skip_count, last_played_at) '
        'VALUES (?, ?, ?, ?) '
        'ON CONFLICT(track_id) DO UPDATE SET '
        'play_count = play_count + excluded.play_count, '
        'skip_count = skip_count + excluded.skip_count, '
        'last_played_at = CASE WHEN excluded.last_played_at IS NULL '
        'THEN last_played_at ELSE excluded.last_played_at END',
        [
          l.trackId,
          l.counted ? 1 : 0,
          l.skipped ? 1 : 0,
          l.counted ? l.startedAt.millisecondsSinceEpoch ~/ 1000 : null,
        ],
      );
    });
  }

  /// Last time each track counted as played; tracks never played map to
  /// null (and tracks without a stats row are absent).
  Future<Map<String, DateTime?>> lastPlayed(Iterable<String> ids) async {
    final list = ids.toSet().toList();
    final out = <String, DateTime?>{};
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(
        i,
        i + 500 > list.length ? list.length : i + 500,
      );
      final rows = await (db.select(
        db.trackStats,
      )..where((t) => t.trackId.isIn(chunk))).get();
      for (final r in rows) {
        out[r.trackId] = r.lastPlayedAt;
      }
    }
    return out;
  }

  Future<TrackStatRow?> stats(String trackId) => (db.select(
    db.trackStats,
  )..where((t) => t.trackId.equals(trackId))).getSingleOrNull();

  Future<List<PlayEventRow>> recent({int limit = 50}) =>
      (db.select(db.playEvents)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();
}
