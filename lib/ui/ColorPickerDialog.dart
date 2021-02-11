import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// https://pub.dev/packages/flutter_colorpicker/example

class ColorPickerDialog extends AlertDialog {
  ColorPickerDialog(double width, Color currentColor, colorChanged)
      : super(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: colorChanged,
              colorPickerWidth: width,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(2.0),
                topRight: const Radius.circular(2.0),
              ),
            ),
          ),
        );
}
