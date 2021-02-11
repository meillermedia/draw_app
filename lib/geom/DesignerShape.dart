import 'dart:ui';
import 'package:designer/geom/ShapePoint.dart';
import 'package:flutter/material.dart';

Paint createPaint(Color color, double thickness) {
  return Paint()
    ..strokeWidth = thickness
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
}

class DesignerShape {
  List<ShapePoint> _points;
  Paint _paint;

  DesignerShape(Paint paint) {
    _points = <ShapePoint>[];
    _paint = paint;
  }

  void add(ShapePoint p) {
    _points.add(p);
  }

  void draw(Canvas canvas) {
    if (_points.length > 0) {
      Path p = Path();
      // First always M
      p.moveTo(_points[0].offset.dx, _points[0].offset.dy);
      for (int i = 1; i < _points.length; i++) {
        var pnt = _points[i];
        switch (pnt.cmd) {
          case PointCmd.M:
            p.moveTo(pnt.offset.dx, pnt.offset.dy);
            break;
          case PointCmd.L:
            p.lineTo(pnt.offset.dx, pnt.offset.dy);
            break;
          case PointCmd.C:
            if (pnt is CubicPoint) {
              p.cubicTo(pnt.offset.dx, pnt.offset.dy, pnt.p1.dx, pnt.p1.dy,
                  pnt.p2.dx, pnt.p2.dy);
            }
            break;
        }
      }

      canvas.drawPath(p, _paint);
    }
  }

  List<ShapePoint> get offsets => _points;

  Paint get paint => _paint;
}
