/// A track from any source. Everything downstream of a source (library,
/// queue, playlists, stats) only ever sees this type, so a local file and a
/// streamed track behave identically.
class Track {
  const Track({
    required this.id,
    required this.source,
    required this.sourceId,
    required this.title,
    this.artist = '',
    this.album = '',
    this.albumArtist = '',
    this.trackNo,
    this.discNo,
    this.year,
    this.genre = '',
    this.duration = Duration.zero,
    this.uri = '',
    this.artUri,
    this.addedAt,
    this.inLibrary = false,
    this.available = true,
  });

  /// `<source>:<sourceId>`, see [trackIdOf].
  final String id;
  final String source;
  final String sourceId;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final int? trackNo;
  final int? discNo;
  final int? year;
  final String genre;
  final Duration duration;

  /// Local path for local files, a page/stream URL for remote sources. The
  /// playable URL is always obtained through `MusicSource.resolve`.
  final String uri;

  /// `file://` path of cached art, or an `http(s)` URL.
  final String? artUri;
  final DateTime? addedAt;
  final bool inLibrary;
  final bool available;

  String get displayArtist => artist.isEmpty ? 'Unknown artist' : artist;
  String get displayAlbum => album.isEmpty ? 'Unknown album' : album;

  Track copyWith({
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    int? trackNo,
    int? discNo,
    int? year,
    String? genre,
    Duration? duration,
    String? uri,
    String? artUri,
    DateTime? addedAt,
    bool? inLibrary,
    bool? available,
  }) {
    return Track(
      id: id,
      source: source,
      sourceId: sourceId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      trackNo: trackNo ?? this.trackNo,
      discNo: discNo ?? this.discNo,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      uri: uri ?? this.uri,
      artUri: artUri ?? this.artUri,
      addedAt: addedAt ?? this.addedAt,
      inLibrary: inLibrary ?? this.inLibrary,
      available: available ?? this.available,
    );
  }

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Track($id, $title)';
}

String trackIdOf(String source, String sourceId) => '$source:$sourceId';
