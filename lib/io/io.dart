import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker_cross/file_picker_cross.dart';

Future<File> getFilePath() async {
  var fp = await FilePickerCross.importFromStorage(type: FileTypeCross.image);
  return File(fp.path);
}

void save(Uint8List data) {
  try {
    var fp = FilePickerCross(data,
        path: "./", type: FileTypeCross.image, fileExtension: "svg");
    fp.exportToStorage().then((value) => print("Write File: $value"));
  } on FileSystemException {
    print("Error while Saving.");
  }
}
