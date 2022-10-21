import 'package:conquer_flutter_app/components/NewColorDialog.dart';
import 'package:conquer_flutter_app/states/labelsAPI.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddOrEditLabelDialog extends StatefulWidget {
  final double curve;
  int? labelIndex;

  AddOrEditLabelDialog({
    Key? key,
    required this.curve,
    this.labelIndex,
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

  int? labelIndex;

  LabelAPI labelsDB = GetIt.I.get();

  List<Color> displayedColors = [];

  // void changeColor(Color color) => setState(() => selectedColor = color);
  void changeColor(Color color) {
    // debugPrint(displayedColors.toString());
    // displayedColors.forEach((element) {
    //   debugPrint(element.toString());
    // });
    // debugPrint(color.toString());
    setState(() {
      selectedColor = color;
    });
    // debugPrint(displayedColors.indexOf(selectedColor!).toString());
  }

  bool labelPresent(String name, Color color) {
    bool present = false;
    for (int i = 0; i < labelsDB.labels.length; i++) {
      if ((i != labelIndex && labelsDB.labels[i].name == name) ||
          (i != labelIndex && labelsDB.labels[i].color == color.toString())) {
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
      if (widget.labelIndex != null) {
        debugPrint("label has been edited");
        labelsDB.editLabel(tagName.text, selectedColor!, labelIndex!);
      } else {
        labelsDB.addLabel(tagName.text, selectedColor!);
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

  void fetchColorsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
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
  }

  @override
  void initState() {
    setState(() {
      labelIndex = widget.labelIndex != null
          ? widget.labelIndex!
          : labelsDB.labels.length;
    });
    tagName.text =
        widget.labelIndex != null ? labelsDB.labels[labelIndex!].name : "";
    setState(() {
      selectedColor = widget.labelIndex != null
          ? stringToColor(labelsDB.labels[labelIndex!].color)
          : null;
    });

    fetchColorsFromStorage();

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
                                      //! the selected color
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
                                          //!all the normal colors
                                          radius: 20,
                                          backgroundColor: Colors.black54,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                displayedColors[index],
                                            radius: 21,
                                          ),
                                        )
                                      : CircleAvatar(
                                          //!the add button
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
                        // onPressed: tagName.text != "" &&
                        //         selectedColor != null &&
                        //         (labelsDB.labels[labelIndex!].name !=
                        //                 tagName.text ||
                        //             stringToColor(labelsDB
                        //                     .labels[labelIndex!].color) !=
                        //                 selectedColor)
                        //     ? () {
                        //         saveLabel();
                        //       }
                        //     : null,
                        onPressed: tagName.text != "" && selectedColor != null
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
