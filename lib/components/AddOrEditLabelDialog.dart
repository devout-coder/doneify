import 'package:conquer_flutter_app/components/NewColorDialog.dart';
import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/material.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddOrEditLabelDialog extends StatefulWidget {
  final double curve;
  String? labelName;
  Color? labelColor;
  int? labelIndex;
  final addLabel;
  final editLabel;
  List<Label> labels;

  AddOrEditLabelDialog({
    Key? key,
    required this.curve,
    this.labelName,
    this.labelColor,
    this.labelIndex,
    this.addLabel,
    this.editLabel,
    required this.labels,
  }) : super(key: key);

  @override
  State<AddOrEditLabelDialog> createState() => _AddOrEditLabelDialogState();
}

Color stringToColor(String strColor) {
  String colorString = strColor.toString(); // Color(0x12345678)
  String valueString =
      colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
  int value = int.parse(valueString, radix: 16);
  Color color = Color(value);
  return color;
}

class _AddOrEditLabelDialogState extends State<AddOrEditLabelDialog> {
  final tagName = TextEditingController();

  Color? selectedColor;

  List<Color> displayedColors = [];

  void changeColor(Color color) => setState(() => selectedColor = color);

  bool labelPresent(String name, Color color) {
    bool present = false;
    for (int i = 0; i < widget.labels.length; i++) {
      if ((i != widget.labelIndex && widget.labels[i].name == name) ||
          (i != widget.labelIndex &&
              widget.labels[i].color == color.toString())) {
        present = true;
      }
    }
    return present;
  }

  void handleNewColor(Color newColor) {
    //add a new color to the palette and storage as well
    if (!displayedColors.contains(newColor)) {
      List<Color> newCols = [...displayedColors, newColor];
      setState(() {
        displayedColors = newCols;
      });
      List<String> stringCols = newCols.map((e) => e.toString()).toList();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList("label_colors", stringCols);
      });
    }
  }

  void saveLabel() {
    if (!labelPresent(tagName.text, selectedColor!)) {
      if (widget.addLabel != null) {
        widget.addLabel(tagName.text, selectedColor);
      } else {
        widget.editLabel(tagName.text, selectedColor, widget.labelIndex);
      }
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: "Name or color matches with previous label",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void initState() {
    tagName.text = widget.labelName != null ? widget.labelName! : "";
    setState(() {
      selectedColor = widget.labelColor != null ? widget.labelColor! : null;
    });

    SharedPreferences.getInstance().then((prefs) {
      List<String> storedColors = prefs.getStringList('label_colors') ?? [];
      // debugPrint("stored colors first" + storedColors.toString());
      if (storedColors.isEmpty) {
        List<String> colors = [
          Colors.yellow.toString(),
          Colors.green.toString(),
          Colors.red.toString(),
          Colors.blue.toString(),
          Colors.white.toString(),
        ];
        prefs.setStringList("label_colors", colors);
        storedColors = colors;
        // debugPrint("stored colors after setting: " + storedColors.toString());
      }
      setState(() {
        displayedColors =
            storedColors.map((color) => stringToColor(color)).toList();
      });
      // debugPrint("stored colors at last: " + storedColors.toString());
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    tagName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
                    title: TextFormField(
                      //! tag name text field
                      controller: tagName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Tag Name",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                    children: <Widget>[
                      Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.3,
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: GridView.builder(
                          itemCount: displayedColors.length + 1,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                changeColor(displayedColors[index]);
                              },
                              child: (selectedColor != null &&
                                      index ==
                                          displayedColors
                                              .indexOf(selectedColor!))
                                  ? CircleAvatar(
                                      radius: 27,
                                      backgroundColor:
                                          Color.fromARGB(221, 50, 50, 50),
                                      child: CircleAvatar(
                                        backgroundColor: displayedColors[index],
                                        radius: 19,
                                      ),
                                    )
                                  : index != displayedColors.length
                                      ? CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black54,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                displayedColors[index],
                                            radius: 21,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            onPressed: () {
                                              showGeneralDialog(
                                                //! new color dialog box
                                                context: context,
                                                pageBuilder: (BuildContext
                                                        context,
                                                    Animation<double> animation,
                                                    Animation<double>
                                                        secondaryAnimation) {
                                                  return Container();
                                                },
                                                transitionBuilder:
                                                    (ctx, a1, a2, child) {
                                                  var curve = Curves.easeInOut
                                                      .transform(a1.value);
                                                  return NewColorDialog(
                                                      curve: curve,
                                                      handleNewColor:
                                                          handleNewColor);
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 300),
                                              );
                                            },
                                            tooltip: "Add new color",
                                            icon: const Icon(
                                              Icons.add,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: "Save changes",
                        onPressed: tagName.text != "" &&
                                selectedColor != null &&
                                (widget.labelName != tagName.text ||
                                    widget.labelColor != selectedColor)
                            ? () {
                                saveLabel();
                              }
                            : null,
                        icon: const Icon(Icons.check_rounded),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          debugPrint("back pressed now in edit label dialog");
          return true;
        });
  }
}
