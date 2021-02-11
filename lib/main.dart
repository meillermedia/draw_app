import 'package:designer/ui/ColorPickerDialog.dart';
import 'package:designer/ui/SliderDialog.dart';
import 'package:designer/geom/DesignerShape.dart';
import 'package:flutter/material.dart';
import 'package:designer/geom/DesignerPainter.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:designer/geom/DesignerData.dart';
import 'package:designer/io/image.dart';

void main() => runApp(Painter());

class Painter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, title: "Designer", home: Designer());
  }
}

class Designer extends StatefulWidget {
  @override
  _DesignerState createState() => _DesignerState();
}

class _DesignerState extends State<Designer> {
  DesignerData data;
  DesignerPainter _designerPainter;
  Color currentColor;
  Color undoButtonColor, redoButtonColor;
  double currentWidth;

  Offset _panValue;
  Offset _center;
  double _scaleValue;
  Matrix4 _matrix;
  Mode mode = Mode.draw;

  @override
  void initState() {
    data = DesignerData();
    currentColor = Colors.blue;
    _setRedoButton(false);
    _setUndoButton(false);
    currentWidth = 2;

    _panValue = Offset.zero;
    _center = Offset.zero;
    _scaleValue = 1;
    _matrix = Matrix4.identity();
    super.initState();
  }

  double _getDialogWidth(BuildContext context) {
    double wh = MediaQuery.of(context).size.width;
    if (wh > 600) wh = 600;
    return wh;
  }

  _setRedoButton(onoff) {
    if (onoff) {
      setState(() => redoButtonColor = Colors.blue);
    } else {
      setState(() => redoButtonColor = Colors.black38);
    }
  }

  _setUndoButton(onoff) {
    if (onoff) {
      setState(() => undoButtonColor = Colors.blue);
    } else {
      setState(() => undoButtonColor = Colors.black38);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    _designerPainter = DesignerPainter(data);
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 15,
        unselectedFontSize: 5,
        currentIndex: getSelectedIndex(mode),
        onTap: (value) {
          switch (value) {
            case 0:
              setState(() {
                _panValue = Offset.zero;
                _center = Offset.zero;
                _scaleValue = 1;
                _matrix = Matrix4.identity();
              });
              break;
            case 1:
              setState(() => mode = Mode.pan);
              break;
            case 2:
              setState(() => mode = Mode.zoom);
              break;
            case 3:
              setState(() => mode = Mode.draw);
              break;
            case 4:
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ColorPickerDialog(
                      _getDialogWidth(context),
                      currentColor,
                      (color) => setState(() => currentColor = color));
                },
              );
              break;
            case 5:
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SliderDialog(
                      _getDialogWidth(context),
                      1,
                      300,
                      currentWidth,
                      (width) => setState(() => currentWidth = width));
                },
              );
              break;
            // Undo- Redo!
            case 6:
              if (data.shapes.isNotEmpty) {
                data.redoShapes.add(data.shapes.removeLast());
              }
              if (data.shapes.isNotEmpty) {
                _setRedoButton(true);
              } else {
                _setUndoButton(false);
              }
              break;
            case 7:
              if (data.redoShapes.isNotEmpty) {
                data.shapes.add(data.redoShapes.removeLast());
              }
              if (data.redoShapes.isNotEmpty) {
                _setUndoButton(true);
              } else {
                _setRedoButton(false);
              }
              break;
            case 8:
              getImage().then((value) {
                if (value != null) {
                  setState(() {
                    data.image = value;
                  });
                }
              });
              break;
            case 9:
              writeImage(data, _designerPainter.width, _designerPainter.height);
              break;
            default:
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.pan_tool_outlined), label: "Pan Image"),
          BottomNavigationBarItem(
              icon: Icon(Icons.zoom_in_outlined), label: "Zoom Image"),
          BottomNavigationBarItem(
              icon: Icon(Icons.brush_outlined), label: "Draw"),
          BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: "Color"),
          BottomNavigationBarItem(
              icon: Icon(Icons.circle), label: "Brush Size"),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.undo,
              color: undoButtonColor,
            ),
            label: "Undo",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.redo,
                color: redoButtonColor,
              ),
              label: "Redo"),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: "Load Image"),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_download), label: "Save Image"),
        ],
      ),
      body: GestureDetector(
        // Single Touch
        behavior: HitTestBehavior.translucent,
        onPanDown: (details) {
          switch (mode) {
            case Mode.draw:
              setState(() {
                data.shapes.add(
                    DesignerShape(createPaint(currentColor, currentWidth)));
                data.shapes.last.add(
                    _trans(details.localPosition, _matrix));
              });
              break;
            case Mode.pan:
              break;
            case Mode.zoom:
              setState(() {
                _center = details.globalPosition;
              });
              break;
          }
        },
        onPanUpdate: (details) {
          switch (mode) {
            case Mode.draw:
              setState(() {
                data.shapes.last.add(
                    _trans(details.localPosition, _matrix));
              });
              break;
            case Mode.pan:
              setState(() {
                var sc = details.delta / _scaleValue;
                if (sc.distance > 0.2) {
                  _panValue += sc;
                  _matrix.translate(sc.dx, sc.dy);
                }
              });
              break;
            case Mode.zoom:
              var val = (details.delta.dx + details.delta.dy) /
                  (_designerPainter.width + _designerPainter.height) *
                  2;
              setState(() {
                _scaleValue += val;

                var dx = -_center.dx * val;
                var dy = -_center.dy * val;

                print(_center.dx - size.width);
                _matrix.translate(dx, dy);
                _matrix.scale(1.0 + val, 1.0 + val);
              });
              break;
          }
        },
        onPanEnd: (details) {
          switch (mode) {
            case Mode.draw:
              setState(() => data.redoShapes.clear());
              _setRedoButton(false);
              _setUndoButton(true);
              break;
            case Mode.pan:
              break;
            case Mode.zoom:
              break;
          }
        },
        child: Transform(
          transform: _matrix,
          //origin: Offset(size.width / 2, size.height / 2),
          //alignment: Alignment.center,
          child: CustomPaint(
            painter: _designerPainter,
            child: Container(
              width: size.width,
              height: size.height,
            ),
          ),
        ),
      ),
    );
  }
}

Offset _trans(Offset p, Matrix4 m) {
  Vector3 v = Vector3(p.dx, p.dy, 0);
  Matrix4 m2 = Matrix4.copy(m);
  m2.invert();
  Vector3 lp = m2 * v;
  return Offset(lp.x, lp.y);
}

Widget buildButton(Icon icon, {double margin = 5, Function onPressed}) {
  return Container(
    margin: EdgeInsets.all(margin),
    child: MaterialButton(
      shape: CircleBorder(),
      elevation: 0.0,
      hoverElevation: 0.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      color: Colors.blue,
      onPressed: onPressed,
      child: icon,
    ),
  );
}

int getSelectedIndex(Mode mode) {
  int i = 3;
  switch (mode) {
    case Mode.pan:
      i = 1;
      break;
    case Mode.zoom:
      i = 2;
      break;
    case Mode.draw:
      i = 3;
      break;
  }
  return i;
}
