import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'drawable.dart';

class CanvasPainter extends CustomPainter {
  final List<Drawable> drawables;
  Drawable? selectedDrawable;

  CanvasPainter({required this.drawables, this.selectedDrawable});

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawable in drawables) {
      drawable.draw(canvas);
    }
    if (selectedDrawable != null) {
      final rect = selectedDrawable!.getBounds();
      final paint = Paint()
        ..color = Color(0xFF0000FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void selectDrawable(Offset position) {
    for (var drawable in drawables) {
      if (drawable.contains(position)) {
        selectedDrawable = drawable;
        break;
      }
    }
  }
}
