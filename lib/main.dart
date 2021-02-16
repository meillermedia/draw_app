import 'package:designer/ui/ColorPickerDialog.dart';
import 'package:designer/ui/SliderDialog.dart';
import 'package:designer/geom/DesignerShape.dart';
import 'package:designer/geom/DesignerPainter.dart';
import 'package:designer/geom/DesignerData.dart';
import 'package:flutter/material.dart';
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

double _minScale = 1;
double _maxScale = 4;

class _DesignerState extends State<Designer> {
  DesignerData data;
  DesignerPainter _designerPainter;
  Color currentColor;
  Color undoButtonColor, redoButtonColor;
  double currentWidth;
  Offset _center;
  Mode mode;
  final TransformationController _transContr = TransformationController();

  @override
  void initState() {
    data = DesignerData();
    currentColor = Colors.blue;
    _setRedoButton(false);
    _setUndoButton(false);
    currentWidth = 2;
    _center = Offset.zero;
    mode = Mode.draw;
    _transContr.value = Matrix4.identity();
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
                _center = Offset.zero;
                _transContr.value = Matrix4.identity();
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
      body: InteractiveViewer(
        minScale: _minScale,
        maxScale: _maxScale,
        scaleEnabled: mode == Mode.zoom,
        panEnabled: mode == Mode.pan,
        transformationController: _transContr,
        child: CustomPaint(
          painter: _designerPainter,
          child: GestureDetector(
            child: Container(
              width: size.width,
              height: size.height,
            ),
            behavior: HitTestBehavior.translucent,
             // Single Touch
            onPanDown: (details) {
              switch (mode) {
                case Mode.draw:
                  setState(() {
                    data.shapes.add(
                        DesignerShape(createPaint(currentColor, currentWidth)));
                    data.shapes.last.add(details.localPosition);
                  });
                  break;
                case Mode.pan:
                  break;
                case Mode.zoom:
                  setState(() {
                    _center = details.localPosition;
                  });
                  break;
              }
            },
            onPanUpdate: (details) {
              switch (mode) {
                case Mode.draw:
                  setState(() {
                    data.shapes.last.add(details.localPosition);
                  });
                  break;
                case Mode.pan:
                  setState(() {
                    var sc = details.delta;
                    if (sc.distance > 0.2) {
                      _transContr.value.translate(sc.dx, sc.dy);
                    }
                  });
                  break;
                case Mode.zoom:
                  var val = (details.delta.dx + details.delta.dy) /
                      (_designerPainter.width + _designerPainter.height) *
                      2;
                  setState(() {
                    var scale = _transContr.value.getMaxScaleOnAxis();
                    var newScale = scale + val;
                    if (newScale > scale && newScale < _maxScale ||
                        newScale < scale && newScale > _minScale) {
                      var dx = -_center.dx * val;
                      var dy = -_center.dy * val;
                      _transContr.value.translate(dx, dy);
                      _transContr.value.scale(1.0 + val, 1.0 + val);
                    }
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
          ),
        ),
      ),
    );
  }
}

int getSelectedIndex(Mode mode) {
  int i;
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
