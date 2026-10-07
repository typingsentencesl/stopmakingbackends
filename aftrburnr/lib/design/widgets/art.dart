import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';

/// Album art. Radius 4 up to 64 px, 8 above (DESIGN.md §5). Without art it
/// shows a quiet `bg3` square with a note glyph: no gradients, no generated
/// color.
class Art extends StatelessWidget {
  const Art({super.key, required this.uri, required this.size});

  /// File path, `file://` URI or http(s) URL.
  final String? uri;
  final double size;

  BorderRadius get _radius => size > 64 ? R.panel : R.small;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cache = (size * dpr).round();
    final u = uri;
    Widget img;
    if (u == null || u.isEmpty) {
      img = _placeholder();
    } else if (u.startsWith('http://') || u.startsWith('https://')) {
      img = Image.network(
        u,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cache,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else {
      img = Image.file(
        File(u.startsWith('file://') ? Uri.parse(u).toFilePath() : u),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cache,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return ClipRRect(
      borderRadius: _radius,
      child: SizedBox.square(dimension: size, child: img),
    );
  }

  Widget _placeholder() => Container(
    width: size,
    height: size,
    color: C.bg3,
    alignment: Alignment.center,
    child: size < S.s7
        ? null
        : Icon(
            LucideIcons.music,
            size: (size * 0.4).clamp(IconSz.row, 64.0),
            color: C.textLow,
          ),
  );
}
