import 'package:flutter/material.dart';
import 'dart:ui';

Paint createPaint(Color color, double thickness) {
  return Paint()
    ..strokeWidth = thickness
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
}

class DesignerShape {
  List<Offset> _points;
  Paint _paint;

  DesignerShape(Paint paint) {
    _points = <Offset>[];
    _paint = paint;
  }

  void add(Offset p) {
    _points.add(p);
  }

  void draw(Canvas canvas) {
    if (_points.length > 0) {
      Path p = Path();
      p.moveTo(_points[0].dx, _points[0].dy);
      for (int i = 1; i < _points.length; i++) {
        p.lineTo(_points[i].dx, _points[i].dy);
      }
      canvas.drawPath(p, _paint);
    }
  }
}
