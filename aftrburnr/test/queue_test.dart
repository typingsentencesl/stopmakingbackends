import 'dart:math';

import 'package:aftrburnr/audio/queue.dart';
import 'package:aftrburnr/audio/shuffle.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> ids(PlayQueue q) => [for (final e in q.entries) e.trackId];
List<String> tracks(int n) => [for (var i = 0; i < n; i++) 't$i'];

void main() {
  group('basic navigation', () {
    test('replace starts at index and next walks forward', () {
      var q = PlayQueue.empty.replace(tracks(3), startIndex: 1);
      expect(q.currentEntry!.trackId, 't1');
      var a = q.next();
      expect(a.ended, isFalse);
      expect(a.queue.currentEntry!.trackId, 't2');
      a = a.queue.next();
      expect(a.ended, isTrue);
      expect(a.queue.currentEntry!.trackId, 't2');
    });

    test('previous stops at start unless repeat all', () {
      final q = PlayQueue.empty.replace(tracks(3));
      expect(q.previous().ended, isTrue);
      final r = q.withRepeat(QueueRepeat.all).previous();
      expect(r.ended, isFalse);
      expect(r.queue.currentEntry!.trackId, 't2');
    });

    test('repeat one replays on natural end but user next moves on', () {
      final q = PlayQueue.empty.replace(tracks(3)).withRepeat(QueueRepeat.one);
      expect(q.next().queue.currentEntry!.trackId, 't0');
      expect(q.next(user: true).queue.currentEntry!.trackId, 't1');
    });

    test('repeat all wraps', () {
      final q = PlayQueue.empty
          .replace(tracks(2), startIndex: 1)
          .withRepeat(QueueRepeat.all);
      final a = q.next();
      expect(a.ended, isFalse);
      expect(a.queue.current, 0);
    });
  });

  group('play next / play last', () {
    test('play next keeps the order the user added things', () {
      var q = PlayQueue.empty.replace(tracks(3));
      q = q.playNext(['a']).playNext(['b']).playNext(['c', 'd']);
      expect(ids(q), ['t0', 'a', 'b', 'c', 'd', 't1', 't2']);
      expect(q.entries[1].origin, QueueOrigin.next);
    });

    test('play last appends', () {
      final q = PlayQueue.empty.replace(tracks(2)).playLast(['x']);
      expect(ids(q), ['t0', 't1', 'x']);
    });

    test('playing a next-up entry turns it into history', () {
      var q = PlayQueue.empty.replace(tracks(2)).playNext(['a', 'b']);
      q = q.next().queue;
      expect(q.currentEntry!.trackId, 'a');
      expect(q.currentEntry!.origin, isNot(QueueOrigin.next));
      // 'b' is still in the next-up block, so a new play-next goes after it.
      q = q.playNext(['c']);
      expect(ids(q), ['t0', 'a', 'b', 'c', 't1']);
    });

    test('adding to an empty queue starts it', () {
      final q = PlayQueue.empty.playLast(['x', 'y']);
      expect(q.current, 0);
      expect(PlayQueue.empty.playNext(['x']).current, 0);
    });

    test('uids are unique even for duplicate tracks', () {
      final q = PlayQueue.empty.replace(['a', 'a']).playLast(['a']);
      expect(q.entries.map((e) => e.uid).toSet().length, 3);
    });
  });

  group('remove and move', () {
    test('removing current makes the following entry current', () {
      var q = PlayQueue.empty.replace(tracks(4), startIndex: 1);
      q = q.remove({q.currentEntry!.uid});
      expect(q.currentEntry!.trackId, 't2');
      expect(ids(q), ['t0', 't2', 't3']);
    });

    test('removing current at the end falls back to the last entry', () {
      var q = PlayQueue.empty.replace(tracks(3), startIndex: 2);
      q = q.remove({q.currentEntry!.uid});
      expect(q.currentEntry!.trackId, 't1');
    });

    test('removing entries before current keeps current', () {
      var q = PlayQueue.empty.replace(tracks(4), startIndex: 2);
      q = q.remove({q.entries[0].uid, q.entries[3].uid});
      expect(q.currentEntry!.trackId, 't2');
      expect(q.current, 1);
    });

    test('multi-select move keeps relative order', () {
      var q = PlayQueue.empty.replace(tracks(6));
      final sel = {q.entries[1].uid, q.entries[3].uid};
      q = q.move(sel, 6);
      expect(ids(q), ['t0', 't2', 't4', 't5', 't1', 't3']);
      expect(q.currentEntry!.trackId, 't0');
    });

    test('moving the current entry keeps it current', () {
      var q = PlayQueue.empty.replace(tracks(4), startIndex: 0);
      q = q.move({q.entries[0].uid}, 3);
      expect(ids(q), ['t1', 't2', 't0', 't3']);
      expect(q.currentEntry!.trackId, 't0');
    });

    test(
      'dropping into the next-up block joins it, dragging out leaves it',
      () {
        var q = PlayQueue.empty.replace(tracks(4)).playNext(['a', 'b']);
        // [t0, a, b, t1, t2, t3]; drag t3 between a and b.
        q = q.move({q.entries[5].uid}, 2);
        expect(ids(q), ['t0', 'a', 't3', 'b', 't1', 't2']);
        expect(q.entries[2].origin, QueueOrigin.next);
        // Drag 'a' to the end.
        q = q.move({q.entries[1].uid}, 6);
        expect(ids(q), ['t0', 't3', 'b', 't1', 't2', 'a']);
        expect(q.entries.last.origin, QueueOrigin.last);
      },
    );

    test('an explicit section overrides the inferred one', () {
      var q = PlayQueue.empty.replace(tracks(4)).playNext(['a']);
      // [t0, a, t1, t2, t3]; drop t3 right after 'a' but into "Next up".
      q = q.move({q.entries[4].uid}, 2, intoNext: false);
      expect(ids(q), ['t0', 'a', 't3', 't1', 't2']);
      expect(q.entries[2].origin, isNot(QueueOrigin.next));
      // Drop t2 at the same boundary into "Next in queue".
      q = q.move({q.entries[4].uid}, 2, intoNext: true);
      expect(ids(q), ['t0', 'a', 't2', 't3', 't1']);
      expect(q.entries[2].origin, QueueOrigin.next);
      // With no block at all, intoNext creates one right after current.
      var r = PlayQueue.empty.replace(tracks(3));
      r = r.move({r.entries[2].uid}, 3, intoNext: true);
      expect(ids(r), ['t0', 't2', 't1']);
      expect(r.entries[1].origin, QueueOrigin.next);
    });

    test('makeNext moves rows into the next-up block, from either side', () {
      var q = PlayQueue.empty.replace(tracks(5), startIndex: 2).playNext(['n']);
      // [t0, t1, t2*, n, t3, t4]
      q = q.makeNext({q.entries[0].uid, q.entries[5].uid});
      expect(ids(q), ['t1', 't2', 'n', 't0', 't4', 't3']);
      expect(q.currentEntry!.trackId, 't2');
      expect(q.entries[3].origin, QueueOrigin.next);
      expect(q.entries[4].origin, QueueOrigin.next);
    });

    test('jumpTo selects an entry', () {
      final q = PlayQueue.empty.replace(tracks(3));
      expect(q.jumpTo(q.entries[2].uid).current, 2);
    });
  });

  group('shuffle', () {
    test('shuffle keeps played entries, current and next-up in place', () {
      var q = PlayQueue.empty.replace(tracks(10), startIndex: 3).playNext([
        'n',
      ]);
      q = q.withShuffle(ShuffleMode.random, random: Random(1));
      expect(ids(q).take(5), ['t0', 't1', 't2', 't3', 'n']);
      expect(ids(q).skip(5).toSet(), {'t4', 't5', 't6', 't7', 't8', 't9'});
    });

    test('turning shuffle off restores original order around current', () {
      var q = PlayQueue.empty.replace(tracks(8), startIndex: 2);
      q = q.withShuffle(ShuffleMode.random, random: Random(7));
      q = q.next().queue.next().queue; // play two shuffled tracks
      final playing = q.currentEntry!.trackId;
      q = q.withShuffle(ShuffleMode.off);
      expect(ids(q), tracks(8));
      expect(q.currentEntry!.trackId, playing);
    });

    test(
      'unshuffle keeps next-up right after current and tracks added later',
      () {
        var q = PlayQueue.empty.replace(tracks(5));
        q = q.withShuffle(ShuffleMode.random, random: Random(3));
        q = q.playNext(['n']).playLast(['z'], random: Random(4));
        q = q.withShuffle(ShuffleMode.off);
        expect(ids(q), ['t0', 'n', 't1', 't2', 't3', 't4', 'z']);
      },
    );

    test('starting a shuffled context plays the chosen track first', () {
      final q = PlayQueue.empty
          .withShuffle(ShuffleMode.random)
          .replace(tracks(20), startIndex: 7, random: Random(2));
      expect(q.current, 0);
      expect(q.currentEntry!.trackId, 't7');
      expect(ids(q).toSet(), tracks(20).toSet());
      // And un-shuffling puts it back in context order.
      final u = q.withShuffle(ShuffleMode.off);
      expect(ids(u), tracks(20));
      expect(u.current, 7);
    });

    test('Fisher–Yates is uniform over all permutations', () {
      // 3 items → 6 permutations; 60k draws → 10k each. A biased shuffle
      // (e.g. the naive swap-with-any) is off by >10% on some permutation.
      final r = Random(42);
      final counts = <String, int>{};
      for (var i = 0; i < 60000; i++) {
        final k = shuffled([1, 2, 3], r).join();
        counts[k] = (counts[k] ?? 0) + 1;
      }
      expect(counts.length, 6);
      for (final c in counts.values) {
        expect(c, inInclusiveRange(9500, 10500));
      }
    });

    test('least recently played: never played first, then oldest', () {
      final now = DateTime(2026, 1, 10);
      final last = {
        't0': now,
        't1': now.subtract(const Duration(days: 5)),
        't2': null,
        't3': now.subtract(const Duration(days: 1)),
        't4': null,
      };
      var q = PlayQueue.empty.replace([
        't0',
        't1',
        't2',
        't3',
        't4',
      ], startIndex: 0);
      q = q.withShuffle(
        ShuffleMode.leastRecent,
        lastPlayed: last,
        random: Random(5),
      );
      final up = ids(q).skip(1).toList();
      expect(up.take(2).toSet(), {'t2', 't4'});
      expect(up.skip(2), ['t1', 't3']);
    });

    test('least recently played breaks ties randomly', () {
      final seen = <String>{};
      for (var s = 0; s < 30; s++) {
        final r = leastRecentFirst(['a', 'b', 'c'], (_) => null, Random(s));
        seen.add(r.first);
      }
      expect(seen, {'a', 'b', 'c'});
    });

    test('play last in random shuffle lands among upcoming, after next-up', () {
      var q = PlayQueue.empty.replace(tracks(6)).playNext(['n']);
      q = q.withShuffle(ShuffleMode.random, random: Random(9));
      q = q.playLast(['x'], random: Random(11));
      final i = ids(q).indexOf('x');
      expect(i, greaterThan(1));
    });
  });

  test('json round trip', () {
    var q = PlayQueue.empty.replace(tracks(5), startIndex: 2).playNext(['n']);
    q = q
        .withShuffle(ShuffleMode.random, random: Random(1))
        .withRepeat(QueueRepeat.all);
    final back = PlayQueue.fromJson(Map<String, dynamic>.from(q.toJson()));
    expect(back.entries, q.entries);
    expect(back.current, q.current);
    expect(back.repeat, q.repeat);
    expect(back.shuffle, q.shuffle);
    expect(back.originalOrder, q.originalOrder);
    expect(back.nextUid, q.nextUid);
  });
}
