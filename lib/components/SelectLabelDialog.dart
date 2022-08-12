import 'dart:convert';

import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectLabelDialog extends StatefulWidget {
  final double curve;
  int selectedLabel;
  final Function updateSelectedLabel;
  SelectLabelDialog({
    Key? key,
    required this.curve,
    required this.selectedLabel,
    required this.updateSelectedLabel,
  }) : super(key: key);

  @override
  State<SelectLabelDialog> createState() => _SelectLabelDialogState();
}

List<Map<String, dynamic>> stringifyLabels(List<Label> labels) {
  List<Map<String, dynamic>> jsonLabels = [];
  labels.forEach((label) {
    Map<String, dynamic> jsonLabel = {
      "name": label.name,
      "color": label.color.toString(),
    };
    jsonLabels.add(jsonLabel);
  });
  return jsonLabels;
}

class _SelectLabelDialogState extends State<SelectLabelDialog> {
  int? selectedLabel;

  LabelDB labelsDB = GetIt.I.get();

  @override
  void initState() {
    selectedLabel = widget.selectedLabel;
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
                            itemCount: labelsDB.labels.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  widget.updateSelectedLabel(index);
                                  setState(() {
                                    selectedLabel = index;
                                  });
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
                                            // widget.updateSelectedLabel(value!);
                                            widget.updateSelectedLabel(index);
                                            setState(() {
                                              selectedLabel = value;
                                            });
                                          },
                                        ),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              Color.fromARGB(221, 79, 79, 79),
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: stringToColor(
                                                labelsDB.labels[index].color),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          labelsDB.labels[index].name,
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
                                                  labelIndex: index,
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
                                          onPressed: labelsDB.labels.length > 1
                                              ? () {
                                                  if (index == selectedLabel) {
                                                    widget
                                                        .updateSelectedLabel(0);
                                                    setState(() {
                                                      selectedLabel = 0;
                                                    });
                                                  }
                                                  labelsDB.deleteLabel(index);
                                                  setState(() {});
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
