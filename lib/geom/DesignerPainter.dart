import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:designer/geom/DesignerData.dart';

enum Mode { pan, zoom, draw }

class DesignerPainter extends CustomPainter {
  final DesignerData data;
  Size currentSize;

  int get width => currentSize.width.floor();
  int get height => currentSize.height.floor();

  DesignerPainter(
    this.data,
  ) {
    currentSize = Size.zero;
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.currentSize = size;
    if (data.image != null) {
      canvas.drawImage(data.image, Offset(0, 0), Paint());
    }
    for (var shape in data.shapes) {
      shape.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
