import 'package:flutter/material.dart';

class SliderDialog extends StatefulWidget {
  /// initial selection for the slider
  final double initialSize, min, max, widgetSize;
  final Function widthChanged;
  SliderDialog(
      this.widgetSize, this.min, this.max, this.initialSize, this.widthChanged,
      {Key key = const ValueKey(0)})
      : super(key: key);

  @override
  _SliderDialogState createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  late double _size;

  @override
  void initState() {
    super.initState();
    _size = widget.initialSize;
  }

  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: const EdgeInsets.all(0.0),
        contentPadding: const EdgeInsets.all(0.0),
        content: SingleChildScrollView(
          child: Slider(
              min: widget.min,
              max: widget.max,
              value: _size,
              onChanged: (val) {
                setState(() {
                  _size = val;
                  widget.widthChanged(_size);
                });
              }),
        ));
  }
}
