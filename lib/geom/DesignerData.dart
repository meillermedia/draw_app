import 'dart:ui' as ui;
import 'package:designer/geom/DesignerShape.dart';

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
