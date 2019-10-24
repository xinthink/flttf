import 'package:flttf/constants.dart';
import 'package:flutter/material.dart';

final Paint drawingPaint = Paint()
  ..strokeCap = StrokeCap.square
  ..isAntiAlias = isAntiAlias
  ..color = brushColor
  ..strokeWidth = strokeWidth;

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.offsetPoints});
  final List<Offset> offsetPoints;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < offsetPoints.length - 1; i++) {
      if (offsetPoints[i] != null && offsetPoints[i + 1] != null) {
        canvas.drawLine(offsetPoints[i], offsetPoints[i + 1], drawingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
