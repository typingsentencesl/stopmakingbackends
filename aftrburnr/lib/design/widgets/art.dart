import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens.dart';

/// Square album art, radius 0. Without art it shows a quiet `bg2` square
/// with a small disc glyph: no gradients, no generated color.
class Art extends StatelessWidget {
  const Art({super.key, required this.uri, required this.size});

  /// File path, `file://` URI or http(s) URL.
  final String? uri;
  final double size;

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
    return SizedBox.square(dimension: size, child: img);
  }

  /// Below 32 px a glyph turns into noise, so small placeholders are a
  /// plain tone step.
  Widget _placeholder() => Container(
    width: size,
    height: size,
    color: C.bg2,
    alignment: Alignment.center,
    child: size < S.s7
        ? null
        : Icon(
            LucideIcons.disc3,
            size: (size * 0.4).clamp(10.0, 48.0),
            color: C.textOff,
          ),
  );
}
