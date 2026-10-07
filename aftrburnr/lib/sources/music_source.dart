import 'package:flutter/foundation.dart';

import '../core/models/track.dart';

/// What the engine needs to play a track.
class Playable {
  const Playable(this.uri, {this.headers = const {}});

  /// A local path or an http(s) URL.
  final String uri;
  final Map<String, String> headers;
}

sealed class SourceHealth {
  const SourceHealth();
}

class SourceReady extends SourceHealth {
  const SourceReady();
}

class SourceOffline extends SourceHealth {
  const SourceOffline();
}

class SourceNeedsSetup extends SourceHealth {
  const SourceNeedsSetup(this.message);
  final String message;
}

class SourceError extends SourceHealth {
  const SourceError(this.message);
  final String message;
}

class SourceScanning extends SourceHealth {
  const SourceScanning(this.done, this.total);
  final int done;
  final int total;
}

/// Thrown by [MusicSource.resolve] when a track can't be played right now,
/// with a sentence the UI can show as-is.
class UnplayableException implements Exception {
  const UnplayableException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The one interface every music source implements. A source turns its own
/// catalogue into [Track]s and turns a [Track] back into something playable;
/// nothing else in the app knows where a track came from.
abstract interface class MusicSource {
  /// Stable id, used as the prefix of every [Track.id] it produces.
  String get id;

  /// Uppercase badge text: `LOCAL`, `AUDIUS`, `JAMENDO`.
  String get label;

  ValueListenable<SourceHealth> get health;

  /// Search this source's catalogue. Remote sources should throw on network
  /// failure; the caller shows that per source.
  Future<List<Track>> search(String query, {int limit = 20});

  /// Resolve a track to a playable URI. Throws [UnplayableException] with a
  /// readable reason when it can't be played (file missing, offline, …).
  Future<Playable> resolve(Track track);

  Future<void> dispose();
}
