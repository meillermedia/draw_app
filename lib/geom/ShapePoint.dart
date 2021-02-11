import 'package:flutter/material.dart';

enum PointCmd { M, L, C }

class ShapePoint {
  Offset offset;
  PointCmd cmd;
  String get command {
    switch (cmd) {
      case PointCmd.M:
        return "M";
        break;
      case PointCmd.L:
        return "L";
        break;
      case PointCmd.C:
        return "C";
        break;
      default:
        return "M";
    }
  }

  ShapePoint(this.offset, this.cmd);
}

class CubicPoint extends ShapePoint {
  Offset p1, p2;
  CubicPoint(o, this.p1, this.p2) : super(o, PointCmd.C);
}
