import '../core/models/track.dart';
import 'music_source.dart';

/// All enabled sources, looked up by the prefix of a [Track.id].
class SourceRegistry {
  SourceRegistry(List<MusicSource> sources)
    : _byId = {for (final s in sources) s.id: s};

  final Map<String, MusicSource> _byId;

  Iterable<MusicSource> get all => _byId.values;

  MusicSource? operator [](String id) => _byId[id];

  Future<Playable> resolve(Track track) {
    final src = _byId[track.source];
    if (src == null) {
      throw UnplayableException(
        'The ${track.source} source is turned off, so this track can’t play.',
      );
    }
    return src.resolve(track);
  }

  Future<void> dispose() async {
    for (final s in _byId.values) {
      await s.dispose();
    }
  }
}
