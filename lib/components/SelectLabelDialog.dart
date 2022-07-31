import 'dart:convert';

import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectLabelDialog extends StatefulWidget {
  final double curve;
  SelectLabelDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<SelectLabelDialog> createState() => _SelectLabelDialogState();
}

class _SelectLabelDialogState extends State<SelectLabelDialog> {
  List<Label> labels = [];
  int selectedLabel = 0;

  List<Label> extractLabels(String labelsString) {
    List<dynamic> decodedMap = jsonDecode(labelsString);
    List<Label> storedLabels = [];
    decodedMap.forEach((element) {
      String name = element["name"];
      String color = element["color"];
      Label thisLabel = Label(name, stringToColor(color));
      storedLabels.add(thisLabel);
    });
    return storedLabels;
  }

  void addLabel(String labelName, Color labelColor) {
    Label newLabel = Label(labelName, labelColor);
    List<Label> newLabelList = [...labels, newLabel];
    setState(() {
      labels = newLabelList;
    });
    List<Map<String, dynamic>> mapList = [];
    newLabelList.forEach((element) {
      Map<String, dynamic> eachMap = {
        'name': element.name,
        'color': element.color.toString()
      };
      mapList.add(eachMap);
    });
    String labelsJSON = jsonEncode(mapList);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
  }

  void editLabel(String labelName, Color labelColor, int index) {
    Label newLabel = Label(labelName, labelColor);
    List<Label> newLabelList = [...labels];
    newLabelList[index] = newLabel;
    setState(() {
      labels = newLabelList;
    });
    List<Map<String, dynamic>> mapList = [];
    newLabelList.forEach((element) {
      Map<String, dynamic> eachMap = {
        'name': element.name,
        'color': element.color.toString()
      };
      mapList.add(eachMap);
    });
    String labelsJSON = jsonEncode(mapList);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
  }

  void deleteLabel(int labelIndex) {
    if (labelIndex == selectedLabel) {
      setState(() {
        selectedLabel = 0;
      });
    }
    setState(() {
      labels.removeAt(labelIndex);
    });
    List<Map<String, dynamic>> mapList = [];
    labels.forEach((element) {
      Map<String, dynamic> eachMap = {
        'name': element.name,
        'color': element.color.toString()
      };
      mapList.add(eachMap);
    });
    String labelsJSON = jsonEncode(mapList);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      // prefs.clear();
      String stringStoredLabels = prefs.getString('labels') ?? "";
      if (stringStoredLabels == "") {
        Label newLabel = Label("General", Colors.white);
        List<Map<String, dynamic>> mapList = [
          {'name': newLabel.name, 'color': newLabel.color.toString()}
        ];

        String labelsJSON = jsonEncode(mapList);
        prefs.setString('labels', labelsJSON);
        stringStoredLabels = labelsJSON;
      }
      // debugPrint(stringStoredLabels);
      setState(() {
        labels = extractLabels(stringStoredLabels);
      });
    });

    super.initState();
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
                    titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    title: const Text('Select Label'),
                    children: <Widget>[
                      Container(
                        height: screenHeight * 0.4,
                        width: screenWidth * 0.9,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: labels.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () => {
                                  setState(() {
                                    selectedLabel = index;
                                  })
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                          value: index,
                                          groupValue: selectedLabel,
                                          onChanged: (int? value) {
                                            setState(() {
                                              selectedLabel = value!;
                                            });
                                          },
                                        ),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              Color.fromARGB(221, 79, 79, 79),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor:
                                                labels[index].color,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          labels[index].name,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "Edit label",
                                          onPressed: () {
                                            showGeneralDialog(
                                              //! edit label dialog box
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
                                                return AddOrEditLabelDialog(
                                                  curve: curve,
                                                  labelName: labels[index].name,
                                                  labelColor:
                                                      labels[index].color,
                                                  labelIndex: index,
                                                  labels: labels,
                                                  editLabel: editLabel,
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 300),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.create_rounded,
                                            color:
                                                Color.fromARGB(255, 99, 99, 99),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: "Delete tag",
                                          onPressed: labels.length > 1
                                              ? () {
                                                  deleteLabel(index);
                                                }
                                              : () {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Atleast one label required",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                  );
                                                },
                                          icon: const Icon(
                                            Icons.delete,
                                            color:
                                                Color.fromARGB(255, 99, 99, 99),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: "Add new label",
                            onPressed: () {
                              showGeneralDialog(
                                //! add new label dialog box
                                context: context,
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation) {
                                  return Container();
                                },
                                transitionBuilder: (ctx, a1, a2, child) {
                                  var curve =
                                      Curves.easeInOut.transform(a1.value);
                                  return AddOrEditLabelDialog(
                                    curve: curve,
                                    labels: labels,
                                    addLabel: addLabel,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              );
                            },
                            icon: const Icon(
                              Icons.add_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: "Save current label",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.check_rounded),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
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
