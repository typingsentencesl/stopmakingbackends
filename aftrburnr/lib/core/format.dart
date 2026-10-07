/// `m:ss` under an hour, `h:mm:ss` above (DESIGN.md §11).
String formatDuration(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// Totals: `82 h 14 m`, `14 m`, `45 s`.
String formatTotal(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0) return '$h h $m m';
  if (d.inMinutes > 0) return '${d.inMinutes} m';
  return '${d.inSeconds} s';
}

/// Exact counts with thousands separators: `1,284`.
String formatCount(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/// `1 track` / `12 tracks`.
String plural(int n, String one, [String? many]) =>
    '${formatCount(n)} ${n == 1 ? one : (many ?? '${one}s')}';
