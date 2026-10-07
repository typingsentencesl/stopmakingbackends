import 'package:flutter/widgets.dart';

import '../tokens.dart';

/// The one shadow in the app (DESIGN.md §6): 1 px of black under a row while
/// it is being dragged, so it reads as lifted. `design_guard_test` allows
/// `BoxShadow` in this file only.
Widget dragProxy(Widget child, int index, Animation<double> animation) {
  return DecoratedBox(
    decoration: const BoxDecoration(
      color: C.bg3,
      boxShadow: [BoxShadow(color: C.dragShadow, offset: Offset(0, 1))],
    ),
    child: child,
  );
}
