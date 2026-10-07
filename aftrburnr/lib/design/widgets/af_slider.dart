import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Hairline track, flame fill, 8 px square thumb that appears on hover,
/// drag or focus. Used for progress and volume.
class AfSlider extends StatefulWidget {
  const AfSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.height = 16,
    this.step = 0.05,
    this.semanticLabel,
    this.fill = C.flame,
  });

  /// 0–1.
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double height;

  /// Keyboard step when focused.
  final double step;
  final String? semanticLabel;
  final Color fill;

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
    final showThumb = _enabled && (_hover || _drag != null || _focus);
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
                    thumb: showThumb,
                    focused: _focus,
                    fill: _enabled ? widget.fill : C.textOff,
                    thick: _hover || _drag != null,
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
    required this.thumb,
    required this.focused,
    required this.fill,
    required this.thick,
  });

  final double value;
  final bool thumb;
  final bool focused;
  final Color fill;
  final bool thick;

  @override
  void paint(Canvas canvas, Size size) {
    final h = thick ? 3.0 : 2.0;
    final y = (size.height - h) / 2;
    final x = size.width * value;
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, h),
      Paint()..color = C.lineStrong,
    );
    canvas.drawRect(Rect.fromLTWH(0, y, x, h), Paint()..color = fill);
    if (thumb) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x.clamp(4, size.width - 4), size.height / 2),
          width: 8,
          height: 8,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, Paint()..color = C.textHi);
      if (focused) {
        canvas.drawRRect(
          r.inflate(2),
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
      o.thumb != thumb ||
      o.focused != focused ||
      o.fill != fill ||
      o.thick != thick;
}
