import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class FiltersDialog extends StatefulWidget {
  final double curve;
  final reloadTodos;
  bool? homePage;

  FiltersDialog({
    Key? key,
    required this.curve,
    required this.reloadTodos,
    this.homePage,
  }) : super(key: key);

  @override
  State<FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {
  LabelDB labelsDB = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();

  Map<String, bool> labelsSelectedVal = {};
  bool currentFirst = true;
  bool ascending = false;
  double turns = 0.0;

  void readFiltersVal() {
    Map<String, bool> labelsSelectedValTemp = {};
    labelsDB.labels.forEach((element) {
      labelsSelectedValTemp[element.name] =
          selectedFilters.selectedLabels.contains(element.name);
    });
    setState(() {
      labelsSelectedVal = labelsSelectedValTemp;
      currentFirst = selectedFilters.currentFirst;
      ascending = selectedFilters.ascending;
      turns = ascending ? 1.0 / 2.0 : 0.0;
    });
  }

  Future<bool> saveFilters() async {
    List<String> newLabels = [];
    labelsSelectedVal.forEach((key, value) {
      if (value) {
        newLabels.add(key);
      }
    });
    if (newLabels.isNotEmpty) {
      selectedFilters.addLabels(newLabels);
      selectedFilters.setAscending(ascending);
      selectedFilters.setCurrentFirst(currentFirst);
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
    readFiltersVal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return saveFilters();
      },
      child: Transform.scale(
        scale: widget.curve,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SimpleDialog(
                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                  titlePadding: EdgeInsets.fromLTRB(20, 20, 10, 0),
                  title: widget.homePage != null
                      ? Text("Select filters")
                      : Text('Choose Labels'),
                  children: <Widget>[
                    widget.homePage != null
                        ? Column(
                            children: [
                              SizedBox(height: 5),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    currentFirst = !currentFirst;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Today's tasks at the top",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Switch(
                                      value: currentFirst,
                                      onChanged: (val) {
                                        setState(() {
                                          currentFirst = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    turns += 1.0 / 2.0;
                                    ascending = !ascending;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Sort by day",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      AnimatedRotation(
                                          duration: const Duration(
                                              microseconds: 200 * 1000),
                                          turns: turns,
                                          child: Icon(
                                            Icons.arrow_upward_rounded,
                                            size: 25,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    widget.homePage != null
                        ? SizedBox(height: 20)
                        : Container(),
                    widget.homePage != null
                        ? Text(
                            "Select labels",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Container(),
                    Container(
                      height: screenHeight * 0.3,
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
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            labelsDB.labels[index].name,
                                          ),
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
