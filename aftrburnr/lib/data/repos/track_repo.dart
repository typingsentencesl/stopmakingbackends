import 'package:drift/drift.dart';

import '../../core/models/track.dart';
import '../db/database.dart';

Track trackFromRow(TrackRow r) => Track(
  id: r.id,
  source: r.source,
  sourceId: r.sourceId,
  title: r.title,
  artist: r.artist,
  album: r.album,
  albumArtist: r.albumArtist,
  trackNo: r.trackNo,
  discNo: r.discNo,
  year: r.year,
  genre: r.genre,
  duration: Duration(milliseconds: r.durationMs),
  uri: r.uri,
  artUri: r.artUri,
  addedAt: r.addedAt,
  inLibrary: r.inLibrary,
  available: r.available,
);

TracksCompanion trackToCompanion(Track t, {int? fileMtimeMs}) =>
    TracksCompanion(
      id: Value(t.id),
      source: Value(t.source),
      sourceId: Value(t.sourceId),
      title: Value(t.title),
      artist: Value(t.artist),
      album: Value(t.album),
      albumArtist: Value(t.albumArtist),
      trackNo: Value(t.trackNo),
      discNo: Value(t.discNo),
      year: Value(t.year),
      genre: Value(t.genre),
      durationMs: Value(t.duration.inMilliseconds),
      uri: Value(t.uri),
      artUri: Value(t.artUri),
      addedAt: Value(t.addedAt),
      inLibrary: Value(t.inLibrary),
      available: Value(t.available),
      fileMtimeMs: fileMtimeMs == null
          ? const Value.absent()
          : Value(fileMtimeMs),
    );

class TrackRepo {
  TrackRepo(this.db);
  final AppDatabase db;

  /// Insert or update. `inLibrary` and `addedAt` are never downgraded by an
  /// upsert: a track added to the library stays there when it is later
  /// re-imported through, say, the queue.
  Future<void> upsertAll(List<Track> tracks) async {
    if (tracks.isEmpty) return;
    await db.batch((b) {
      for (final t in tracks) {
        b.insert(
          db.tracks,
          trackToCompanion(t),
          onConflict: DoUpdate<$TracksTable, TrackRow>.withExcluded(
            (old, ex) => TracksCompanion.custom(
              title: ex.title,
              artist: ex.artist,
              album: ex.album,
              albumArtist: ex.albumArtist,
              trackNo: ex.trackNo,
              discNo: ex.discNo,
              year: ex.year,
              genre: ex.genre,
              durationMs: ex.durationMs,
              uri: ex.uri,
              artUri: ex.artUri,
              available: ex.available,
              inLibrary: old.inLibrary | ex.inLibrary,
              addedAt: coalesce([old.addedAt, ex.addedAt]),
            ),
          ),
        );
      }
    });
  }

  Future<Map<String, Track>> byIds(Iterable<String> ids) async {
    final set = ids.toSet();
    if (set.isEmpty) return const {};
    final out = <String, Track>{};
    // SQLite caps bound variables; chunk large queues.
    final list = set.toList();
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(
        i,
        i + 500 > list.length ? list.length : i + 500,
      );
      final rows = await (db.select(
        db.tracks,
      )..where((t) => t.id.isIn(chunk))).get();
      for (final r in rows) {
        out[r.id] = trackFromRow(r);
      }
    }
    return out;
  }

  Future<Track?> byId(String id) async {
    final r = await (db.select(
      db.tracks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : trackFromRow(r);
  }

  Future<void> setDuration(String id, Duration d) async {
    await (db.update(db.tracks)..where((t) => t.id.equals(id))).write(
      TracksCompanion(durationMs: Value(d.inMilliseconds)),
    );
  }
}
