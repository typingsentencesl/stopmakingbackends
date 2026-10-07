import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// The dominant color of a piece of album art, reduced to a dark, muted
/// band color (DESIGN.md §4): tone [tone], chroma at most [maxChroma].
/// Returns null when the art can't be read or has no usable color, and the
/// caller falls back to a surface token.
Future<Color?> bandColorFor(
  Uint8List bytes, {
  double tone = 14,
  double maxChroma = 28,
}) async {
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: 48,
    targetHeight: 48,
  );
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  frame.image.dispose();
  codec.dispose();
  if (data == null) return null;
  final pixels = <int>[];
  for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
    final a = data.getUint8(i + 3);
    if (a < 255) continue;
    pixels.add(
      (a << 24) |
          (data.getUint8(i) << 16) |
          (data.getUint8(i + 1) << 8) |
          data.getUint8(i + 2),
    );
  }
  if (pixels.isEmpty) return null;
  final q = await QuantizerCelebi().quantize(pixels, 32);
  // filter: false keeps near-greys, so a black-and-white sleeve gets a grey
  // band instead of Score's fallback hue.
  final ranked = Score.score(
    q.colorToCount,
    desired: 1,
    fallbackColorARGB: 0,
    filter: false,
  );
  if (ranked.isEmpty || ranked.first == 0) return null;
  final hct = Hct.fromInt(ranked.first);
  final out = Hct.from(
    hct.hue,
    hct.chroma < maxChroma ? hct.chroma : maxChroma,
    tone,
  );
  return Color(out.toInt());
}

/// Band color per art URI, computed once per session.
final artBandColorProvider = FutureProvider.family<Color?, String>((
  ref,
  uri,
) async {
  try {
    final Uint8List bytes;
    if (uri.startsWith('http://') || uri.startsWith('https://')) {
      final client = HttpClient();
      try {
        final req = await client.getUrl(Uri.parse(uri));
        final res = await req.close();
        if (res.statusCode != 200) return null;
        final b = BytesBuilder(copy: false);
        await for (final chunk in res) {
          b.add(chunk);
        }
        bytes = b.takeBytes();
      } finally {
        client.close();
      }
    } else {
      final path = uri.startsWith('file://')
          ? Uri.parse(uri).toFilePath()
          : uri;
      bytes = await File(path).readAsBytes();
    }
    return await bandColorFor(bytes);
  } catch (_) {
    return null;
  }
});
