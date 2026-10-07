import 'dart:math';

/// Shared CSPRNG. Shuffle has to be honestly random: no artist spreading,
/// no weighting toward "favourites", every permutation equally likely.
final Random secureRandom = Random.secure();

/// Fisher–Yates (Durstenfeld) shuffle; returns a new list.
List<T> shuffled<T>(List<T> items, Random random) {
  final out = [...items];
  for (var i = out.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final t = out[i];
    out[i] = out[j];
    out[j] = t;
  }
  return out;
}

/// Orders items by when they were last played, oldest first. Items never
/// played come first. Ties (including all never-played items) are broken
/// randomly so repeated use doesn't always start with the same track.
List<T> leastRecentFirst<T>(
  List<T> items,
  DateTime? Function(T) lastPlayed,
  Random random,
) {
  final keyed = [
    for (final it in shuffled(items, random)) (it, lastPlayed(it)),
  ];
  // Dart's List.sort is not guaranteed stable, so sort an indexed copy.
  final indexed = [for (var i = 0; i < keyed.length; i++) (i, keyed[i])];
  indexed.sort((a, b) {
    final la = a.$2.$2, lb = b.$2.$2;
    if (la == null && lb == null) return a.$1.compareTo(b.$1);
    if (la == null) return -1;
    if (lb == null) return 1;
    final c = la.compareTo(lb);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final x in indexed) x.$2.$1];
}
