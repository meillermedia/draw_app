import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> getFilePath() async {
  print("Start");
  var fp = await FilePicker.platform.pickFiles(type: FileType.image);
  print("End");
  if (fp != null && fp.paths.length > 0) {
    var path = fp.paths.first;
    if (path != null) {
      return File(path);
    } else {
      return null;
    }
  } else {
    return null;
  }
}

void save(Uint8List data) async {
  var fp = await FilePicker.platform.saveFile(type: FileType.image);
  if (fp != null) {
    var f = await File(fp);
    await f.writeAsBytes(data);
  }
}
