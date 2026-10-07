import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Every color, spacing, radius and duration in the app. Values are copied
/// from docs/DESIGN.md; change the spec first, then this file. Nothing else
/// in lib/ may contain a hex color (test/design_guard_test.dart checks).
abstract final class C {
  // Surfaces, three steps plus pressed.
  static const bg0 = Color(0xFF0C0B0A);
  static const bg1 = Color(0xFF141311);
  static const bg2 = Color(0xFF1D1B19);
  static const bg3 = Color(0xFF272522);

  // Lines.
  static const line = Color(0xFF2A2825);
  static const lineStrong = Color(0xFF3D3A36);

  // Text.
  static const textHi = Color(0xFFEDEAE4);
  static const textMid = Color(0xFFA6A29B);
  static const textLow = Color(0xFF6E6A64);
  static const textOff = Color(0xFF47443F);

  // The one accent.
  static const flame = Color(0xFFFF5320);
  static const flamePressed = Color(0xFFE04415);
  static const onFlame = Color(0xFF0C0B0A);

  /// `flame` at 10 % over a surface: background of the playing row only.
  static Color flameWashOver(Color surface) =>
      Color.alphaBlend(flame.withValues(alpha: 0.10), surface);

  static const transparent = Color(0x00000000);

  /// Modal scrim: flat black at 60 %, never blurred.
  static const scrim = Color(0x99000000);

  /// The only shadow color, used under a row while it is being dragged.
  static const dragShadow = Color(0x66000000);
}

/// Spacing scale, 4 px base. Only these values are legal.
abstract final class S {
  static const s0 = 0.0;
  static const s1 = 2.0;
  static const s2 = 4.0;
  static const s3 = 8.0;
  static const s4 = 12.0;
  static const s5 = 16.0;
  static const s6 = 24.0;
  static const s7 = 32.0;
  static const s8 = 48.0;
  static const s9 = 64.0;
  static const s10 = 96.0;
}

/// Fixed layout dimensions.
abstract final class Dim {
  static const rowTight = 28.0;
  static const rowNormal = 32.0;
  static const rowTouch = 48.0;
  static const sidebar = 224.0;
  static const sidebarCollapsed = 56.0;
  static const queuePanel = 336.0;
  static const transport = 72.0;
  static const miniTransport = 56.0;
  static const gutter = S.s6;
  static const gutterMobile = S.s5;
  static const tileArt = 168.0;
  static const tileArtMin = 144.0;
  static const rowArt = 20.0;
  static const rowArtTouch = 40.0;
  static const palette = 560.0;
  static const mobileBreakpoint = 720.0;
  static const hairline = 1.0;
}

/// Radius rules: 0 for surfaces and art, 2 for interactive controls.
abstract final class R {
  static const none = BorderRadius.zero;
  static const control = BorderRadius.all(Radius.circular(2));
}

/// Motion tokens. Nothing over 200 ms, nothing that overshoots.
abstract final class M {
  static const instant = Duration.zero;
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 160);
  static const slow = Duration(milliseconds: 200);

  static const fastCurve = Curves.easeOut;
  static const baseCurve = Curves.easeOutCubic;

  /// Step of the playing-indicator bars (a step, not an animation).
  static const barsStep = Duration(milliseconds: 400);
}

/// Icon sizes.
abstract final class IconSz {
  static const row = 16.0;
  static const nav = 18.0;
  static const transport = 20.0;
  static const nowPlaying = 24.0;
  static const playLarge = 32.0;
}
