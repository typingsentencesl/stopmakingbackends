import 'package:aftrburnr/app/app.dart';
import 'package:aftrburnr/app/services.dart';
import 'package:aftrburnr/audio/player_controller.dart';
import 'package:aftrburnr/audio/queue.dart';
import 'package:aftrburnr/core/models/track.dart';
import 'package:aftrburnr/features/queue/queue_row.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/fonts.dart';

/// Real public-domain recordings' metadata, so the UI is exercised with
/// realistic title lengths (no invented artists).
final pdTracks = <Track>[
  for (final (i, t) in [
    ('Gymnopédie No. 1', 'Erik Satie', 'Trois Gymnopédies', 1888, 208),
    ('Gymnopédie No. 2', 'Erik Satie', 'Trois Gymnopédies', 1888, 156),
    ('Gymnopédie No. 3', 'Erik Satie', 'Trois Gymnopédies', 1888, 141),
    ('Clair de lune', 'Claude Debussy', 'Suite bergamasque', 1905, 302),
    ('Rêverie', 'Claude Debussy', 'Rêverie', 1890, 263),
    ('Arabesque No. 1', 'Claude Debussy', 'Deux Arabesques', 1891, 249),
    (
      'Prelude in C major, BWV 846',
      'Johann Sebastian Bach',
      'The Well-Tempered Clavier, Book I',
      1722,
      137,
    ),
    ('Gnossienne No. 1', 'Erik Satie', 'Trois Gnossiennes', 1893, 233),
  ].indexed)
    Track(
      id: trackIdOf('fake', 'pd$i'),
      source: 'fake',
      sourceId: 'pd$i',
      title: t.$1,
      artist: t.$2,
      album: t.$3,
      year: t.$4,
      duration: Duration(seconds: t.$5),
    ),
];

void main() {
  late FakeEngine engine;
  late Services services;
  late ProviderContainer container;

  /// Everything here (in-memory SQLite, fake engine) completes through
  /// microtasks and short timers, so pumping the fake clock is enough.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    engine = FakeEngine();
    services = fakeServices(engine: engine);
    container = ProviderContainer(
      overrides: [servicesProvider.overrideWithValue(services)],
    );
    addTearDown(() async {
      container.dispose();
      await services.db.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AftrburnrApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> run(WidgetTester tester, Future<void> Function() f) async {
    var finished = false;
    Object? error;
    f().then(
      (_) => finished = true,
      onError: (Object e) {
        error = e;
        finished = true;
      },
    );
    for (var i = 0; i < 200 && !finished; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    if (error != null) throw error!;
    expect(finished, isTrue, reason: 'operation did not complete');
    await settle(tester);
  }

  PlayerState st() => container.read(playerProvider);

  testWidgets('empty queue shows the empty state and disabled transport', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Nothing queued.'), findsOneWidget);
    expect(find.text('Open files'), findsWidgets);
    // Space with nothing loaded does nothing.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(engine.playing, isFalse);
  });

  testWidgets('queue lists now playing and up next; keyboard controls work', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(
      tester,
      () => container.read(playerProvider.notifier).playTracks(pdTracks),
    );
    expect(find.text('Queue'), findsWidgets);
    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Gymnopédie No. 1'), findsNWidgets(2)); // row + transport
    expect(find.text('7 tracks up next · 24 m'), findsOneWidget);

    // Space pauses, Ctrl+→ skips.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(engine.playing, isFalse);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await run(tester, () async {});
    expect(st().current!.title, 'Gymnopédie No. 2');
  });

  testWidgets('click selects, shift-click extends, Delete removes', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(
      tester,
      () => container.read(playerProvider.notifier).playTracks(pdTracks),
    );
    await tester.tap(find.text('Clair de lune'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Arabesque No. 1'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump(const Duration(milliseconds: 400));
    final selected = tester
        .widgetList<TrackRowView>(find.byType(TrackRowView))
        .where((r) => r.selected)
        .map((r) => r.track!.title)
        .toList();
    expect(selected, ['Clair de lune', 'Rêverie', 'Arabesque No. 1']);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await run(tester, () async {});
    expect(st().queue.entries.length, 5);
    expect(find.text('Clair de lune'), findsNothing);
  });

  testWidgets('Alt+↓ moves the selection; Ctrl+Enter makes it next up', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(
      tester,
      () => container.read(playerProvider.notifier).playTracks(pdTracks),
    );
    await tester.tap(find.text('Gnossienne No. 1'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await run(tester, () async {});
    expect(st().queue.entries[1].origin, QueueOrigin.next);
    expect(st().trackOf(st().queue.entries[1])!.title, 'Gnossienne No. 1');
    expect(find.text('NEXT UP'), findsOneWidget);

    await tester.tap(find.text('Gymnopédie No. 3'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await run(tester, () async {});
    final titles = [for (final e in st().queue.entries) st().trackOf(e)!.title];
    expect(
      titles.indexOf('Gymnopédie No. 3'),
      titles.indexOf('Clair de lune') + 1,
    );
  });

  testWidgets('shuffle and repeat buttons cycle modes', (tester) async {
    await pumpApp(tester);
    await run(
      tester,
      () => container.read(playerProvider.notifier).playTracks(pdTracks),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await run(tester, () async {});
    expect(st().queue.shuffle, ShuffleMode.random);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await run(tester, () async {});
    expect(st().queue.shuffle, ShuffleMode.leastRecent);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await run(tester, () async {});
    expect(st().queue.repeat, QueueRepeat.all);
  });

  testWidgets('a playback error shows as a status strip and can be dismissed', (
    tester,
  ) async {
    await pumpApp(tester);
    await run(
      tester,
      () => container.read(playerProvider.notifier).playTracks(pdTracks),
    );
    await run(tester, () async {
      final source = services.registry['fake']! as FakeSource;
      source.broken.add(pdTracks[1].id);
      await container.read(playerProvider.notifier).next();
    });
    expect(find.textContaining('Gymnopédie No. 2 is broken'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Dismiss'));
    await tester.pump();
    expect(find.textContaining('is broken'), findsNothing);
  });
}
