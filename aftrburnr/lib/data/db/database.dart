import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Every track that has ever entered the library, queue, a playlist or the
/// play history, from any source. Rows are never deleted when a local file
/// disappears: `available` goes false so history and stats stay intact.
@DataClassName('TrackRow')
class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant(''))();
  TextColumn get album => text().withDefault(const Constant(''))();
  TextColumn get albumArtist => text().withDefault(const Constant(''))();
  IntColumn get trackNo => integer().nullable()();
  IntColumn get discNo => integer().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genre => text().withDefault(const Constant(''))();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get uri => text().withDefault(const Constant(''))();
  TextColumn get artUri => text().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  BoolColumn get inLibrary => boolean().withDefault(const Constant(false))();
  BoolColumn get available => boolean().withDefault(const Constant(true))();
  IntColumn get fileMtimeMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per listen, written when a track stops being current.
@DataClassName('PlayEventRow')
class PlayEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackId => text().references(Tracks, #id)();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get msPlayed => integer()();

  /// Counted as a play: ≥ 30 s or ≥ 50 % of the track was heard.
  BoolColumn get counted => boolean()();

  /// The user moved on before it counted.
  BoolColumn get skipped => boolean()();
}

/// Per-track aggregates maintained alongside [PlayEvents].
@DataClassName('TrackStatRow')
class TrackStats extends Table {
  TextColumn get trackId => text().references(Tracks, #id)();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  IntColumn get skipCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {trackId};
}

/// Key/value JSON settings, including the persisted queue.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Tracks, PlayEvents, TrackStats, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The on-disk database in the platform's app support folder
  /// (`%APPDATA%\dev.aftrburnr\aftrburnr` on Windows).
  factory AppDatabase.open() => AppDatabase(
    driftDatabase(
      name: 'aftrburnr',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS play_events_track ON play_events (track_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS play_events_started ON play_events (started_at)',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
