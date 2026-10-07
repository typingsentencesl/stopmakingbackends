import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Type scale from docs/DESIGN.md §2. Line heights are absolute, so each
/// style sets `height` = line / size.
class AfType {
  const AfType._();

  static const desktop = AfType._();

  static const display = 'Archivo XC';
  static const ui = 'IBM Plex Sans';
  static const _tnum = [FontFeature.tabularFigures()];

  static TextStyle _s(
    String family,
    FontWeight w,
    double size,
    double line, {
    double trackingPct = 0,
    Color color = C.textHi,
    bool tnum = false,
  }) => TextStyle(
    fontFamily: family,
    fontWeight: w,
    fontSize: size,
    height: line / size,
    letterSpacing: size * trackingPct / 100,
    color: color,
    fontFeatures: tnum ? _tnum : null,
    leadingDistribution: TextLeadingDistribution.even,
  );

  TextStyle get hero => _s(display, FontWeight.w800, 72, 72, trackingPct: -1);
  TextStyle get displayL =>
      _s(display, FontWeight.w800, 40, 44, trackingPct: -0.5);
  TextStyle get displayM => _s(display, FontWeight.w700, 24, 28);
  TextStyle get section => _s(ui, FontWeight.w600, 16, 22);
  TextStyle get titleS => _s(ui, FontWeight.w600, 14, 20);
  TextStyle get rowTitle => _s(ui, FontWeight.w500, 15, 20);
  TextStyle get body => _s(ui, FontWeight.w400, 14, 20);
  TextStyle get bodyStrong => _s(ui, FontWeight.w500, 14, 20);
  TextStyle get meta => _s(ui, FontWeight.w400, 13, 18, color: C.textMid);
  TextStyle get metaS => _s(ui, FontWeight.w400, 12, 16, color: C.textMid);

  /// Uppercase is applied by the caller (`text.toUpperCase()`), since
  /// TextStyle has no text-transform.
  TextStyle get label =>
      _s(ui, FontWeight.w500, 11, 14, trackingPct: 6, color: C.textLow);
  TextStyle get num =>
      _s(ui, FontWeight.w400, 14, 20, color: C.textMid, tnum: true);
  TextStyle get numS =>
      _s(ui, FontWeight.w400, 12, 16, color: C.textMid, tnum: true);
  TextStyle get numXL => _s(display, FontWeight.w700, 56, 56, tnum: true);
}
