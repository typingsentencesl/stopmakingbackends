// Real libmpv playback through MpvEngine, with audio output set to null so
// it runs headless. Needs libmpv and ffmpeg on the machine, so it only runs
// when AFTRBURNR_MPV_TESTS=1:
//
//   AFTRBURNR_MPV_TESTS=1 flutter test test/engine_mpv_test.dart
@Tags(['mpv'])
library;

import 'dart:async';
import 'dart:io';

import 'package:aftrburnr/audio/engine.dart';
import 'package:aftrburnr/audio/mpv_engine.dart';
import 'package:aftrburnr/sources/local/tag_reader.dart';
import 'package:aftrburnr/sources/music_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' hide Playable;
import 'package:path/path.dart' as p;

final enabled = Platform.environment['AFTRBURNR_MPV_TESTS'] == '1';

late Directory dir;

String tone(
  String name,
  double seconds,
  int hz, {
  String ext = 'flac',
  bool art = false,
}) {
  final out = p.join(dir.path, '$name.$ext');
  final cover = p.join(dir.path, 'cover.png');
  if (art && !File(cover).existsSync()) {
    final r = Process.runSync('ffmpeg', [
      '-y',
      '-loglevel',
      'error',
      '-f',
      'lavfi',
      '-i',
      'color=c=0x804020:s=64x64',
      '-frames:v',
      '1',
      cover,
    ]);
    if (r.exitCode != 0) throw StateError('ffmpeg failed: ${r.stderr}');
  }
  final args = [
    '-y',
    '-loglevel',
    'error',
    '-f',
    'lavfi',
    '-i',
    'sine=frequency=$hz:duration=$seconds:sample_rate=44100',
    if (art) ...[
      '-i',
      cover,
      '-map',
      '0:a',
      '-map',
      '1:v',
      '-c:v',
      'png',
      '-disposition:v',
      'attached_pic',
    ],
    '-metadata',
    'title=Tone $name',
    '-metadata',
    'artist=Generator',
    '-metadata',
    'album=Test Tones',
    '-metadata',
    'track=${name.codeUnitAt(0) - 64}',
    '-metadata',
    'date=2024',
    '-metadata',
    'genre=Test',
    if (ext == 'mp3') ...['-id3v2_version', '3'],
    out,
  ];
  final r = Process.runSync('ffmpeg', args);
  if (r.exitCode != 0) throw StateError('ffmpeg failed: ${r.stderr}');
  return out;
}

Future<T> waitFor<T extends EngineEvent>(
  Stream<EngineEvent> events,
  bool Function(T) test, {
  Duration timeout = const Duration(seconds: 15),
}) {
  return events
      .where((e) => e is T && test(e))
      .cast<T>()
      .first
      .timeout(timeout);
}

void main() {
  if (!enabled) {
    test(
      'libmpv engine (set AFTRBURNR_MPV_TESTS=1 to run)',
      () {},
      skip: 'needs libmpv + ffmpeg',
    );
    return;
  }

  setUpAll(() {
    MediaKit.ensureInitialized();
    dir = Directory.systemTemp.createTempSync('aftrburnr_mpv');
  });

  tearDownAll(() => dir.deleteSync(recursive: true));

  test('tag reader reads tags, duration and embedded art', () {
    final mp3 = tone('A', 2, 440, ext: 'mp3', art: true);
    final flac = tone('B', 1.5, 660);
    final r = readTracks([mp3, flac], p.join(dir.path, 'art'), DateTime(2026));
    expect(r, hasLength(2));
    final a = r[0].track;
    expect(a.title, 'Tone A');
    expect(a.artist, 'Generator');
    expect(a.album, 'Test Tones');
    expect(a.year, 2024);
    expect(a.genre, 'Test');
    expect(a.trackNo, 1);
    // MP3 durations from tags are estimates; mpv's measured duration
    // replaces them on first play (see PlayerController).
    expect(a.duration.inMilliseconds, closeTo(2000, 500));
    expect(a.artUri, isNotNull);
    expect(File(a.artUri!).existsSync(), isTrue);
    expect(r[1].track.duration.inMilliseconds, closeTo(1500, 100));
    expect(r[1].track.id, startsWith('local:'));
  });

  test(
    'gapless: the preloaded track follows with no reload, then ends',
    () async {
      final engine = MpvEngine(audioOutput: 'null');
      addTearDown(engine.dispose);
      final a = tone('C', 1.5, 300);
      final b = tone('D', 1.5, 500);
      final advanced = waitFor<EngineAdvanced>(
        engine.events,
        (e) => e.tag == 2,
      );
      final ended = waitFor<EngineEnded>(engine.events, (e) => e.tag == 2);
      final sw = Stopwatch()..start();
      await engine.load(Playable(a), tag: 1);
      await engine.setNext(Playable(b), tag: 2);
      await advanced;
      final atJoin = sw.elapsedMilliseconds;
      await ended;
      final atEnd = sw.elapsedMilliseconds;
      // A ran for ~1.5 s, B for another ~1.5 s, back to back.
      expect(atJoin, inInclusiveRange(1200, 2600));
      expect(atEnd - atJoin, inInclusiveRange(1200, 2200));
    },
  );

  test('replacing the preloaded next track takes effect', () async {
    final engine = MpvEngine(audioOutput: 'null');
    addTearDown(engine.dispose);
    final a = tone('E', 1.2, 300);
    final b = tone('F', 1, 500);
    final c = tone('G', 1, 700);
    final advanced = waitFor<EngineAdvanced>(engine.events, (_) => true);
    await engine.load(Playable(a), tag: 1);
    await engine.setNext(Playable(b), tag: 2);
    await engine.setNext(Playable(c), tag: 3);
    expect((await advanced).tag, 3);
  });

  test('crossfade: advances before the end of the outgoing track', () async {
    final engine = MpvEngine(audioOutput: 'null');
    addTearDown(engine.dispose);
    await engine.setCrossfade(const Duration(seconds: 1));
    final a = tone('H', 4, 300);
    final b = tone('I', 3, 500);
    final advanced = waitFor<EngineAdvanced>(engine.events, (e) => e.tag == 2);
    final ended = waitFor<EngineEnded>(engine.events, (e) => e.tag == 2);
    final sw = Stopwatch()..start();
    await engine.load(Playable(a), tag: 1);
    await engine.setNext(Playable(b), tag: 2);
    await advanced;
    final atFade = sw.elapsedMilliseconds;
    await ended;
    final atEnd = sw.elapsedMilliseconds;
    // The fade starts ~1 s before A ends (at ~3 s), and B then runs ~3 s.
    expect(atFade, inInclusiveRange(2400, 3700));
    expect(atEnd - atFade, inInclusiveRange(2500, 3800));
  });

  test('a missing file reports an error for its tag', () async {
    final engine = MpvEngine(audioOutput: 'null');
    addTearDown(engine.dispose);
    final err = waitFor<EngineError>(engine.events, (e) => e.tag == 7);
    await engine.load(Playable(p.join(dir.path, 'nope.flac')), tag: 7);
    expect((await err).message, isNotEmpty);
  });

  test('seek, pause and position', () async {
    final engine = MpvEngine(audioOutput: 'null');
    addTearDown(engine.dispose);
    final a = tone('J', 5, 300);
    final playing = waitFor<EnginePlaying>(engine.events, (e) => e.playing);
    await engine.load(Playable(a), tag: 1);
    await playing;
    await engine.seek(const Duration(seconds: 3));
    final pos = await engine.position
        .firstWhere((p) => p >= const Duration(milliseconds: 3100))
        .timeout(const Duration(seconds: 5));
    expect(pos.inMilliseconds, lessThan(4500));
    await engine.pause();
    final at = engine.currentPosition;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect((engine.currentPosition - at).inMilliseconds.abs(), lessThan(150));
  });
}
