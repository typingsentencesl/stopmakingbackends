import 'package:aftrburnr/app/services.dart';
import 'package:aftrburnr/audio/engine.dart';
import 'package:aftrburnr/audio/player_controller.dart';
import 'package:aftrburnr/audio/queue.dart';
import 'package:aftrburnr/data/db/database.dart';
import 'package:aftrburnr/data/repos/history_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeEngine engine;
  late FakeSource source;
  late Services services;
  late ProviderContainer container;

  PlayerController ctl() => container.read(playerProvider.notifier);
  PlayerState st() => container.read(playerProvider);

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await ctl().idle;
      await Future<void>.delayed(Duration.zero);
    }
  }

  ProviderContainer makeContainer() => ProviderContainer(
    overrides: [servicesProvider.overrideWithValue(services)],
  );

  setUp(() async {
    db = memoryDb();
    engine = FakeEngine();
    source = FakeSource('fake');
    services = fakeServices(db: db, engine: engine, source: source);
    container = makeContainer();
    container.read(playerProvider);
    await settle();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  final tracks = [for (var i = 0; i < 5; i++) fakeTrack(i)];

  test('play loads the chosen track and preloads the next', () async {
    await ctl().playTracks(tracks, startIndex: 1);
    await settle();
    expect(engine.loadedUri, 'mem://fake:t1');
    expect(engine.nextUri, 'mem://fake:t2');
    expect(st().current!.id, 'fake:t1');
  });

  test('gapless advance moves the queue and records a counted play', () async {
    await ctl().playTracks(tracks);
    await settle();
    engine.playFor(40);
    engine.advance();
    await settle();
    expect(st().current!.id, 'fake:t1');
    expect(engine.nextUri, 'mem://fake:t2');
    final s = await services.history.stats('fake:t0');
    expect(s!.playCount, 1);
    expect(s.skipCount, 0);
    expect(s.lastPlayedAt, isNotNull);
  });

  test('pressing next early records a skip, not a play', () async {
    await ctl().playTracks(tracks);
    await settle();
    engine.playFor(5);
    await ctl().next();
    await settle();
    final s = await services.history.stats('fake:t0');
    expect(s!.playCount, 0);
    expect(s.skipCount, 1);
    expect(engine.loadedUri, 'mem://fake:t1');
  });

  test('seeking does not count as listening', () async {
    await ctl().playTracks(tracks);
    await settle();
    engine.playFor(2);
    await ctl().seek(const Duration(seconds: 150));
    engine.tick(const Duration(seconds: 150));
    engine.playFor(2);
    await ctl().next();
    await settle();
    final events = await services.history.recent();
    expect(events.single.msPlayed, inInclusiveRange(3800, 4000));
    expect(events.single.skipped, isTrue);
  });

  test('end of the queue stops; play next changes what is preloaded', () async {
    await ctl().playTracks(tracks.take(2).toList());
    await settle();
    expect(engine.nextUri, 'mem://fake:t1');
    await ctl().playNext([fakeTrack(9)]);
    await settle();
    expect(engine.nextUri, 'mem://fake:t9');
    engine.advance();
    await settle();
    expect(st().current!.id, 'fake:t9');
    expect(engine.nextUri, 'mem://fake:t1');
    engine.advance();
    await settle();
    expect(engine.nextUri, isNull);
    engine.emit(EngineEnded(st().queue.currentEntry!.uid));
    await settle();
    expect(st().playing, isFalse);
    expect(st().current!.id, 'fake:t1');
  });

  test('unplayable tracks are skipped with a readable error', () async {
    source.broken.add('fake:t1');
    await ctl().playTracks(tracks, startIndex: 1);
    await settle();
    expect(engine.loadedUri, 'mem://fake:t2');
    expect(st().error, contains('Track 1 is broken'));
  });

  test('engine errors skip to the next track', () async {
    await ctl().playTracks(tracks);
    await settle();
    engine.emit(EngineError(st().queue.currentEntry!.uid, 'Failed to open'));
    await settle();
    expect(engine.loadedUri, 'mem://fake:t1');
    expect(st().error, contains('Failed to open'));
  });

  test('previous restarts the track after 3 s, goes back before', () async {
    await ctl().playTracks(tracks, startIndex: 2);
    await settle();
    engine.playFor(5);
    await ctl().previous();
    await settle();
    expect(engine.log.last, 'seek 0');
    expect(st().current!.id, 'fake:t2');
    engine.tick(const Duration(seconds: 1));
    await ctl().previous();
    await settle();
    expect(st().current!.id, 'fake:t1');
  });

  test('repeat one preloads the same entry for a gapless loop', () async {
    await ctl().playTracks(tracks);
    await ctl().cycleRepeat(); // all
    await ctl().cycleRepeat(); // one
    await settle();
    expect(st().queue.repeat, QueueRepeat.one);
    expect(engine.nextUri, 'mem://fake:t0');
    engine.advance();
    await settle();
    expect(st().current!.id, 'fake:t0');
    expect(st().queue.current, 0);
  });

  test('removing the playing entry loads the following one', () async {
    await ctl().playTracks(tracks);
    await settle();
    await ctl().remove({st().queue.currentEntry!.uid});
    await settle();
    expect(engine.loadedUri, 'mem://fake:t1');
    expect(st().queue.entries.length, 4);
  });

  test('reordering upcoming entries updates the preload', () async {
    await ctl().playTracks(tracks);
    await settle();
    final last = st().queue.entries.last.uid;
    await ctl().move({last}, 1);
    await settle();
    expect(engine.nextUri, 'mem://fake:t4');
  });

  test('queue, position and volume survive a restart', () async {
    await ctl().playTracks(tracks, startIndex: 2);
    await ctl().setVolume(0.42);
    await ctl().setShuffle(ShuffleMode.random);
    await settle();
    engine.playFor(12);
    await ctl().save();
    final before = st().queue;
    container.dispose();

    final engine2 = FakeEngine();
    services = fakeServices(db: db, engine: engine2, source: source);
    container = makeContainer();
    container.read(playerProvider);
    await settle();
    expect(st().restored, isTrue);
    expect(st().queue.entries, before.entries);
    expect(st().queue.current, before.current);
    expect(st().queue.shuffle, ShuffleMode.random);
    expect(st().volume, closeTo(0.42, 1e-9));
    expect(engine2.loadedUri, 'mem://fake:t2');
    expect(engine2.loadedPlay, isFalse);
    expect(engine2.loadedStart.inSeconds, 12);
  });

  test('least recently played shuffle uses play history', () async {
    // t3 was played long ago, t1 recently; the rest never.
    Listen heard(String id, int daysAgo) => Listen(
      trackId: id,
      startedAt: DateTime.now().subtract(Duration(days: daysAgo)),
      played: const Duration(minutes: 3),
      counted: true,
      skipped: false,
    );
    await ctl().playTracks(tracks);
    await settle();
    await services.history.record(heard('fake:t3', 30));
    await services.history.record(heard('fake:t1', 1));
    await ctl().setShuffle(ShuffleMode.leastRecent);
    await settle();
    final up = [for (final e in st().queue.upcoming) e.trackId];
    expect(up.take(2).toSet(), {'fake:t2', 'fake:t4'});
    expect(up.skip(2), ['fake:t3', 'fake:t1']);
  });
}
