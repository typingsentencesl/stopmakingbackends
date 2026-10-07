import 'dart:io';

import 'package:flutter/services.dart';

bool _loaded = false;

/// flutter_test renders every font as boxes unless real fonts are loaded.
/// Loads the bundled faces and the Lucide icon font so widget tests and
/// screenshots look like the app.
Future<void> loadAppFonts() async {
  if (_loaded) return;
  _loaded = true;
  Future<void> load(String family, List<String> files) async {
    final l = FontLoader(family);
    for (final f in files) {
      l.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await l.load();
  }

  await load('Archivo XC', [
    'assets/fonts/ArchivoXC-700.ttf',
    'assets/fonts/ArchivoXC-800.ttf',
  ]);
  await load('IBM Plex Sans', [
    'assets/fonts/IBMPlexSans-400.ttf',
    'assets/fonts/IBMPlexSans-500.ttf',
    'assets/fonts/IBMPlexSans-600.ttf',
  ]);
  final lucide = await rootBundle.load(
    'packages/lucide_icons_flutter/assets/lucide.ttf',
  );
  final l = FontLoader('packages/lucide_icons_flutter/Lucide')
    ..addFont(Future.value(lucide));
  await l.load();
}
