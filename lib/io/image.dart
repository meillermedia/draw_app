import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:designer/io/io.dart';
import 'dart:io';

Future<ui.Image?> getImage() async {
  File? f = await getFilePath();
  if (f == null) return null;
  var bytes = await ui.instantiateImageCodec(f.readAsBytesSync());
  var frm = await bytes.getNextFrame();
  return frm.image;
}

void writeImage(data, width, height) async {
  ui.PictureRecorder recorder = new ui.PictureRecorder();
  Canvas canvas = new Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0.0, 0.0, width + 0.0, height + 0.0),
      Paint()..color = Colors.white);
  if (data.image != null) {
    canvas.drawImage(data.image, Offset(0, 0), Paint());
  }
  for (var shape in data.shapes) {
    shape.draw(canvas);
  }

  var pic = recorder.endRecording();
  var im = await pic.toImage(width, height);
  im.toByteData(format: ui.ImageByteFormat.png).then((bytes) {
    if (bytes != null) {
      var uints = bytes.buffer
          .asUint8List(bytes.offsetInBytes, bytes.buffer.lengthInBytes);
      save(uints);
    }
  });
}
