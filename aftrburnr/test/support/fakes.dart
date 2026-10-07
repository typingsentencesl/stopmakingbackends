import 'dart:async';

import 'package:aftrburnr/app/services.dart';
import 'package:aftrburnr/audio/engine.dart';
import 'package:aftrburnr/core/models/track.dart';
import 'package:aftrburnr/data/db/database.dart';
import 'package:aftrburnr/sources/local/local_source.dart';
import 'package:aftrburnr/sources/music_source.dart';
import 'package:aftrburnr/sources/source_registry.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';

/// Records what the controller asks of the engine; the test drives events.
class FakeEngine implements AudioEngine {
  final _events = StreamController<EngineEvent>.broadcast(sync: true);
  final _pos = StreamController<Duration>.broadcast(sync: true);

  final List<String> log = [];
  String? loadedUri;
  Object? loadedTag;
  bool loadedPlay = false;
  Duration loadedStart = Duration.zero;
  String? nextUri;
  Object? nextTag;
  bool playing = false;
  double volume = 1;
  Duration crossfade = Duration.zero;
  String filters = '';
  Duration pos = Duration.zero;

  @override
  Stream<EngineEvent> get events => _events.stream;
  @override
  Stream<Duration> get position => _pos.stream;
  @override
  Duration get currentPosition => pos;

  void emit(EngineEvent e) => _events.add(e);

  void tick(Duration p) {
    pos = p;
    _pos.add(p);
  }

  /// Simulate [seconds] of continuous playback in 100 ms ticks.
  void playFor(int seconds) {
    for (var i = 0; i < seconds * 10; i++) {
      tick(pos + const Duration(milliseconds: 100));
    }
  }

  /// Simulate a gapless join into whatever was preloaded.
  void advance() {
    final tag = nextTag;
    loadedUri = nextUri;
    loadedTag = tag;
    nextUri = null;
    nextTag = null;
    pos = Duration.zero;
    emit(EngineAdvanced(tag));
  }

  @override
  Future<void> load(
    Playable p, {
    required Object tag,
    bool play = true,
    Duration start = Duration.zero,
  }) async {
    log.add('load ${p.uri}');
    loadedUri = p.uri;
    loadedTag = tag;
    loadedPlay = play;
    loadedStart = start;
    nextUri = null;
    nextTag = null;
    pos = start;
    playing = play;
    emit(EnginePlaying(play));
  }

  @override
  Future<void> setNext(Playable? p, {Object? tag}) async {
    log.add('next ${p?.uri}');
    nextUri = p?.uri;
    nextTag = tag;
  }

  @override
  Future<void> play() async {
    playing = true;
    emit(const EnginePlaying(true));
  }

  @override
  Future<void> pause() async {
    playing = false;
    emit(const EnginePlaying(false));
  }

  @override
  Future<void> seek(Duration to) async {
    log.add('seek ${to.inSeconds}');
    pos = to;
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    loadedUri = null;
    playing = false;
    emit(const EnginePlaying(false));
  }

  @override
  Future<void> setVolume(double v) async => volume = v;
  @override
  Future<void> setCrossfade(Duration d) async => crossfade = d;
  @override
  Future<void> setAudioFilters(String af) async => filters = af;
  @override
  Future<void> setReplayGain(String mode, {double preampDb = 0}) async {}
  @override
  Future<void> dispose() async {
    await _events.close();
    await _pos.close();
  }
}

/// A source whose tracks resolve to `mem://<id>` unless listed as broken.
class FakeSource implements MusicSource {
  FakeSource(this.id);

  @override
  final String id;
  final Set<String> broken = {};

  @override
  String get label => id.toUpperCase();

  @override
  ValueListenable<SourceHealth> get health =>
      ValueNotifier(const SourceReady());

  @override
  Future<List<Track>> search(String query, {int limit = 20}) async => const [];

  @override
  Future<Playable> resolve(Track track) async {
    if (broken.contains(track.id)) {
      throw UnplayableException('${track.title} is broken');
    }
    return Playable('mem://${track.id}');
  }

  @override
  Future<void> dispose() async {}
}

Track fakeTrack(int i, {String source = 'fake', int seconds = 200}) => Track(
  id: trackIdOf(source, 't$i'),
  source: source,
  sourceId: 't$i',
  title: 'Track $i',
  artist: 'Artist ${i % 3}',
  album: 'Album ${i % 2}',
  duration: Duration(seconds: seconds),
);

AppDatabase memoryDb() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

Services fakeServices({
  AppDatabase? db,
  FakeEngine? engine,
  FakeSource? source,
}) {
  final d = db ?? memoryDb();
  final local = LocalSource(db: d, artDir: '/tmp/aftrburnr-test-art');
  return Services(
    db: d,
    engine: engine ?? FakeEngine(),
    local: local,
    registry: SourceRegistry([local, source ?? FakeSource('fake')]),
  );
}
