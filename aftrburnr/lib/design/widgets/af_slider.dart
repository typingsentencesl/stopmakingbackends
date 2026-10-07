import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Progress and volume bar: 4 px pill track, `textHi` fill at rest that
/// turns flame with a 12 px round thumb while hovered, dragged or focused.
class AfSlider extends StatefulWidget {
  const AfSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.height = 16,
    this.step = 0.05,
    this.semanticLabel,
  });

  /// 0–1.
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double height;

  /// Keyboard step when focused.
  final double step;
  final String? semanticLabel;

  @override
  State<AfSlider> createState() => _AfSliderState();
}

class _AfSliderState extends State<AfSlider> {
  bool _hover = false;
  bool _focus = false;
  double? _drag;

  bool get _enabled => widget.onChanged != null;

  double _at(Offset local, double width) =>
      width <= 0 ? 0 : (local.dx / width).clamp(0.0, 1.0);

  void _nudge(double d) {
    final v = (widget.value + d).clamp(0.0, 1.0);
    widget.onChanged?.call(v);
    widget.onChangeEnd?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final v = (_drag ?? widget.value).clamp(0.0, 1.0);
    final hot = _enabled && (_hover || _drag != null || _focus);
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: '${(v * 100).round()}%',
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (h) => setState(() => _hover = h),
        onShowFocusHighlight: (f) => setState(() => _focus = f),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowRight): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _NudgeIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _NudgeIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _NudgeIntent(-1),
        },
        actions: {
          _NudgeIntent: CallbackAction<_NudgeIntent>(
            onInvoke: (i) => _nudge(widget.step * i.dir),
          ),
        },
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _enabled
                  ? (d) {
                      final x = _at(d.localPosition, w);
                      widget.onChanged?.call(x);
                      widget.onChangeEnd?.call(x);
                    }
                  : null,
              onHorizontalDragStart: _enabled
                  ? (d) => setState(() => _drag = _at(d.localPosition, w))
                  : null,
              onHorizontalDragUpdate: _enabled
                  ? (d) {
                      setState(() => _drag = _at(d.localPosition, w));
                      widget.onChanged?.call(_drag!);
                    }
                  : null,
              onHorizontalDragEnd: _enabled
                  ? (_) {
                      final x = _drag;
                      setState(() => _drag = null);
                      if (x != null) widget.onChangeEnd?.call(x);
                    }
                  : null,
              child: SizedBox(
                height: widget.height,
                width: w,
                child: CustomPaint(
                  painter: _SliderPainter(
                    value: v,
                    hot: hot,
                    focused: _focus,
                    enabled: _enabled,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NudgeIntent extends Intent {
  const _NudgeIntent(this.dir);
  final int dir;
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.value,
    required this.hot,
    required this.focused,
    required this.enabled,
  });

  final double value;
  final bool hot;
  final bool focused;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    const h = Dim.progressTrack;
    final y = (size.height - h) / 2;
    final x = size.width * value;
    const pill = Radius.circular(999);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, y, size.width, h), pill),
      Paint()..color = C.lineStrong,
    );
    if (x > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, y, x, h), pill),
        Paint()
          ..color = !enabled
              ? C.textOff
              : hot
              ? C.flame
              : C.textHi,
      );
    }
    if (hot) {
      final c = Offset(
        x.clamp(Dim.progressThumb / 2, size.width - Dim.progressThumb / 2),
        size.height / 2,
      );
      canvas.drawCircle(c, Dim.progressThumb / 2, Paint()..color = C.textHi);
      if (focused) {
        canvas.drawCircle(
          c,
          Dim.progressThumb / 2 + 2,
          Paint()
            ..color = C.textHi
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SliderPainter o) =>
      o.value != value ||
      o.hot != hot ||
      o.focused != focused ||
      o.enabled != enabled;
}
