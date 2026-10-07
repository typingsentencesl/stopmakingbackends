import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/open_files.dart';
import 'app/services.dart';
import 'audio/mpv_engine.dart';
import 'audio/player_controller.dart';
import 'data/db/database.dart';
import 'sources/local/local_source.dart';
import 'sources/source_registry.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final support = await getApplicationSupportDirectory();
  final db = AppDatabase.open();
  final local = LocalSource(db: db, artDir: p.join(support.path, 'art'));
  final services = Services(
    db: db,
    engine: MpvEngine(),
    local: local,
    registry: SourceRegistry([local]),
  );

  final container = ProviderContainer(
    overrides: [servicesProvider.overrideWithValue(services)],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AftrburnrApp(),
    ),
  );

  // Files passed on the command line (Explorer's "Open with") play at once.
  final files = args.where((a) => !a.startsWith('-')).toList();
  if (files.isNotEmpty) {
    await openPaths(
      services,
      container.read(playerProvider.notifier),
      files,
      playNow: true,
    );
  }
}
