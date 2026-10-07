import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Type scale from docs/DESIGN.md §2. Line heights are absolute, so each
/// style sets `height` = line / size.
class AfType {
  const AfType._({required this.mobile});

  final bool mobile;

  static const desktop = AfType._(mobile: false);
  static const touch = AfType._(mobile: true);

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

  TextStyle get displayXL => mobile
      ? _s(display, FontWeight.w800, 40, 38, trackingPct: -0.5)
      : _s(display, FontWeight.w800, 64, 60, trackingPct: -0.5);
  TextStyle get displayL => mobile
      ? _s(display, FontWeight.w800, 32, 32, trackingPct: -0.5)
      : _s(display, FontWeight.w800, 44, 44, trackingPct: -0.5);
  TextStyle get displayM => mobile
      ? _s(display, FontWeight.w700, 22, 26)
      : _s(display, FontWeight.w700, 24, 28);
  TextStyle get titleS => mobile
      ? _s(ui, FontWeight.w600, 16, 22)
      : _s(ui, FontWeight.w600, 14, 20);
  TextStyle get body => mobile
      ? _s(ui, FontWeight.w400, 15, 20)
      : _s(ui, FontWeight.w400, 13, 18);
  TextStyle get bodyStrong => mobile
      ? _s(ui, FontWeight.w500, 15, 20)
      : _s(ui, FontWeight.w500, 13, 18);
  TextStyle get meta => mobile
      ? _s(ui, FontWeight.w400, 13, 18, color: C.textMid)
      : _s(ui, FontWeight.w400, 12, 16, color: C.textMid);

  /// Uppercase is applied by the caller (`text.toUpperCase()`), since
  /// TextStyle has no text-transform.
  TextStyle get label =>
      _s(ui, FontWeight.w500, 11, 14, trackingPct: 6, color: C.textLow);
  TextStyle get num => mobile
      ? _s(ui, FontWeight.w400, 15, 20, color: C.textMid, tnum: true)
      : _s(ui, FontWeight.w400, 13, 18, color: C.textMid, tnum: true);
  TextStyle get numS =>
      _s(ui, FontWeight.w400, 12, 16, color: C.textMid, tnum: true);
  TextStyle get numXL => mobile
      ? _s(display, FontWeight.w700, 40, 40, tnum: true)
      : _s(display, FontWeight.w700, 56, 56, tnum: true);
}
