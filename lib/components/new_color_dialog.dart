import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NewColorDialog extends StatefulWidget {
  final double curve;
  final handleNewColor;
  const NewColorDialog(
      {Key? key, required this.curve, required this.handleNewColor})
      : super(key: key);

  @override
  State<NewColorDialog> createState() => _NewColorDialogState();
}

class _NewColorDialogState extends State<NewColorDialog> {
  Color newSelectedColor = Colors.white;

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
                        pickerColor: newSelectedColor, //default color
                        onColorChanged: (Color color) {
                          setState(() {
                            newSelectedColor = color;
                          });
                        },
                      ),
                      TextButton(
                          onPressed: () {
                            debugPrint("picked color" +
                                newSelectedColor.toString() +
                                " ");
                            widget.handleNewColor(newSelectedColor);
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
