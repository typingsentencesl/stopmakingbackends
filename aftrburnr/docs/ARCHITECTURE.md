# AFTRBURNR — Architecture

Status: **draft, awaiting approval**.

## 1. Stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter 3.47 (stable), Dart 3 | One codebase for iOS, Android, Windows, macOS, Linux. |
| State | `flutter_riverpod` 3 (hand-written `Notifier`/`StreamProvider`, no codegen) | Testable without widgets, scoped overrides for tests, no global singletons. |
| Persistence | `drift` (SQLite) + `sqlite3_flutter_libs`, generated code committed | Reactive queries (`watch()`) drive the UI directly; smart-playlist rules and stats compile to SQL; FTS5 for local search. Everything is on device. |
| Audio | `media_kit` (libmpv) on all five platforms | The only engine that gives the *same* feature set everywhere: gapless (`gapless-audio`, `prefetch-playlist`), ReplayGain (`replaygain=track/album`), and a real **parametric EQ** through ffmpeg's `lavfi` `equalizer` filters. `just_audio` only has an Android-only fixed-band EQ. |
| OS media controls | `audio_service` (Android/iOS/macOS), MPRIS on Linux, SMTC on Windows via media_kit's own integration | Lock screen, headset buttons, media keys. |
| Tags | `audio_metadata_reader` (pure Dart) | MP3/ID3, FLAC/Vorbis, MP4/M4A, OGG/Opus, WAV. Pure Dart means it behaves the same on every platform and runs in an isolate. |
| HTTP | `http` with a per-source client, timeouts and cancellation | Audius, Jamendo, LRCLIB. |
| Icons | `lucide_icons_flutter` only | See DESIGN.md §7. |
| Color from art | `material_color_utilities` (already a Flutter dependency) – Celebi quantizer + HCT | No extra package; tone/chroma clamping in HCT is exactly what DESIGN.md §4 asks for. |

## 2. Folders

All code lives in `aftrburnr/` in this repo.

```
aftrburnr/
  docs/                      DESIGN.md, ARCHITECTURE.md, step reports
  assets/fonts/              Archivo (variable), IBM Plex Sans 400/500/600 (OFL)
  lib/
    main.dart                bootstraps media_kit, opens DB, runs ProviderScope
    app/
      app.dart               WidgetsApp/MaterialApp with fully overridden theme
      shell_desktop.dart     sidebar | page | queue panel + transport bar
      shell_mobile.dart      tabs + mini transport + now-playing sheet
      routes.dart            tiny typed router (no package; ~6 destinations)
      shortcuts.dart         keyboard map → Intents → Actions
      palette/               command palette (fuzzy matcher, command registry)
    design/
      tokens.dart            colors, spacing, radius, durations — the ONLY place for literals
      type.dart              text styles from DESIGN.md §2
      theme.dart             ThemeData that overrides every Material component theme
      widgets/               AfButton, AfIconButton, AfInput, AfMenu, AfSlider, AfToggle,
                             AfTable (sortable/resizable), AfGrid, Art, PlayingBars,
                             StatusStrip, EmptyState, ErrorState, SourceBadge, Skeleton
    core/
      models/                Track, Album, Artist, Playlist, SmartRule, QueueEntry, Lyrics
      ids.dart               TrackId = "<sourceId>:<sourceTrackId>"
      format.dart            durations, counts, dates (tabular)
    data/
      db/                    drift tables, migrations, FTS5 setup (+ *.g.dart committed)
      repos/                 LibraryRepo, PlaylistRepo, HistoryRepo, SettingsRepo,
                             StatsRepo, SmartPlaylistCompiler
    sources/
      music_source.dart      the plugin interface (below)
      source_registry.dart   enabled sources, health/offline status
      local/                 folder scanner (isolate), tag reader, watcher, sidecar .lrc
      audius/                host discovery, search, stream URL, artwork
      jamendo/               client_id from settings, search, stream URL, artwork
    audio/
      engine.dart            two-deck media_kit engine (gapless / crossfade)
      dsp.dart               EQ bands + preamp + normalization → mpv `af` string
      queue.dart             pure-Dart queue model (no Flutter imports)
      shuffle.dart           Fisher–Yates over a CSPRNG; least-recently-played ordering
      player_controller.dart Riverpod Notifier joining engine + queue + history
      sleep_timer.dart
      media_session.dart
    features/
      home/ library/ playlists/ smart/ now_playing/ queue/ search/
      settings/ eq/ stats/ lyrics/
  test/                      unit tests per module + widget tests + design_guard_test
  linux/ macos/ windows/ android/ ios/   platform runners
```

Dependency direction: `features → app/design → audio/data/sources → core`. `core` and
`audio/queue.dart` import nothing from Flutter so they're tested as plain Dart.

## 3. Data model (SQLite via drift)

```
tracks(id PK "src:id", source, source_id, title, artist, album, album_artist, album_id,
       track_no, disc_no, year, genre, duration_ms, uri, art_uri, replaygain_track,
       replaygain_album, added_at, in_library BOOL, file_mtime, available BOOL)
tracks_fts(title, artist, album, genre)            FTS5 external-content over tracks
albums(id, title, artist, year, art_uri, art_color, source)
playlists(id, name, created_at, updated_at, kind 'manual'|'smart', rules_json, sort_json, limit)
playlist_items(playlist_id, position, track_id)
play_events(id, track_id, started_at, ms_played, completed BOOL, skipped BOOL, context)
track_stats(track_id PK, play_count, skip_count, last_played_at)   maintained from play_events
queue_state(single row: entries_json, current_index, position_ms, shuffle, repeat, original_order_json)
eq_presets(id, name, preamp_db, bands_json, builtin BOOL)
settings(key PK, value_json)
lyrics_cache(track_id PK, synced_lrc, plain, source, fetched_at)
local_folders(path PK, added_at, last_scan_at)
```

Any track — local, Audius, Jamendo — is a row in `tracks` the moment it enters the queue,
a playlist, history or the library. Playlists, queue, stats and smart rules only ever see
`TrackId`s, so a remote track behaves exactly like a local one.

## 4. Source plugin interface

```dart
abstract interface class MusicSource {
  String get id;                     // 'local' | 'audius' | 'jamendo'
  String get label;                  // 'LOCAL' | 'AUDIUS' | 'JAMENDO'
  SourceCapabilities get caps;       // search, browseAlbums, needsNetwork, providesLyrics
  ValueListenable<SourceHealth> get health;   // ready | offline | error(msg) | scanning(progress)

  Future<void> init(SourceContext ctx);        // settings, http client, db access
  Future<SearchPage> search(String query, {int limit = 20, CancelToken? cancel});
  Future<List<Track>> albumTracks(String sourceAlbumId);
  Future<Playable> resolve(Track track);       // uri + headers + replaygain; may refresh
                                               // expiring stream URLs (Audius)
  Future<Lyrics?> lyrics(Track track) async => null;   // embedded / sidecar / remote
  Future<void> dispose();
}

class Playable { final Uri uri; final Map<String,String> headers;
                 final double? gainTrackDb, gainAlbumDb; }
```

- `LocalSource` additionally implements `LibraryProvider` (add/remove folders, rescan,
  watch for changes). Scanning runs in an isolate, upserts in batches of 200, and marks
  missing files `available = false` rather than deleting their history.
- `AudiusSource` picks a host from `api.audius.co` discovery, sends `app_name=AFTRBURNR`,
  streams via `/v1/tracks/{id}/stream`.
- `JamendoSource` needs a free Jamendo `client_id`; the user enters it in Settings. Until
  then the source shows "needs a client ID" in its health and is skipped by search.
- Adding a source = one class + one line in `source_registry.dart`.

## 5. Audio engine

- **Two decks** (A/B), each a media_kit `Player` with the same `af` DSP chain.
- **Gapless mode** (crossfade = 0): the active deck holds the current and next track as an
  mpv playlist with `gapless-audio=weak`, `prefetch-playlist=yes`; mpv joins them with no gap.
- **Crossfade mode** (1–12 s): the inactive deck preloads the next track; at
  `duration − fade`, both decks ramp volume on an equal-power curve; decks swap.
- **Normalization**: off / track / album via mpv `replaygain` using tags; for tracks
  without tags (most remote streams) an optional `dynaudnorm` fallback.
- **Parametric EQ**: up to 10 bands, each `{type: peak|lowshelf|highshelf, f, gain, q}` →
  `lavfi=[equalizer=f=…:t=q:w=…:g=…]` / `bass=` / `treble=` + `volume=preamp`. Applied
  live without restarting playback. Presets in `eq_presets` (built-ins + user-saved).
- **Sleep timer**: duration or "end of current track", 8 s fade before pause.
- Play events are recorded by the controller: a play counts at ≥ 30 s or ≥ 50 %; a skip is
  a user advance before that.

## 6. Queue

Pure Dart, unit-tested in isolation.

- `entries: List<QueueEntry>` (each has a unique entry id, `TrackId`, and an `origin`:
  `context` or `user`), `current: int`, `history` (entries that were played, newest first).
- **Play next** inserts after the current entry *and after any earlier play-next entries*
  (so 3× play next keeps the order the user chose). **Play last** appends.
- Reorder by drag, multi-select remove/move/play-next/save-as-playlist.
- **Shuffle**: Fisher–Yates using `Random.secure()` over the not-yet-played entries; every
  permutation equally likely. No artist spreading, no "smart" weighting. Turning it off
  restores original order around the current track.
- **Least recently played first**: orders upcoming entries by `last_played_at` ascending
  (never-played first), ties broken randomly.
- Repeat: off / all / one. The queue persists after every change (debounced 300 ms) and is
  restored with position on launch.

## 7. State management

```
databaseProvider            → AppDatabase
sourceRegistryProvider      → SourceRegistry (all MusicSource instances + health)
libraryRepoProvider, playlistRepoProvider, historyRepoProvider, statsRepoProvider, …
playerControllerProvider    → Notifier<PlayerState>   (track, position stream, state, queue)
positionProvider            → StreamProvider<Duration> (separate so only the bar rebuilds)
libraryTracksProvider(sort, filter) → StreamProvider from drift watch()
searchProvider(query)       → per-source AsyncValue map, debounced 120 ms, cancels stale
settingsProvider            → Notifier backed by settings table
```

UI widgets read providers; they never touch the DB, sources, or media_kit directly.

## 8. Keyboard (desktop)

| Key | Action |
|---|---|
| Ctrl/Cmd+K | Command palette |
| Space | Play / pause (when focus isn't in a text field) |
| Ctrl/Cmd+→ / ← | Next / previous |
| Shift+→ / ← | Seek ±10 s |
| Ctrl/Cmd+↑ / ↓ | Volume ±5 % |
| ↑ / ↓, Shift+↑/↓ | Move / extend selection in lists |
| Enter | Play selection |
| Ctrl/Cmd+Enter / Ctrl/Cmd+Shift+Enter | Play next / play last |
| Delete | Remove selection (queue, playlist) |
| Alt+↑ / ↓ | Move selected queue rows |
| Ctrl/Cmd+F or / | Focus search |
| Ctrl/Cmd+1…5 | Home, Library, Playlists, Search, Stats |
| Q / L / S / R | Toggle queue panel, lyrics, shuffle, repeat |
| Ctrl/Cmd+A | Select all |
| Esc | Close palette/menu, clear selection, leave now-playing |

## 9. Testing per step

- Unit tests for queue, shuffle (distribution check), LRP ordering, DSP filter strings,
  smart-rule compiler, stats queries, LRC parser, source JSON parsing (recorded fixtures).
- Widget tests for each screen state (empty, loading, error, offline, populated) using
  real tokens and bundled fonts, plus golden screenshots committed to `docs/screens/`.
- `flutter analyze` clean, `flutter build linux` after every step.
- `design_guard_test` (DESIGN.md §12).

## 10. Known platform constraints (stated up front)

- **iOS** has no arbitrary file system access: local files come from the Files picker
  (security-scoped bookmarks) or the app's Documents folder (exposed in Files/Finder).
- **Android 13+** needs `READ_MEDIA_AUDIO`; folders are picked through the system picker.
- **Linux** builds need `libmpv` installed (`libmpv-dev` / `mpv-libs`).
- This build environment can reach pub.dev and the Flutter SDK but **not** Audius, Jamendo
  or LRCLIB, so those integrations will be tested against recorded API fixtures here; a
  live check needs a machine with normal internet.
