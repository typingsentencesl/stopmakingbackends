import 'dart:math';

import 'shuffle.dart';

/// Where a queue entry came from.
enum QueueOrigin {
  /// Part of the thing the user pressed play on (album, playlist, selection).
  context,

  /// Added with "play next". Sits directly after the current entry, in the
  /// order the user added them, and is never moved by shuffle.
  next,

  /// Added with "play last".
  last,
}

enum QueueRepeat { off, all, one }

enum ShuffleMode {
  off,

  /// Uniform Fisher–Yates over a CSPRNG: every order equally likely.
  random,

  /// Least recently played first; never-played tracks lead, ties random.
  leastRecent,
}

class QueueEntry {
  const QueueEntry(this.uid, this.trackId, this.origin);

  /// Unique within one queue, so the same track can appear twice.
  final int uid;
  final String trackId;
  final QueueOrigin origin;

  QueueEntry withOrigin(QueueOrigin o) => QueueEntry(uid, trackId, o);

  List<Object> toJson() => [uid, trackId, origin.index];

  static QueueEntry fromJson(List<dynamic> j) =>
      QueueEntry(j[0] as int, j[1] as String, QueueOrigin.values[j[2] as int]);

  @override
  bool operator ==(Object other) =>
      other is QueueEntry &&
      other.uid == uid &&
      other.trackId == trackId &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(uid, trackId, origin);

  @override
  String toString() => 'Q($uid,$trackId,${origin.name})';
}

/// Result of moving to another entry.
class Advance {
  const Advance(this.queue, {required this.ended});
  final PlayQueue queue;

  /// True when there was nothing to move to; [queue] is unchanged.
  final bool ended;
}

/// Immutable play queue. Entries before [current] have been played this
/// session ("Played" in the UI), entries after it are upcoming.
class PlayQueue {
  const PlayQueue({
    this.entries = const [],
    this.current = -1,
    this.repeat = QueueRepeat.off,
    this.shuffle = ShuffleMode.off,
    this.originalOrder = const [],
    this.nextUid = 1,
  });

  final List<QueueEntry> entries;

  /// Index into [entries], or -1 when empty.
  final int current;
  final QueueRepeat repeat;
  final ShuffleMode shuffle;

  /// Uids in the order they had before shuffle was turned on.
  final List<int> originalOrder;
  final int nextUid;

  static const empty = PlayQueue();

  bool get isEmpty => entries.isEmpty;
  QueueEntry? get currentEntry =>
      current >= 0 && current < entries.length ? entries[current] : null;

  List<QueueEntry> get played =>
      current <= 0 ? const [] : entries.sublist(0, current);
  List<QueueEntry> get upcoming =>
      current < 0 ? entries : entries.sublist(current + 1);

  /// Index one past the end of the "next up" block that follows current.
  int get _nextBlockEnd {
    var i = current + 1;
    while (i < entries.length && entries[i].origin == QueueOrigin.next) {
      i++;
    }
    return i;
  }

  PlayQueue copyWith({
    List<QueueEntry>? entries,
    int? current,
    QueueRepeat? repeat,
    ShuffleMode? shuffle,
    List<int>? originalOrder,
    int? nextUid,
  }) {
    return PlayQueue(
      entries: entries ?? this.entries,
      current: current ?? this.current,
      repeat: repeat ?? this.repeat,
      shuffle: shuffle ?? this.shuffle,
      originalOrder: originalOrder ?? this.originalOrder,
      nextUid: nextUid ?? this.nextUid,
    );
  }

  List<QueueEntry> _make(List<String> ids, QueueOrigin origin, int from) => [
    for (var i = 0; i < ids.length; i++) QueueEntry(from + i, ids[i], origin),
  ];

  /// Replace the queue with a new context and start at [startIndex].
  /// Shuffle mode is kept; when on, the context is shuffled with the
  /// started track placed first.
  PlayQueue replace(
    List<String> trackIds, {
    int startIndex = 0,
    Random? random,
    Map<String, DateTime?> lastPlayed = const {},
  }) {
    if (trackIds.isEmpty) {
      return PlayQueue(repeat: repeat, shuffle: shuffle, nextUid: nextUid);
    }
    final start = startIndex.clamp(0, trackIds.length - 1);
    final made = _make(trackIds, QueueOrigin.context, nextUid);
    var q = PlayQueue(
      entries: made,
      current: start,
      repeat: repeat,
      shuffle: ShuffleMode.off,
      nextUid: nextUid + made.length,
    );
    if (shuffle != ShuffleMode.off) {
      // Starting a shuffled context: the chosen track plays first, the rest
      // of the context follows in shuffled order.
      final chosen = made[start];
      final rest = [...made]..removeAt(start);
      q = q.copyWith(entries: [chosen, ...rest], current: 0);
      q = q.withShuffle(
        shuffle,
        random: random,
        lastPlayed: lastPlayed,
        originalOverride: [for (final e in made) e.uid],
      );
    }
    return q;
  }

  PlayQueue playNext(List<String> trackIds) {
    if (trackIds.isEmpty) return this;
    final made = _make(trackIds, QueueOrigin.next, nextUid);
    if (current < 0) {
      return copyWith(
        entries: [...entries, ...made],
        current: 0,
        nextUid: nextUid + made.length,
        originalOrder: _extendOriginal(made),
      );
    }
    final at = _nextBlockEnd;
    return copyWith(
      entries: [...entries]..insertAll(at, made),
      nextUid: nextUid + made.length,
      originalOrder: _extendOriginal(made),
    );
  }

  PlayQueue playLast(List<String> trackIds, {Random? random}) {
    if (trackIds.isEmpty) return this;
    final made = _make(trackIds, QueueOrigin.last, nextUid);
    final list = [...entries];
    if (shuffle == ShuffleMode.random && current >= 0) {
      // In a shuffled queue new tracks land at uniformly random positions
      // among the upcoming (non "next up") entries.
      final r = random ?? secureRandom;
      final lo = _nextBlockEnd;
      for (final e in made) {
        final pos = lo + r.nextInt(list.length - lo + 1);
        list.insert(pos, e);
      }
    } else {
      list.addAll(made);
    }
    return copyWith(
      entries: list,
      current: current < 0 ? 0 : current,
      nextUid: nextUid + made.length,
      originalOrder: _extendOriginal(made),
    );
  }

  List<int> _extendOriginal(List<QueueEntry> made) => shuffle == ShuffleMode.off
      ? originalOrder
      : [...originalOrder, for (final e in made) e.uid];

  /// Remove entries by uid. Removing the current entry makes the following
  /// entry current (the caller loads it).
  PlayQueue remove(Set<int> uids) {
    if (uids.isEmpty) return this;
    final list = <QueueEntry>[];
    var newCurrent = -1;
    var curRemoved = false;
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (uids.contains(e.uid)) {
        if (i == current) curRemoved = true;
        continue;
      }
      if (i == current) newCurrent = list.length;
      // First surviving entry after a removed current becomes current.
      if (curRemoved && newCurrent < 0 && i > current) newCurrent = list.length;
      list.add(e);
    }
    if (list.isEmpty) {
      return PlayQueue(repeat: repeat, shuffle: shuffle, nextUid: nextUid);
    }
    if (newCurrent < 0) {
      // Current was removed and nothing followed it.
      newCurrent = curRemoved ? list.length - 1 : 0;
    }
    return copyWith(
      entries: list,
      current: newCurrent,
      originalOrder: originalOrder.where((u) => !uids.contains(u)).toList(),
    );
  }

  /// Move the entries with [uids] (kept in their current relative order) so
  /// they start at [toIndex], where [toIndex] is an index into the list as it
  /// is before the move. The current entry may be moved; it stays current.
  ///
  /// Entries dropped inside an existing "next up" block join it; `next`
  /// entries dragged out of the block become ordinary queued entries.
  ///
  /// [intoNext] overrides that inference when the UI knows which section
  /// the rows were dropped into (the boundary between the "next up" block
  /// and the rest is otherwise ambiguous). The drop position is clamped
  /// into that section.
  PlayQueue move(Set<int> uids, int toIndex, {bool? intoNext}) {
    if (uids.isEmpty) return this;
    final moving = [
      for (final e in entries)
        if (uids.contains(e.uid)) e,
    ];
    final rest = [
      for (final e in entries)
        if (!uids.contains(e.uid)) e,
    ];
    var at = entries
        .take(toIndex.clamp(0, entries.length))
        .where((e) => !uids.contains(e.uid))
        .length;
    final curUid = currentEntry?.uid;
    final restCur = rest.indexWhere((e) => e.uid == curUid);
    var blockLen = 0;
    if (restCur >= 0) {
      while (restCur + 1 + blockLen < rest.length &&
          rest[restCur + 1 + blockLen].origin == QueueOrigin.next) {
        blockLen++;
      }
    }
    bool intoBlock;
    if (intoNext != null && restCur >= 0 && at > restCur) {
      intoBlock = intoNext;
      final blockEnd = restCur + 1 + blockLen;
      at = intoNext
          ? at.clamp(restCur + 1, blockEnd)
          : (at < blockEnd ? blockEnd : at);
    } else {
      intoBlock =
          restCur >= 0 &&
          blockLen > 0 &&
          at > restCur &&
          at <= restCur + blockLen;
    }
    final placed = [
      for (final e in moving)
        if (e.uid == curUid)
          e
        else if (intoBlock)
          e.withOrigin(QueueOrigin.next)
        else if (e.origin == QueueOrigin.next)
          e.withOrigin(QueueOrigin.last)
        else
          e,
    ];
    final list = [...rest]..insertAll(at, placed);
    return copyWith(
      entries: list,
      current: curUid == null
          ? current
          : list.indexWhere((e) => e.uid == curUid),
    );
  }

  /// Moves existing entries to the end of the "next up" block, in their
  /// current relative order ("play next" on rows already in the queue).
  /// The current entry is left where it is.
  PlayQueue makeNext(Set<int> uids) {
    final curUid = currentEntry?.uid;
    final sel = {...uids}..remove(curUid);
    if (sel.isEmpty || curUid == null) return this;
    final moving = [
      for (final e in entries)
        if (sel.contains(e.uid)) e.withOrigin(QueueOrigin.next),
    ];
    final rest = [
      for (final e in entries)
        if (!sel.contains(e.uid)) e,
    ];
    var at = rest.indexWhere((e) => e.uid == curUid) + 1;
    while (at < rest.length && rest[at].origin == QueueOrigin.next) {
      at++;
    }
    final list = [...rest]..insertAll(at, moving);
    return copyWith(
      entries: list,
      current: list.indexWhere((e) => e.uid == curUid),
    );
  }

  PlayQueue jumpTo(int uid) {
    final i = entries.indexWhere((e) => e.uid == uid);
    if (i < 0) return this;
    return copyWith(current: i);
  }

  /// Move forward. [user] is true for the next button, false when a track
  /// ended on its own (only then does repeat-one replay the same entry).
  Advance next({
    bool user = false,
    Random? random,
    Map<String, DateTime?> lastPlayed = const {},
  }) {
    if (entries.isEmpty) return Advance(this, ended: true);
    if (!user && repeat == QueueRepeat.one) {
      return Advance(this, ended: false);
    }
    if (current + 1 < entries.length) {
      return Advance(_consumeNext(current + 1), ended: false);
    }
    if (repeat == QueueRepeat.off) return Advance(this, ended: true);
    // Repeat all: wrap. A shuffled queue gets a fresh order for the next lap.
    var q = copyWith(current: 0);
    if (shuffle != ShuffleMode.off) {
      final r = random ?? secureRandom;
      final order = shuffle == ShuffleMode.random
          ? shuffled(entries, r)
          : leastRecentFirst(entries, (e) => lastPlayed[e.trackId], r);
      q = q.copyWith(entries: order);
    }
    return Advance(q, ended: false);
  }

  /// "Next up" entries become ordinary history once played.
  PlayQueue _consumeNext(int newCurrent) {
    final e = entries[newCurrent];
    if (e.origin != QueueOrigin.next) return copyWith(current: newCurrent);
    final list = [...entries];
    list[newCurrent] = e.withOrigin(QueueOrigin.last);
    return copyWith(entries: list, current: newCurrent);
  }

  /// Move back one entry. Wraps only with repeat all.
  Advance previous() {
    if (entries.isEmpty) return Advance(this, ended: true);
    if (current > 0) {
      return Advance(copyWith(current: current - 1), ended: false);
    }
    if (repeat == QueueRepeat.all) {
      return Advance(copyWith(current: entries.length - 1), ended: false);
    }
    return Advance(this, ended: true);
  }

  PlayQueue withRepeat(QueueRepeat mode) => copyWith(repeat: mode);

  /// Change shuffle mode. Played entries and the "next up" block keep their
  /// places; only the rest of the upcoming entries are reordered. Turning
  /// shuffle off restores the order from before it was turned on.
  PlayQueue withShuffle(
    ShuffleMode mode, {
    Random? random,
    Map<String, DateTime?> lastPlayed = const {},
    List<int>? originalOverride,
  }) {
    final r = random ?? secureRandom;
    if (mode == ShuffleMode.off) {
      if (shuffle == ShuffleMode.off) return this;
      return _unshuffle();
    }
    final original =
        originalOverride ??
        (shuffle == ShuffleMode.off
            ? [for (final e in entries) e.uid]
            : originalOrder);
    if (entries.isEmpty) {
      return copyWith(shuffle: mode, originalOrder: original);
    }
    final head = entries.sublist(0, current < 0 ? 0 : _nextBlockEnd);
    final tail = entries.sublist(current < 0 ? 0 : _nextBlockEnd);
    final reordered = mode == ShuffleMode.random
        ? shuffled(tail, r)
        : leastRecentFirst(tail, (e) => lastPlayed[e.trackId], r);
    return copyWith(
      entries: [...head, ...reordered],
      shuffle: mode,
      originalOrder: original,
    );
  }

  PlayQueue _unshuffle() {
    final cur = currentEntry;
    if (cur == null) {
      return copyWith(shuffle: ShuffleMode.off, originalOrder: const []);
    }
    final rank = {
      for (var i = 0; i < originalOrder.length; i++) originalOrder[i]: i,
    };
    final nextBlock = entries.sublist(current + 1, _nextBlockEnd);
    final nextUids = {for (final e in nextBlock) e.uid};
    final others = [
      for (final e in entries)
        if (e.uid != cur.uid && !nextUids.contains(e.uid)) e,
    ];
    // Stable sort by original rank; unknown entries keep their relative
    // order at the end.
    final known = others.where((e) => rank.containsKey(e.uid)).toList()
      ..sort((a, b) => rank[a.uid]!.compareTo(rank[b.uid]!));
    final unknown = others.where((e) => !rank.containsKey(e.uid));
    final ordered = [...known, ...unknown];
    final curRank = rank[cur.uid];
    final before = curRank == null
        ? ordered.length
        : ordered.where((e) => (rank[e.uid] ?? 1 << 30) < curRank).length;
    final list = [
      ...ordered.take(before),
      cur,
      ...nextBlock,
      ...ordered.skip(before),
    ];
    return copyWith(
      entries: list,
      current: before,
      shuffle: ShuffleMode.off,
      originalOrder: const [],
    );
  }

  Map<String, Object?> toJson() => {
    'entries': [for (final e in entries) e.toJson()],
    'current': current,
    'repeat': repeat.index,
    'shuffle': shuffle.index,
    'original': originalOrder,
    'nextUid': nextUid,
  };

  static PlayQueue fromJson(Map<String, dynamic> j) {
    final entries = [
      for (final e in j['entries'] as List) QueueEntry.fromJson(e as List),
    ];
    final current = j['current'] as int;
    return PlayQueue(
      entries: entries,
      current: entries.isEmpty ? -1 : current.clamp(0, entries.length - 1),
      repeat: QueueRepeat.values[j['repeat'] as int],
      shuffle: ShuffleMode.values[j['shuffle'] as int],
      originalOrder: [for (final u in j['original'] as List) u as int],
      nextUid: j['nextUid'] as int,
    );
  }
}
