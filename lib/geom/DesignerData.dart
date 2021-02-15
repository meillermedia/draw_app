import 'package:designer/geom/DesignerShape.dart';
import 'dart:ui' as ui;

class DesignerData {
  ui.Image image;
  final shapes = <DesignerShape>[];
  final redoShapes = <DesignerShape>[];

  DesignerData() {
    init();
  }
  void init() {
    shapes.clear();
    redoShapes.clear();
  }
}
