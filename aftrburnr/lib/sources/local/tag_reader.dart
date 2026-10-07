import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import '../../core/models/track.dart';

/// Extensions the local source picks up. mpv plays all of these; tags are
/// read for every format `audio_metadata_reader` understands and fall back
/// to the file name otherwise.
const audioExtensions = {
  '.mp3',
  '.flac',
  '.m4a',
  '.mp4',
  '.aac',
  '.alac',
  '.ogg',
  '.oga',
  '.opus',
  '.wav',
  '.aif',
  '.aiff',
  '.ape',
  '.wv',
  '.wma',
  '.webm',
  '.mka',
};

bool isAudioFile(String path) =>
    audioExtensions.contains(p.extension(path).toLowerCase());

/// Stable id for a local file. On Windows paths are case-insensitive, so the
/// canonical form is lowercased there.
String localIdFor(String path) => p.canonicalize(path);

/// Result of reading one file, sent back from the tag-reading isolate.
class ReadResult {
  const ReadResult(this.track, this.mtimeMs);
  final Track track;
  final int mtimeMs;
}

/// 64-bit FNV-1a, used to name cached art files.
String fnv1a(String s) {
  var h = 0xcbf29ce484222325;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return h.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

/// Reads tags and embedded art for [paths]. Runs synchronously; call it from
/// an isolate. Embedded art is written once per album into [artDir].
List<ReadResult> readTracks(List<String> paths, String artDir, DateTime now) {
  final out = <ReadResult>[];
  for (final path in paths) {
    final file = File(path);
    final FileStat stat;
    try {
      stat = file.statSync();
      if (stat.type != FileSystemEntityType.file) continue;
    } on FileSystemException {
      continue;
    }
    AudioMetadata? meta;
    try {
      meta = readMetadata(file, getImage: true);
    } catch (_) {
      // Unknown container or broken tags: still playable, so keep the file
      // with what the path tells us.
      meta = null;
    }
    final title = _clean(meta?.title) ?? p.basenameWithoutExtension(path);
    final artist = _clean(meta?.artist) ?? '';
    final album = _clean(meta?.album) ?? '';
    final albumArtist = _clean(meta?.albumArtist) ?? '';
    String? artUri;
    final pics = meta?.pictures ?? const <Picture>[];
    if (pics.isNotEmpty) {
      final pic = pics.firstWhere(
        (x) => x.pictureType == PictureType.coverFront,
        orElse: () => pics.first,
      );
      final key = album.isNotEmpty
          ? '${albumArtist.isNotEmpty ? albumArtist : artist}\u0000$album'
          : path;
      final ext = pic.mimetype.contains('png') ? 'png' : 'jpg';
      final artPath = p.join(artDir, '${fnv1a(key)}.$ext');
      try {
        final f = File(artPath);
        if (!f.existsSync()) {
          f.parent.createSync(recursive: true);
          f.writeAsBytesSync(pic.bytes, flush: true);
        }
        artUri = artPath;
      } on FileSystemException {
        artUri = null;
      }
    }
    final id = localIdFor(path);
    out.add(
      ReadResult(
        Track(
          id: trackIdOf('local', id),
          source: 'local',
          sourceId: id,
          title: title,
          artist: artist,
          album: album,
          albumArtist: albumArtist,
          trackNo: meta?.trackNumber,
          discNo: meta?.discNumber,
          year: meta?.year?.year,
          genre: (meta?.genres ?? const <String>[])
              .map((g) => g.trim())
              .where((g) => g.isNotEmpty)
              .join(', '),
          duration: meta?.duration ?? Duration.zero,
          uri: path,
          artUri: artUri,
          addedAt: now,
        ),
        stat.modified.millisecondsSinceEpoch,
      ),
    );
  }
  return out;
}

String? _clean(String? s) {
  if (s == null) return null;
  final t = s.replaceAll('\u0000', '').trim();
  return t.isEmpty ? null : t;
}
