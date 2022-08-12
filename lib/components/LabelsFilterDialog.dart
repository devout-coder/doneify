import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedLabelsFilter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class LabelsFilterDialog extends StatefulWidget {
  final double curve;
  final reloadTodos;

  LabelsFilterDialog({
    Key? key,
    required this.curve,
    required this.reloadTodos,
  }) : super(key: key);

  @override
  State<LabelsFilterDialog> createState() => _LabelsFilterDialogState();
}

class _LabelsFilterDialogState extends State<LabelsFilterDialog> {
  LabelDB labelsDB = GetIt.I.get();
  SelectedLabel selectedLabelsClass = GetIt.I.get();

  Map<String, bool> labelsSelectedVal = {};

  void setLabelsVal() {
    Map<String, bool> labelsSelectedValTemp = {};

    labelsDB.labels.forEach((element) {
      labelsSelectedValTemp[element.name] =
          selectedLabelsClass.selectedLabels.contains(element.name);
    });
    setState(() {
      labelsSelectedVal = labelsSelectedValTemp;
    });
  }

  Future<bool> saveSelectedLabels() async {
    List<String> newLabels = [];
    labelsSelectedVal.forEach((key, value) {
      if (value) {
        newLabels.add(key);
      }
    });
    if (newLabels.isNotEmpty) {
      selectedLabelsClass.addLabels(newLabels);
      // await widget.reloadTodos();
      return true;
    } else {
      Fluttertoast.showToast(
        msg: "Atleast one label required",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
  }

  @override
  void initState() {
    setLabelsVal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return saveSelectedLabels();
      },
      child: Transform.scale(
        scale: widget.curve,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SimpleDialog(
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                  titlePadding: EdgeInsets.fromLTRB(20, 20, 10, 0),
                  title: const Text('Choose Labels'),
                  children: <Widget>[
                    Container(
                      height: screenHeight * 0.4,
                      width: screenWidth * 0.9,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: labelsDB.labels.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  labelsSelectedVal[
                                          labelsDB.labels[index].name] =
                                      !labelsSelectedVal[
                                          labelsDB.labels[index].name]!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  // adding color will hide the splash effect
                                  // color: Colors.blueGrey.shade200,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: labelsSelectedVal[
                                              labelsDB.labels[index].name],
                                          onChanged: (val) {
                                            setState(() {
                                              labelsSelectedVal[labelsDB
                                                  .labels[index].name] = val!;
                                            });
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10,
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
                                          width: 12,
                                        ),
                                        Text(
                                          labelsDB.labels[index].name,
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
