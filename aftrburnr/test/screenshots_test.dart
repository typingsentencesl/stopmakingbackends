// Renders the real app at 1280×800 with the bundled fonts and writes PNGs
// to docs/screens/ for the step reports:
//
//   AFTRBURNR_SCREENSHOTS=1 flutter test test/screenshots_test.dart --update-goldens
//
// Skipped otherwise: font rasterisation differs per OS, so these are
// documentation, not pixel tests.
import 'dart:io';

import 'package:aftrburnr/app/app.dart';
import 'package:aftrburnr/app/services.dart';
import 'package:aftrburnr/audio/player_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_widget_test.dart' show pdTracks;
import 'support/fakes.dart';
import 'support/fonts.dart';

final enabled = Platform.environment['AFTRBURNR_SCREENSHOTS'] == '1';

void main() {
  late FakeEngine engine;
  late Services services;
  late ProviderContainer container;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
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

  Future<void> play(WidgetTester tester) async {
    container.read(playerProvider.notifier).playTracks(pdTracks, startIndex: 2);
    await settle(tester);
    engine.tick(const Duration(seconds: 47));
    await settle(tester);
  }

  final shot = find.byType(AftrburnrApp);

  testWidgets('empty', (tester) async {
    await pumpApp(tester);
    await expectLater(shot, matchesGoldenFile('../docs/screens/02-empty.png'));
  }, skip: !enabled);

  testWidgets('queue', (tester) async {
    await pumpApp(tester);
    await play(tester);
    // Play two, then select a range so selection and played states show.
    await tester.tap(find.text('Rêverie').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Arabesque No. 1'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await settle(tester);
    await tester.tap(find.text('PLAYED'));
    await settle(tester);
    await expectLater(shot, matchesGoldenFile('../docs/screens/02-queue.png'));
  }, skip: !enabled);

  testWidgets('context menu', (tester) async {
    await pumpApp(tester);
    await play(tester);
    final at = tester.getCenter(find.text('Clair de lune'));
    final g = await tester.startGesture(
      at,
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    await g.up();
    await settle(tester);
    await expectLater(shot, matchesGoldenFile('../docs/screens/02-menu.png'));
  }, skip: !enabled);

  testWidgets('error', (tester) async {
    await pumpApp(tester);
    await play(tester);
    (services.registry['fake']! as FakeSource).broken.add(pdTracks[3].id);
    container.read(playerProvider.notifier).next();
    await settle(tester);
    await expectLater(shot, matchesGoldenFile('../docs/screens/02-error.png'));
  }, skip: !enabled);
}
