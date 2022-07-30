import 'dart:convert';

import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Label {
  String name;
  Color color;

  Label(this.name, this.color);
}

class SelectLabelDialog extends StatefulWidget {
  final double curve;
  SelectLabelDialog({Key? key, required this.curve}) : super(key: key);

  @override
  State<SelectLabelDialog> createState() => _SelectLabelDialogState();
}

class _SelectLabelDialogState extends State<SelectLabelDialog> {
  List<Label> labels = [];
  String selectedLabel = "General";

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

      List<dynamic> decodedMap = jsonDecode(stringStoredLabels);
      List<Label> storedLabels = [];
      decodedMap.forEach((element) {
        String name = element["name"];
        String color = element["color"];
        Label thisLabel = Label(name, stringToColor(color));
        storedLabels.add(thisLabel);
      });
      setState(() {
        labels = storedLabels;
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
                                    selectedLabel = labels[index].name;
                                  })
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                          value: labels[index].name,
                                          groupValue: selectedLabel,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedLabel = value!;
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          width: 15,
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
                                    IconButton(
                                      tooltip: "Edit label",
                                      onPressed: () {
                                        showGeneralDialog(
                                          //! edit label dialog box
                                          context: context,
                                          pageBuilder: (BuildContext context,
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
                                              labelColor: labels[index].color,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.create_rounded,
                                      ),
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
                                      curve: curve, addLabel: addLabel);
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
