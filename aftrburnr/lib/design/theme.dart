import 'package:flutter/material.dart';

import 'tokens.dart';
import 'type.dart';

/// MaterialApp is used for its plumbing (overlays, text editing, scroll
/// behaviour, localisations). Everything visible is drawn by our own
/// widgets; this theme exists so that no Material default — ripple,
/// elevation, rounded shape, purple tint — can leak through anywhere.
ThemeData buildTheme() {
  const t = AfType.desktop;
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: C.flame,
    onPrimary: C.onFlame,
    secondary: C.textMid,
    onSecondary: C.bg0,
    error: C.textHi,
    onError: C.bg0,
    surface: C.bg0,
    onSurface: C.textHi,
    surfaceContainerLowest: C.bg0,
    surfaceContainerLow: C.bg1,
    surfaceContainer: C.bg1,
    surfaceContainerHigh: C.bg2,
    surfaceContainerHighest: C.bg3,
    onSurfaceVariant: C.textMid,
    outline: C.lineStrong,
    outlineVariant: C.line,
    shadow: C.bg0,
    scrim: C.scrim,
    surfaceTint: C.bg0,
    inverseSurface: C.textHi,
    onInverseSurface: C.bg0,
    inversePrimary: C.flamePressed,
  );
  const shape = RoundedRectangleBorder(borderRadius: R.control);
  final textTheme = TextTheme(
    displayLarge: t.displayXL,
    displayMedium: t.displayL,
    displaySmall: t.displayM,
    headlineLarge: t.displayL,
    headlineMedium: t.displayM,
    headlineSmall: t.displayM,
    titleLarge: t.titleS,
    titleMedium: t.titleS,
    titleSmall: t.bodyStrong,
    bodyLarge: t.body,
    bodyMedium: t.body,
    bodySmall: t.meta,
    labelLarge: t.bodyStrong,
    labelMedium: t.meta,
    labelSmall: t.label,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    fontFamily: AfType.ui,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: C.bg0,
    canvasColor: C.bg0,
    cardColor: C.bg1,
    dividerColor: C.line,
    disabledColor: C.textOff,
    hintColor: C.textLow,
    focusColor: C.transparent,
    hoverColor: C.transparent,
    highlightColor: C.transparent,
    splashColor: C.transparent,
    splashFactory: NoSplash.splashFactory,
    shadowColor: C.transparent,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    iconTheme: const IconThemeData(color: C.textMid, size: IconSz.row),
    dividerTheme: const DividerThemeData(
      color: C.line,
      thickness: Dim.hairline,
      space: Dim.hairline,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: C.textHi,
      selectionColor: C.flame.withValues(alpha: 0.35),
      selectionHandleColor: C.flame,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(6),
      radius: Radius.zero,
      thumbColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.hovered) || s.contains(WidgetState.dragged)
            ? C.lineStrong
            : C.bg3,
      ),
      trackColor: const WidgetStatePropertyAll(C.transparent),
      crossAxisMargin: 0,
      mainAxisMargin: 0,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: C.bg2,
        borderRadius: R.control,
        border: Border.all(color: C.lineStrong),
      ),
      textStyle: t.meta.copyWith(color: C.textHi),
      padding: const EdgeInsets.symmetric(horizontal: S.s3, vertical: S.s2),
      waitDuration: const Duration(milliseconds: 600),
      exitDuration: M.instant,
      preferBelow: false,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: C.bg2,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: R.control,
        side: BorderSide(color: C.lineStrong),
      ),
      textStyle: t.body,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: C.bg1,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: R.none,
        side: BorderSide(color: C.line),
      ),
      barrierColor: C.scrim,
      titleTextStyle: t.titleS,
      contentTextStyle: t.body,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: C.bg2,
      hintStyle: t.body.copyWith(color: C.textLow),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: S.s3,
        vertical: S.s3,
      ),
      border: const OutlineInputBorder(
        borderRadius: R.control,
        borderSide: BorderSide(color: C.line),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: R.control,
        borderSide: BorderSide(color: C.line),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: R.control,
        borderSide: BorderSide(color: C.textHi),
      ),
      hoverColor: C.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.bg2,
      contentTextStyle: t.body,
      elevation: 0,
      shape: shape,
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: C.flame,
      linearTrackColor: C.lineStrong,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: _FadeTransitions(),
        TargetPlatform.linux: _FadeTransitions(),
        TargetPlatform.macOS: _FadeTransitions(),
        TargetPlatform.android: _FadeTransitions(),
        TargetPlatform.iOS: _FadeTransitions(),
      },
    ),
  );
}

/// Routes fade in over `M.base` with a 8 px rise; no zoom, no slide-over.
class _FadeTransitions extends PageTransitionsBuilder {
  const _FadeTransitions();

  @override
  Duration get transitionDuration => M.base;

  @override
  Duration get reverseTransitionDuration => M.base;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final a = CurvedAnimation(parent: animation, curve: M.baseCurve);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.01),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
  }
}
