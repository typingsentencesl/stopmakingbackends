// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TracksTable extends Tracks with TableInfo<$TracksTable, TrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trackNoMeta = const VerificationMeta(
    'trackNo',
  );
  @override
  late final GeneratedColumn<int> trackNo = GeneratedColumn<int>(
    'track_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discNoMeta = const VerificationMeta('discNo');
  @override
  late final GeneratedColumn<int> discNo = GeneratedColumn<int>(
    'disc_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _uriMeta = const VerificationMeta('uri');
  @override
  late final GeneratedColumn<String> uri = GeneratedColumn<String>(
    'uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artUriMeta = const VerificationMeta('artUri');
  @override
  late final GeneratedColumn<String> artUri = GeneratedColumn<String>(
    'art_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inLibraryMeta = const VerificationMeta(
    'inLibrary',
  );
  @override
  late final GeneratedColumn<bool> inLibrary = GeneratedColumn<bool>(
    'in_library',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_library" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _availableMeta = const VerificationMeta(
    'available',
  );
  @override
  late final GeneratedColumn<bool> available = GeneratedColumn<bool>(
    'available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fileMtimeMsMeta = const VerificationMeta(
    'fileMtimeMs',
  );
  @override
  late final GeneratedColumn<int> fileMtimeMs = GeneratedColumn<int>(
    'file_mtime_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    sourceId,
    title,
    artist,
    album,
    albumArtist,
    trackNo,
    discNo,
    year,
    genre,
    durationMs,
    uri,
    artUri,
    addedAt,
    inLibrary,
    available,
    fileMtimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
      );
    }
    if (data.containsKey('track_no')) {
      context.handle(
        _trackNoMeta,
        trackNo.isAcceptableOrUnknown(data['track_no']!, _trackNoMeta),
      );
    }
    if (data.containsKey('disc_no')) {
      context.handle(
        _discNoMeta,
        discNo.isAcceptableOrUnknown(data['disc_no']!, _discNoMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('uri')) {
      context.handle(
        _uriMeta,
        uri.isAcceptableOrUnknown(data['uri']!, _uriMeta),
      );
    }
    if (data.containsKey('art_uri')) {
      context.handle(
        _artUriMeta,
        artUri.isAcceptableOrUnknown(data['art_uri']!, _artUriMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('in_library')) {
      context.handle(
        _inLibraryMeta,
        inLibrary.isAcceptableOrUnknown(data['in_library']!, _inLibraryMeta),
      );
    }
    if (data.containsKey('available')) {
      context.handle(
        _availableMeta,
        available.isAcceptableOrUnknown(data['available']!, _availableMeta),
      );
    }
    if (data.containsKey('file_mtime_ms')) {
      context.handle(
        _fileMtimeMsMeta,
        fileMtimeMs.isAcceptableOrUnknown(
          data['file_mtime_ms']!,
          _fileMtimeMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      )!,
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      )!,
      trackNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_no'],
      ),
      discNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}disc_no'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      uri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uri'],
      )!,
      artUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art_uri'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      ),
      inLibrary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_library'],
      )!,
      available: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}available'],
      )!,
      fileMtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_mtime_ms'],
      ),
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class TrackRow extends DataClass implements Insertable<TrackRow> {
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
  final int durationMs;
  final String uri;
  final String? artUri;
  final DateTime? addedAt;
  final bool inLibrary;
  final bool available;
  final int? fileMtimeMs;
  const TrackRow({
    required this.id,
    required this.source,
    required this.sourceId,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    this.trackNo,
    this.discNo,
    this.year,
    required this.genre,
    required this.durationMs,
    required this.uri,
    this.artUri,
    this.addedAt,
    required this.inLibrary,
    required this.available,
    this.fileMtimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['album_artist'] = Variable<String>(albumArtist);
    if (!nullToAbsent || trackNo != null) {
      map['track_no'] = Variable<int>(trackNo);
    }
    if (!nullToAbsent || discNo != null) {
      map['disc_no'] = Variable<int>(discNo);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['genre'] = Variable<String>(genre);
    map['duration_ms'] = Variable<int>(durationMs);
    map['uri'] = Variable<String>(uri);
    if (!nullToAbsent || artUri != null) {
      map['art_uri'] = Variable<String>(artUri);
    }
    if (!nullToAbsent || addedAt != null) {
      map['added_at'] = Variable<DateTime>(addedAt);
    }
    map['in_library'] = Variable<bool>(inLibrary);
    map['available'] = Variable<bool>(available);
    if (!nullToAbsent || fileMtimeMs != null) {
      map['file_mtime_ms'] = Variable<int>(fileMtimeMs);
    }
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      source: Value(source),
      sourceId: Value(sourceId),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      albumArtist: Value(albumArtist),
      trackNo: trackNo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNo),
      discNo: discNo == null && nullToAbsent
          ? const Value.absent()
          : Value(discNo),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genre: Value(genre),
      durationMs: Value(durationMs),
      uri: Value(uri),
      artUri: artUri == null && nullToAbsent
          ? const Value.absent()
          : Value(artUri),
      addedAt: addedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(addedAt),
      inLibrary: Value(inLibrary),
      available: Value(available),
      fileMtimeMs: fileMtimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(fileMtimeMs),
    );
  }

  factory TrackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackRow(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String>(json['albumArtist']),
      trackNo: serializer.fromJson<int?>(json['trackNo']),
      discNo: serializer.fromJson<int?>(json['discNo']),
      year: serializer.fromJson<int?>(json['year']),
      genre: serializer.fromJson<String>(json['genre']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      uri: serializer.fromJson<String>(json['uri']),
      artUri: serializer.fromJson<String?>(json['artUri']),
      addedAt: serializer.fromJson<DateTime?>(json['addedAt']),
      inLibrary: serializer.fromJson<bool>(json['inLibrary']),
      available: serializer.fromJson<bool>(json['available']),
      fileMtimeMs: serializer.fromJson<int?>(json['fileMtimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String>(albumArtist),
      'trackNo': serializer.toJson<int?>(trackNo),
      'discNo': serializer.toJson<int?>(discNo),
      'year': serializer.toJson<int?>(year),
      'genre': serializer.toJson<String>(genre),
      'durationMs': serializer.toJson<int>(durationMs),
      'uri': serializer.toJson<String>(uri),
      'artUri': serializer.toJson<String?>(artUri),
      'addedAt': serializer.toJson<DateTime?>(addedAt),
      'inLibrary': serializer.toJson<bool>(inLibrary),
      'available': serializer.toJson<bool>(available),
      'fileMtimeMs': serializer.toJson<int?>(fileMtimeMs),
    };
  }

  TrackRow copyWith({
    String? id,
    String? source,
    String? sourceId,
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    Value<int?> trackNo = const Value.absent(),
    Value<int?> discNo = const Value.absent(),
    Value<int?> year = const Value.absent(),
    String? genre,
    int? durationMs,
    String? uri,
    Value<String?> artUri = const Value.absent(),
    Value<DateTime?> addedAt = const Value.absent(),
    bool? inLibrary,
    bool? available,
    Value<int?> fileMtimeMs = const Value.absent(),
  }) => TrackRow(
    id: id ?? this.id,
    source: source ?? this.source,
    sourceId: sourceId ?? this.sourceId,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    albumArtist: albumArtist ?? this.albumArtist,
    trackNo: trackNo.present ? trackNo.value : this.trackNo,
    discNo: discNo.present ? discNo.value : this.discNo,
    year: year.present ? year.value : this.year,
    genre: genre ?? this.genre,
    durationMs: durationMs ?? this.durationMs,
    uri: uri ?? this.uri,
    artUri: artUri.present ? artUri.value : this.artUri,
    addedAt: addedAt.present ? addedAt.value : this.addedAt,
    inLibrary: inLibrary ?? this.inLibrary,
    available: available ?? this.available,
    fileMtimeMs: fileMtimeMs.present ? fileMtimeMs.value : this.fileMtimeMs,
  );
  TrackRow copyWithCompanion(TracksCompanion data) {
    return TrackRow(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      trackNo: data.trackNo.present ? data.trackNo.value : this.trackNo,
      discNo: data.discNo.present ? data.discNo.value : this.discNo,
      year: data.year.present ? data.year.value : this.year,
      genre: data.genre.present ? data.genre.value : this.genre,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      uri: data.uri.present ? data.uri.value : this.uri,
      artUri: data.artUri.present ? data.artUri.value : this.artUri,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      inLibrary: data.inLibrary.present ? data.inLibrary.value : this.inLibrary,
      available: data.available.present ? data.available.value : this.available,
      fileMtimeMs: data.fileMtimeMs.present
          ? data.fileMtimeMs.value
          : this.fileMtimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackRow(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('trackNo: $trackNo, ')
          ..write('discNo: $discNo, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('durationMs: $durationMs, ')
          ..write('uri: $uri, ')
          ..write('artUri: $artUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('inLibrary: $inLibrary, ')
          ..write('available: $available, ')
          ..write('fileMtimeMs: $fileMtimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    sourceId,
    title,
    artist,
    album,
    albumArtist,
    trackNo,
    discNo,
    year,
    genre,
    durationMs,
    uri,
    artUri,
    addedAt,
    inLibrary,
    available,
    fileMtimeMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackRow &&
          other.id == this.id &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.trackNo == this.trackNo &&
          other.discNo == this.discNo &&
          other.year == this.year &&
          other.genre == this.genre &&
          other.durationMs == this.durationMs &&
          other.uri == this.uri &&
          other.artUri == this.artUri &&
          other.addedAt == this.addedAt &&
          other.inLibrary == this.inLibrary &&
          other.available == this.available &&
          other.fileMtimeMs == this.fileMtimeMs);
}

class TracksCompanion extends UpdateCompanion<TrackRow> {
  final Value<String> id;
  final Value<String> source;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String> albumArtist;
  final Value<int?> trackNo;
  final Value<int?> discNo;
  final Value<int?> year;
  final Value<String> genre;
  final Value<int> durationMs;
  final Value<String> uri;
  final Value<String?> artUri;
  final Value<DateTime?> addedAt;
  final Value<bool> inLibrary;
  final Value<bool> available;
  final Value<int?> fileMtimeMs;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.discNo = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.uri = const Value.absent(),
    this.artUri = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.inLibrary = const Value.absent(),
    this.available = const Value.absent(),
    this.fileMtimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    required String source,
    required String sourceId,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.discNo = const Value.absent(),
    this.year = const Value.absent(),
    this.genre = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.uri = const Value.absent(),
    this.artUri = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.inLibrary = const Value.absent(),
    this.available = const Value.absent(),
    this.fileMtimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       sourceId = Value(sourceId),
       title = Value(title);
  static Insertable<TrackRow> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<int>? trackNo,
    Expression<int>? discNo,
    Expression<int>? year,
    Expression<String>? genre,
    Expression<int>? durationMs,
    Expression<String>? uri,
    Expression<String>? artUri,
    Expression<DateTime>? addedAt,
    Expression<bool>? inLibrary,
    Expression<bool>? available,
    Expression<int>? fileMtimeMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (trackNo != null) 'track_no': trackNo,
      if (discNo != null) 'disc_no': discNo,
      if (year != null) 'year': year,
      if (genre != null) 'genre': genre,
      if (durationMs != null) 'duration_ms': durationMs,
      if (uri != null) 'uri': uri,
      if (artUri != null) 'art_uri': artUri,
      if (addedAt != null) 'added_at': addedAt,
      if (inLibrary != null) 'in_library': inLibrary,
      if (available != null) 'available': available,
      if (fileMtimeMs != null) 'file_mtime_ms': fileMtimeMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<String>? sourceId,
    Value<String>? title,
    Value<String>? artist,
    Value<String>? album,
    Value<String>? albumArtist,
    Value<int?>? trackNo,
    Value<int?>? discNo,
    Value<int?>? year,
    Value<String>? genre,
    Value<int>? durationMs,
    Value<String>? uri,
    Value<String?>? artUri,
    Value<DateTime?>? addedAt,
    Value<bool>? inLibrary,
    Value<bool>? available,
    Value<int?>? fileMtimeMs,
    Value<int>? rowid,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      trackNo: trackNo ?? this.trackNo,
      discNo: discNo ?? this.discNo,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      durationMs: durationMs ?? this.durationMs,
      uri: uri ?? this.uri,
      artUri: artUri ?? this.artUri,
      addedAt: addedAt ?? this.addedAt,
      inLibrary: inLibrary ?? this.inLibrary,
      available: available ?? this.available,
      fileMtimeMs: fileMtimeMs ?? this.fileMtimeMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (trackNo.present) {
      map['track_no'] = Variable<int>(trackNo.value);
    }
    if (discNo.present) {
      map['disc_no'] = Variable<int>(discNo.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (uri.present) {
      map['uri'] = Variable<String>(uri.value);
    }
    if (artUri.present) {
      map['art_uri'] = Variable<String>(artUri.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (inLibrary.present) {
      map['in_library'] = Variable<bool>(inLibrary.value);
    }
    if (available.present) {
      map['available'] = Variable<bool>(available.value);
    }
    if (fileMtimeMs.present) {
      map['file_mtime_ms'] = Variable<int>(fileMtimeMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('trackNo: $trackNo, ')
          ..write('discNo: $discNo, ')
          ..write('year: $year, ')
          ..write('genre: $genre, ')
          ..write('durationMs: $durationMs, ')
          ..write('uri: $uri, ')
          ..write('artUri: $artUri, ')
          ..write('addedAt: $addedAt, ')
          ..write('inLibrary: $inLibrary, ')
          ..write('available: $available, ')
          ..write('fileMtimeMs: $fileMtimeMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayEventsTable extends PlayEvents
    with TableInfo<$PlayEventsTable, PlayEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _msPlayedMeta = const VerificationMeta(
    'msPlayed',
  );
  @override
  late final GeneratedColumn<int> msPlayed = GeneratedColumn<int>(
    'ms_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedMeta = const VerificationMeta(
    'counted',
  );
  @override
  late final GeneratedColumn<bool> counted = GeneratedColumn<bool>(
    'counted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("counted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<bool> skipped = GeneratedColumn<bool>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("skipped" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trackId,
    startedAt,
    msPlayed,
    counted,
    skipped,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ms_played')) {
      context.handle(
        _msPlayedMeta,
        msPlayed.isAcceptableOrUnknown(data['ms_played']!, _msPlayedMeta),
      );
    } else if (isInserting) {
      context.missing(_msPlayedMeta);
    }
    if (data.containsKey('counted')) {
      context.handle(
        _countedMeta,
        counted.isAcceptableOrUnknown(data['counted']!, _countedMeta),
      );
    } else if (isInserting) {
      context.missing(_countedMeta);
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    } else if (isInserting) {
      context.missing(_skippedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      msPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ms_played'],
      )!,
      counted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}counted'],
      )!,
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}skipped'],
      )!,
    );
  }

  @override
  $PlayEventsTable createAlias(String alias) {
    return $PlayEventsTable(attachedDatabase, alias);
  }
}

class PlayEventRow extends DataClass implements Insertable<PlayEventRow> {
  final int id;
  final String trackId;
  final DateTime startedAt;
  final int msPlayed;

  /// Counted as a play: ≥ 30 s or ≥ 50 % of the track was heard.
  final bool counted;

  /// The user moved on before it counted.
  final bool skipped;
  const PlayEventRow({
    required this.id,
    required this.trackId,
    required this.startedAt,
    required this.msPlayed,
    required this.counted,
    required this.skipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['track_id'] = Variable<String>(trackId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ms_played'] = Variable<int>(msPlayed);
    map['counted'] = Variable<bool>(counted);
    map['skipped'] = Variable<bool>(skipped);
    return map;
  }

  PlayEventsCompanion toCompanion(bool nullToAbsent) {
    return PlayEventsCompanion(
      id: Value(id),
      trackId: Value(trackId),
      startedAt: Value(startedAt),
      msPlayed: Value(msPlayed),
      counted: Value(counted),
      skipped: Value(skipped),
    );
  }

  factory PlayEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayEventRow(
      id: serializer.fromJson<int>(json['id']),
      trackId: serializer.fromJson<String>(json['trackId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      msPlayed: serializer.fromJson<int>(json['msPlayed']),
      counted: serializer.fromJson<bool>(json['counted']),
      skipped: serializer.fromJson<bool>(json['skipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trackId': serializer.toJson<String>(trackId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'msPlayed': serializer.toJson<int>(msPlayed),
      'counted': serializer.toJson<bool>(counted),
      'skipped': serializer.toJson<bool>(skipped),
    };
  }

  PlayEventRow copyWith({
    int? id,
    String? trackId,
    DateTime? startedAt,
    int? msPlayed,
    bool? counted,
    bool? skipped,
  }) => PlayEventRow(
    id: id ?? this.id,
    trackId: trackId ?? this.trackId,
    startedAt: startedAt ?? this.startedAt,
    msPlayed: msPlayed ?? this.msPlayed,
    counted: counted ?? this.counted,
    skipped: skipped ?? this.skipped,
  );
  PlayEventRow copyWithCompanion(PlayEventsCompanion data) {
    return PlayEventRow(
      id: data.id.present ? data.id.value : this.id,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      msPlayed: data.msPlayed.present ? data.msPlayed.value : this.msPlayed,
      counted: data.counted.present ? data.counted.value : this.counted,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayEventRow(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('startedAt: $startedAt, ')
          ..write('msPlayed: $msPlayed, ')
          ..write('counted: $counted, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, trackId, startedAt, msPlayed, counted, skipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayEventRow &&
          other.id == this.id &&
          other.trackId == this.trackId &&
          other.startedAt == this.startedAt &&
          other.msPlayed == this.msPlayed &&
          other.counted == this.counted &&
          other.skipped == this.skipped);
}

class PlayEventsCompanion extends UpdateCompanion<PlayEventRow> {
  final Value<int> id;
  final Value<String> trackId;
  final Value<DateTime> startedAt;
  final Value<int> msPlayed;
  final Value<bool> counted;
  final Value<bool> skipped;
  const PlayEventsCompanion({
    this.id = const Value.absent(),
    this.trackId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.msPlayed = const Value.absent(),
    this.counted = const Value.absent(),
    this.skipped = const Value.absent(),
  });
  PlayEventsCompanion.insert({
    this.id = const Value.absent(),
    required String trackId,
    required DateTime startedAt,
    required int msPlayed,
    required bool counted,
    required bool skipped,
  }) : trackId = Value(trackId),
       startedAt = Value(startedAt),
       msPlayed = Value(msPlayed),
       counted = Value(counted),
       skipped = Value(skipped);
  static Insertable<PlayEventRow> custom({
    Expression<int>? id,
    Expression<String>? trackId,
    Expression<DateTime>? startedAt,
    Expression<int>? msPlayed,
    Expression<bool>? counted,
    Expression<bool>? skipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackId != null) 'track_id': trackId,
      if (startedAt != null) 'started_at': startedAt,
      if (msPlayed != null) 'ms_played': msPlayed,
      if (counted != null) 'counted': counted,
      if (skipped != null) 'skipped': skipped,
    });
  }

  PlayEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? trackId,
    Value<DateTime>? startedAt,
    Value<int>? msPlayed,
    Value<bool>? counted,
    Value<bool>? skipped,
  }) {
    return PlayEventsCompanion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      startedAt: startedAt ?? this.startedAt,
      msPlayed: msPlayed ?? this.msPlayed,
      counted: counted ?? this.counted,
      skipped: skipped ?? this.skipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (msPlayed.present) {
      map['ms_played'] = Variable<int>(msPlayed.value);
    }
    if (counted.present) {
      map['counted'] = Variable<bool>(counted.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<bool>(skipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayEventsCompanion(')
          ..write('id: $id, ')
          ..write('trackId: $trackId, ')
          ..write('startedAt: $startedAt, ')
          ..write('msPlayed: $msPlayed, ')
          ..write('counted: $counted, ')
          ..write('skipped: $skipped')
          ..write(')'))
        .toString();
  }
}

class $TrackStatsTable extends TrackStats
    with TableInfo<$TrackStatsTable, TrackStatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id)',
    ),
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skipCountMeta = const VerificationMeta(
    'skipCount',
  );
  @override
  late final GeneratedColumn<int> skipCount = GeneratedColumn<int>(
    'skip_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    playCount,
    skipCount,
    lastPlayedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackStatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('skip_count')) {
      context.handle(
        _skipCountMeta,
        skipCount.isAcceptableOrUnknown(data['skip_count']!, _skipCountMeta),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  TrackStatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackStatRow(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      skipCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skip_count'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      ),
    );
  }

  @override
  $TrackStatsTable createAlias(String alias) {
    return $TrackStatsTable(attachedDatabase, alias);
  }
}

class TrackStatRow extends DataClass implements Insertable<TrackStatRow> {
  final String trackId;
  final int playCount;
  final int skipCount;
  final DateTime? lastPlayedAt;
  const TrackStatRow({
    required this.trackId,
    required this.playCount,
    required this.skipCount,
    this.lastPlayedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['play_count'] = Variable<int>(playCount);
    map['skip_count'] = Variable<int>(skipCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    return map;
  }

  TrackStatsCompanion toCompanion(bool nullToAbsent) {
    return TrackStatsCompanion(
      trackId: Value(trackId),
      playCount: Value(playCount),
      skipCount: Value(skipCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
    );
  }

  factory TrackStatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackStatRow(
      trackId: serializer.fromJson<String>(json['trackId']),
      playCount: serializer.fromJson<int>(json['playCount']),
      skipCount: serializer.fromJson<int>(json['skipCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'playCount': serializer.toJson<int>(playCount),
      'skipCount': serializer.toJson<int>(skipCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
    };
  }

  TrackStatRow copyWith({
    String? trackId,
    int? playCount,
    int? skipCount,
    Value<DateTime?> lastPlayedAt = const Value.absent(),
  }) => TrackStatRow(
    trackId: trackId ?? this.trackId,
    playCount: playCount ?? this.playCount,
    skipCount: skipCount ?? this.skipCount,
    lastPlayedAt: lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
  );
  TrackStatRow copyWithCompanion(TrackStatsCompanion data) {
    return TrackStatRow(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      skipCount: data.skipCount.present ? data.skipCount.value : this.skipCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackStatRow(')
          ..write('trackId: $trackId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, playCount, skipCount, lastPlayedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackStatRow &&
          other.trackId == this.trackId &&
          other.playCount == this.playCount &&
          other.skipCount == this.skipCount &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class TrackStatsCompanion extends UpdateCompanion<TrackStatRow> {
  final Value<String> trackId;
  final Value<int> playCount;
  final Value<int> skipCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<int> rowid;
  const TrackStatsCompanion({
    this.trackId = const Value.absent(),
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackStatsCompanion.insert({
    required String trackId,
    this.playCount = const Value.absent(),
    this.skipCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId);
  static Insertable<TrackStatRow> custom({
    Expression<String>? trackId,
    Expression<int>? playCount,
    Expression<int>? skipCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (playCount != null) 'play_count': playCount,
      if (skipCount != null) 'skip_count': skipCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackStatsCompanion copyWith({
    Value<String>? trackId,
    Value<int>? playCount,
    Value<int>? skipCount,
    Value<DateTime?>? lastPlayedAt,
    Value<int>? rowid,
  }) {
    return TrackStatsCompanion(
      trackId: trackId ?? this.trackId,
      playCount: playCount ?? this.playCount,
      skipCount: skipCount ?? this.skipCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (skipCount.present) {
      map['skip_count'] = Variable<int>(skipCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackStatsCompanion(')
          ..write('trackId: $trackId, ')
          ..write('playCount: $playCount, ')
          ..write('skipCount: $skipCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $PlayEventsTable playEvents = $PlayEventsTable(this);
  late final $TrackStatsTable trackStats = $TrackStatsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tracks,
    playEvents,
    trackStats,
    settings,
  ];
}

typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  required String id,
  required String source,
  required String sourceId,
  required String title,
  Value<String> artist,
  Value<String> album,
  Value<String> albumArtist,
  Value<int?> trackNo,
  Value<int?> discNo,
  Value<int?> year,
  Value<String> genre,
  Value<int> durationMs,
  Value<String> uri,
  Value<String?> artUri,
  Value<DateTime?> addedAt,
  Value<bool> inLibrary,
  Value<bool> available,
  Value<int?> fileMtimeMs,
  Value<int> rowid,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<String> id,
  Value<String> source,
  Value<String> sourceId,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String> albumArtist,
  Value<int?> trackNo,
  Value<int?> discNo,
  Value<int?> year,
  Value<String> genre,
  Value<int> durationMs,
  Value<String> uri,
  Value<String?> artUri,
  Value<DateTime?> addedAt,
  Value<bool> inLibrary,
  Value<bool> available,
  Value<int?> fileMtimeMs,
  Value<int> rowid,
});

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, TrackRow> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayEventsTable, List<PlayEventRow>>
  _playEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playEvents,
    aliasName: 'tracks__id__play_events__track_id',
  );

  $$PlayEventsTableProcessedTableManager get playEventsRefs {
    final manager = $$PlayEventsTableTableManager(
      $_db,
      $_db.playEvents,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackStatsTable, List<TrackStatRow>>
  _trackStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackStats,
    aliasName: 'tracks__id__track_stats__track_id',
  );

  $$TrackStatsTableProcessedTableManager get trackStatsRefs {
    final manager = $$TrackStatsTableTableManager(
      $_db,
      $_db.trackStats,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artUri => $composableBuilder(
    column: $table.artUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inLibrary => $composableBuilder(
    column: $table.inLibrary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileMtimeMs => $composableBuilder(
    column: $table.fileMtimeMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playEventsRefs(
    Expression<bool> Function($$PlayEventsTableFilterComposer f) f,
  ) {
    final $$PlayEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playEvents,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayEventsTableFilterComposer(
            $db: $db,
            $table: $db.playEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackStatsRefs(
    Expression<bool> Function($$TrackStatsTableFilterComposer f) f,
  ) {
    final $$TrackStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackStats,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackStatsTableFilterComposer(
            $db: $db,
            $table: $db.trackStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discNo => $composableBuilder(
    column: $table.discNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uri => $composableBuilder(
    column: $table.uri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artUri => $composableBuilder(
    column: $table.artUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inLibrary => $composableBuilder(
    column: $table.inLibrary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileMtimeMs => $composableBuilder(
    column: $table.fileMtimeMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackNo =>
      $composableBuilder(column: $table.trackNo, builder: (column) => column);

  GeneratedColumn<int> get discNo =>
      $composableBuilder(column: $table.discNo, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uri =>
      $composableBuilder(column: $table.uri, builder: (column) => column);

  GeneratedColumn<String> get artUri =>
      $composableBuilder(column: $table.artUri, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<bool> get inLibrary =>
      $composableBuilder(column: $table.inLibrary, builder: (column) => column);

  GeneratedColumn<bool> get available =>
      $composableBuilder(column: $table.available, builder: (column) => column);

  GeneratedColumn<int> get fileMtimeMs => $composableBuilder(
    column: $table.fileMtimeMs,
    builder: (column) => column,
  );

  Expression<T> playEventsRefs<T extends Object>(
    Expression<T> Function($$PlayEventsTableAnnotationComposer a) f,
  ) {
    final $$PlayEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playEvents,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.playEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackStatsRefs<T extends Object>(
    Expression<T> Function($$TrackStatsTableAnnotationComposer a) f,
  ) {
    final $$TrackStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackStats,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          TrackRow,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (TrackRow, $$TracksTableReferences),
          TrackRow,
          PrefetchHooks Function({bool playEventsRefs, bool trackStatsRefs})
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String?> artUri = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<bool> inLibrary = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<int?> fileMtimeMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                source: source,
                sourceId: sourceId,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                trackNo: trackNo,
                discNo: discNo,
                year: year,
                genre: genre,
                durationMs: durationMs,
                uri: uri,
                artUri: artUri,
                addedAt: addedAt,
                inLibrary: inLibrary,
                available: available,
                fileMtimeMs: fileMtimeMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String source,
                required String sourceId,
                required String title,
                Value<String> artist = const Value.absent(),
                Value<String> album = const Value.absent(),
                Value<String> albumArtist = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                Value<int?> discNo = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> uri = const Value.absent(),
                Value<String?> artUri = const Value.absent(),
                Value<DateTime?> addedAt = const Value.absent(),
                Value<bool> inLibrary = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<int?> fileMtimeMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                source: source,
                sourceId: sourceId,
                title: title,
                artist: artist,
                album: album,
                albumArtist: albumArtist,
                trackNo: trackNo,
                discNo: discNo,
                year: year,
                genre: genre,
                durationMs: durationMs,
                uri: uri,
                artUri: artUri,
                addedAt: addedAt,
                inLibrary: inLibrary,
                available: available,
                fileMtimeMs: fileMtimeMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, TrackRow>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playEventsRefs = false, trackStatsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playEventsRefs) db.playEvents,
                    if (trackStatsRefs) db.trackStats,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playEventsRefs)
                        await $_getPrefetchedData<
                          TrackRow,
                          $TracksTable,
                          PlayEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._playEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).playEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackStatsRefs)
                        await $_getPrefetchedData<
                          TrackRow,
                          $TracksTable,
                          TrackStatRow
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._trackStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).trackStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      TrackRow,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (TrackRow, $$TracksTableReferences),
      TrackRow,
      PrefetchHooks Function({bool playEventsRefs, bool trackStatsRefs})
    >;
typedef $$PlayEventsTableCreateCompanionBuilder = PlayEventsCompanion Function({
  Value<int> id,
  required String trackId,
  required DateTime startedAt,
  required int msPlayed,
  required bool counted,
  required bool skipped,
});
typedef $$PlayEventsTableUpdateCompanionBuilder = PlayEventsCompanion Function({
  Value<int> id,
  Value<String> trackId,
  Value<DateTime> startedAt,
  Value<int> msPlayed,
  Value<bool> counted,
  Value<bool> skipped,
});

final class $$PlayEventsTableReferences
    extends BaseReferences<_$AppDatabase, $PlayEventsTable, PlayEventRow> {
  $$PlayEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('play_events__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayEventsTable> {
  $$PlayEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get msPlayed => $composableBuilder(
    column: $table.msPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayEventsTable> {
  $$PlayEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get msPlayed => $composableBuilder(
    column: $table.msPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get counted => $composableBuilder(
    column: $table.counted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayEventsTable> {
  $$PlayEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get msPlayed =>
      $composableBuilder(column: $table.msPlayed, builder: (column) => column);

  GeneratedColumn<bool> get counted =>
      $composableBuilder(column: $table.counted, builder: (column) => column);

  GeneratedColumn<bool> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayEventsTable,
          PlayEventRow,
          $$PlayEventsTableFilterComposer,
          $$PlayEventsTableOrderingComposer,
          $$PlayEventsTableAnnotationComposer,
          $$PlayEventsTableCreateCompanionBuilder,
          $$PlayEventsTableUpdateCompanionBuilder,
          (PlayEventRow, $$PlayEventsTableReferences),
          PlayEventRow,
          PrefetchHooks Function({bool trackId})
        > {
  $$PlayEventsTableTableManager(_$AppDatabase db, $PlayEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> msPlayed = const Value.absent(),
                Value<bool> counted = const Value.absent(),
                Value<bool> skipped = const Value.absent(),
              }) => PlayEventsCompanion(
                id: id,
                trackId: trackId,
                startedAt: startedAt,
                msPlayed: msPlayed,
                counted: counted,
                skipped: skipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trackId,
                required DateTime startedAt,
                required int msPlayed,
                required bool counted,
                required bool skipped,
              }) => PlayEventsCompanion.insert(
                id: id,
                trackId: trackId,
                startedAt: startedAt,
                msPlayed: msPlayed,
                counted: counted,
                skipped: skipped,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayEventsTable, PlayEventRow>(table),
                  $$PlayEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$PlayEventsTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$PlayEventsTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayEventsTable,
      PlayEventRow,
      $$PlayEventsTableFilterComposer,
      $$PlayEventsTableOrderingComposer,
      $$PlayEventsTableAnnotationComposer,
      $$PlayEventsTableCreateCompanionBuilder,
      $$PlayEventsTableUpdateCompanionBuilder,
      (PlayEventRow, $$PlayEventsTableReferences),
      PlayEventRow,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$TrackStatsTableCreateCompanionBuilder = TrackStatsCompanion Function({
  required String trackId,
  Value<int> playCount,
  Value<int> skipCount,
  Value<DateTime?> lastPlayedAt,
  Value<int> rowid,
});
typedef $$TrackStatsTableUpdateCompanionBuilder = TrackStatsCompanion Function({
  Value<String> trackId,
  Value<int> playCount,
  Value<int> skipCount,
  Value<DateTime?> lastPlayedAt,
  Value<int> rowid,
});

final class $$TrackStatsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackStatsTable, TrackStatRow> {
  $$TrackStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('track_stats__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackStatsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackStatsTable> {
  $$TrackStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackStatsTable> {
  $$TrackStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipCount => $composableBuilder(
    column: $table.skipCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackStatsTable> {
  $$TrackStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get skipCount =>
      $composableBuilder(column: $table.skipCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackStatsTable,
          TrackStatRow,
          $$TrackStatsTableFilterComposer,
          $$TrackStatsTableOrderingComposer,
          $$TrackStatsTableAnnotationComposer,
          $$TrackStatsTableCreateCompanionBuilder,
          $$TrackStatsTableUpdateCompanionBuilder,
          (TrackStatRow, $$TrackStatsTableReferences),
          TrackStatRow,
          PrefetchHooks Function({bool trackId})
        > {
  $$TrackStatsTableTableManager(_$AppDatabase db, $TrackStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackStatsCompanion(
                trackId: trackId,
                playCount: playCount,
                skipCount: skipCount,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                Value<int> playCount = const Value.absent(),
                Value<int> skipCount = const Value.absent(),
                Value<DateTime?> lastPlayedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackStatsCompanion.insert(
                trackId: trackId,
                playCount: playCount,
                skipCount: skipCount,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackStatsTable, TrackStatRow>(table),
                  $$TrackStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackStatsTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackStatsTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackStatsTable,
      TrackStatRow,
      $$TrackStatsTableFilterComposer,
      $$TrackStatsTableOrderingComposer,
      $$TrackStatsTableAnnotationComposer,
      $$TrackStatsTableCreateCompanionBuilder,
      $$TrackStatsTableUpdateCompanionBuilder,
      (TrackStatRow, $$TrackStatsTableReferences),
      TrackStatRow,
      PrefetchHooks Function({bool trackId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$PlayEventsTableTableManager get playEvents =>
      $$PlayEventsTableTableManager(_db, _db.playEvents);
  $$TrackStatsTableTableManager get trackStats =>
      $$TrackStatsTableTableManager(_db, _db.trackStats);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
