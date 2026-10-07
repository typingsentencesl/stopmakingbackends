import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/engine.dart';
import '../data/db/database.dart';
import '../data/repos/history_repo.dart';
import '../data/repos/settings_repo.dart';
import '../data/repos/track_repo.dart';
import '../sources/local/local_source.dart';
import '../sources/source_registry.dart';

/// Long-lived objects created once at startup (or by a test) and handed to
/// the provider graph through [servicesProvider].
class Services {
  Services({
    required this.db,
    required this.engine,
    required this.local,
    required this.registry,
  }) : tracks = TrackRepo(db),
       history = HistoryRepo(db),
       settings = SettingsRepo(db);

  final AppDatabase db;
  final AudioEngine engine;
  final LocalSource local;
  final SourceRegistry registry;
  final TrackRepo tracks;
  final HistoryRepo history;
  final SettingsRepo settings;

  Future<void> dispose() async {
    await engine.dispose();
    await registry.dispose();
    await db.close();
  }
}

/// Supplied with `ProviderScope(overrides: [servicesProvider.overrideWithValue(...)])`
/// by `main()` and by tests; there is no default instance.
final servicesProvider = Provider<Services>(
  (ref) => throw StateError('servicesProvider is provided by main() or a test'),
);
