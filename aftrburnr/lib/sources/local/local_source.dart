import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/models/track.dart';
import '../../data/db/database.dart';
import '../../data/repos/track_repo.dart';
import '../music_source.dart';
import 'tag_reader.dart';

class LocalSource implements MusicSource {
  LocalSource({required this.db, required this.artDir});

  final AppDatabase db;

  /// Folder for album art extracted from tags.
  final String artDir;

  late final TrackRepo _tracks = TrackRepo(db);
  final _health = ValueNotifier<SourceHealth>(const SourceReady());

  @override
  String get id => 'local';

  @override
  String get label => 'LOCAL';

  @override
  ValueListenable<SourceHealth> get health => _health;

  /// Reads tags for [paths] off the UI isolate and stores the tracks.
  /// Non-audio paths are ignored. Returns tracks in the order given.
  Future<List<Track>> importFiles(List<String> paths) async {
    final audio = paths.where(isAudioFile).toList();
    if (audio.isEmpty) return const [];
    final dir = artDir;
    final now = DateTime.now();
    final results = await Isolate.run(() => readTracks(audio, dir, now));
    final tracks = [for (final r in results) r.track];
    await _tracks.upsertAll(tracks);
    // Re-read so tracks that already existed keep their original addedAt.
    final stored = await _tracks.byIds(tracks.map((t) => t.id));
    return [for (final t in tracks) stored[t.id] ?? t];
  }

  @override
  Future<List<Track>> search(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final like = '%${q.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    Expression<bool> m(GeneratedColumn<String> c) =>
        c.like(like, escapeChar: r'\');
    final rows =
        await (db.select(db.tracks)
              ..where(
                (t) =>
                    t.source.equals('local') &
                    (m(t.title) | m(t.artist) | m(t.album) | m(t.genre)),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.title)])
              ..limit(limit))
            .get();
    return rows.map(trackFromRow).toList();
  }

  @override
  Future<Playable> resolve(Track track) async {
    final path = track.uri;
    if (path.isEmpty || !await File(path).exists()) {
      throw UnplayableException(
        'File not found: $path. It may have been moved, or its drive '
        "isn't connected.",
      );
    }
    return Playable(path);
  }

  @override
  Future<void> dispose() async => _health.dispose();
}
