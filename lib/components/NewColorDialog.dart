import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NewColorDialog extends StatefulWidget {
  final double curve;
  NewColorDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<NewColorDialog> createState() => _NewColorDialogState();
}

class _NewColorDialogState extends State<NewColorDialog> {
  Color selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Transform.scale(
          scale: widget.curve,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SimpleDialog(
                    contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                    titlePadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    children: [
                      ColorPicker(
                        pickerColor: selectedColor, //default color
                        onColorChanged: (Color color) {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            print("picked color" +
                                selectedColor.toString() +
                                " ");
                            Navigator.pop(context);
                          },
                          child: const Text("Save Color")),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        onWillPop: () async {
          debugPrint("back pressed now in add label dialog");
          return true;
        });
  }
}
