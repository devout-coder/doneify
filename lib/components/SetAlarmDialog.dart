import 'package:conquer_flutter_app/components/MyExpansionPanel.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SetAlarmDialog extends StatefulWidget {
  final double curve;
  String timeType;
  SetAlarmDialog({
    Key? key,
    required this.curve,
    required this.timeType,
  }) : super(key: key);

  @override
  State<SetAlarmDialog> createState() => _SetAlarmDialogState();
}

final _tileKeys = [];
var _selectedIndex = 0;

class SwitchValue {
  String name;
  bool status;

  SwitchValue(this.name, this.status);
}

class _SetAlarmDialogState extends State<SetAlarmDialog> {
  List<String> daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  DateTime onceDate = DateTime.now();
  TimeOfDay onceTime = TimeOfDay(hour: 9, minute: 00);
  String everyWeekDay = "Mon";
  TimeOfDay everyWeekTime = TimeOfDay(hour: 9, minute: 00);
  TextEditingController everyMonthDay = TextEditingController();
  TimeOfDay everyMonthTime = TimeOfDay(hour: 9, minute: 00);
  DateTime everyYearDate = DateTime.now();
  TimeOfDay everyYearTime = TimeOfDay(hour: 9, minute: 00);
  TimeOfDay everyDayTime = TimeOfDay(hour: 9, minute: 00);

  List<SwitchValue> switchValues = [
    SwitchValue("once", true),
    SwitchValue("everyDay", false),
    SwitchValue("everyWeek", false),
    SwitchValue("everyMonth", false),
    SwitchValue("everyYear", false),
  ];

  void handleSwitch(String switchName, bool switchValue) {
    setState(() {
      for (SwitchValue element in switchValues) {
        if (switchName == element.name) {
          element.status = switchValue;
        }
      }
    });
  }

  Future<Null> _selectDate(BuildContext context, String switchName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: switchName == "once" ? onceDate : everyYearDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (switchName == "once") {
          onceDate = picked;
        } else if (switchName == "everyYear") {
          everyYearDate = picked;
        }
      });
    }
  }

  Future<Null> _selectTime(BuildContext context, String switchName) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: switchName == "once"
            ? onceTime
            : switchName == "everyYear"
                ? everyYearTime
                : everyDayTime);
    if (picked != null) {
      setState(() {
        switch (switchName) {
          case "once":
            onceTime = picked;
            break;
          case "everyYear":
            everyYearTime = picked;
            break;
          case "everyWeek":
            everyWeekTime = picked;
            break;
          case "everyMonth":
            everyMonthTime = picked;
            break;
          case "everyDay":
            everyDayTime = picked;
            break;
          default:
            break;
        }
      });
    }
  }

  bool itemShouldAppear(String switchName) {
    return switchName == "everyYear" && widget.timeType == "longTerm" ||
        switchName == "everyMonth" &&
            (widget.timeType == "year" || widget.timeType == "longTerm") ||
        switchName == "everyWeek" &&
            (widget.timeType == "year" ||
                widget.timeType == "longTerm" ||
                widget.timeType == "month") ||
        switchName == "everyDay" &&
            (widget.timeType == "year" ||
                widget.timeType == "longTerm" ||
                widget.timeType == "month" ||
                widget.timeType == "week") ||
        switchName == "once";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Transform.scale(
      scale: widget.curve,
      child: Column(
        children: [
          Expanded(
            child: SimpleDialog(
              contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 5),
              backgroundColor: modalDark,
              children: [
                Container(
                  height: screenHeight * 0.65,
                  width: screenWidth,
                  color: modalDark,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MyExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            debugPrint("expansion callback");
                            handleSwitch(switchValues[index].name,
                                !switchValues[index].status);
                          },
                          elevation: 0,
                          children: switchValues
                              .map<MyExpansionPanel>((SwitchValue item) {
                            return itemShouldAppear(item.name)
                                ? MyExpansionPanel(
                                    canTapOnHeader: true,
                                    backgroundColor: modalDark,
                                    isEmpty: false,
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
                                      return ListTile(
                                        onTap: () {
                                          handleSwitch(item.name, !item.status);
                                        },
                                        title: Text(item.name,
                                            style:
                                                TextStyle(color: Colors.white)),
                                      );
                                    },
                                    isExpanded: item.status,
                                    body: item.name == "everyDay" &&
                                            widget.timeType != "day"
                                        ? TextButton(
                                            onPressed: () {
                                              _selectTime(context, "everyDay");
                                            },
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.all(12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          30.0),
                                                ),
                                                primary: Colors.white,
                                                elevation: 2,
                                                backgroundColor: Color.fromARGB(
                                                    255, 39, 37, 37)),
                                            child: Text(
                                              '${everyDayTime.hour.toString().padLeft(2, '0')}:${everyDayTime.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )
                                        : item.name == "everyWeek" &&
                                                widget.timeType != "day" &&
                                                widget.timeType != "week"
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  DropdownButton<String>(
                                                    value: everyWeekDay,
                                                    elevation: 16,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            "EuclidCircular",
                                                        color: Colors.white),
                                                    underline: Container(
                                                      height: 2,
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                    ),
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        everyWeekDay = value!;
                                                      });
                                                    },
                                                    dropdownColor: modalDark,
                                                    items: daysOfWeek.map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                  ),
                                                  SizedBox(width: 10),
                                                  TextButton(
                                                    onPressed: () {
                                                      _selectTime(
                                                          context, "everyWeek");
                                                    },
                                                    style: TextButton.styleFrom(
                                                        padding:
                                                            EdgeInsets.all(12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  30.0),
                                                        ),
                                                        primary: Colors.white,
                                                        elevation: 2,
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                39, 37, 37)),
                                                    child: Text(
                                                      '${everyWeekTime.hour.toString().padLeft(2, '0')}:${everyWeekTime.minute.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : item.name == 'everyMonth' &&
                                                    widget.timeType != "day" &&
                                                    widget.timeType != "week" &&
                                                    widget.timeType != "month"
                                                ? Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 50,
                                                            child:
                                                                TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              controller:
                                                                  everyMonthDay,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          116,
                                                                          116,
                                                                          116),
                                                                ),
                                                                hintText: "Day",
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                errorBorder:
                                                                    InputBorder
                                                                        .none,
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          TextButton(
                                                            onPressed: () {
                                                              _selectTime(
                                                                  context,
                                                                  "everyMonth");
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    primary: Colors
                                                                        .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${everyMonthTime.hour.toString().padLeft(2, '0')}:${everyYearTime.minute.toString().padLeft(2, '0')}',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                      everyMonthDay.text !=
                                                                  "" &&
                                                              int.parse(everyMonthDay
                                                                      .text
                                                                      .split(
                                                                          ".")[0]) >
                                                                  28
                                                          ? Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .warning_amber_rounded,
                                                                  size: 25,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          255,
                                                                          118,
                                                                          118),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                int.parse(everyMonthDay.text.split(".")[0]) >
                                                                            0 &&
                                                                        int.parse(everyMonthDay.text.split(".")[0]) <
                                                                            31
                                                                    ? Container(
                                                                        width:
                                                                            250,
                                                                        child:
                                                                            Text(
                                                                          "Alarm will be fired on the last day of the month if this day isn't present",
                                                                          style:
                                                                              TextStyle(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                118,
                                                                                118),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "Please enter a valid day",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              118,
                                                                              118),
                                                                        ),
                                                                      )
                                                              ],
                                                            )
                                                          : Container()
                                                    ],
                                                  )
                                                : item.name == "everyYear" &&
                                                        widget.timeType !=
                                                            "day" &&
                                                        widget.timeType !=
                                                            "week" &&
                                                        widget.timeType !=
                                                            "month" &&
                                                        widget.timeType !=
                                                            "year"
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              _selectDate(
                                                                  context,
                                                                  "everyYear");
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    primary: Colors
                                                                        .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              DateFormat(
                                                                      "d MMM")
                                                                  .format(
                                                                      everyYearDate),
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          TextButton(
                                                            onPressed: () {
                                                              _selectTime(
                                                                  context,
                                                                  "everyYear");
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    primary: Colors
                                                                        .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${everyYearTime.hour.toString().padLeft(2, '0')}:${everyYearTime.minute.toString().padLeft(2, '0')}',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              _selectDate(
                                                                  context,
                                                                  "once");
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    primary: Colors
                                                                        .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              DateFormat(
                                                                      "d MMM y")
                                                                  .format(
                                                                      onceDate),
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          TextButton(
                                                            onPressed: () {
                                                              _selectTime(
                                                                  context,
                                                                  "once");
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            12),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              30.0),
                                                                    ),
                                                                    primary: Colors
                                                                        .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${onceTime.hour.toString().padLeft(2, '0')}:${onceTime.minute.toString().padLeft(2, '0')}',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                  )
                                : MyExpansionPanel(
                                    headerBuilder: (BuildContext context,
                                        bool isExpanded) {
                                      return Container();
                                    },
                                    backgroundColor: modalDark,
                                    body: Container(),
                                    isEmpty: true,
                                  );
                          }).toList(),
                        ),
                        // ExpansionTile(
                        //   title: Container(
                        //       child: const Text('One time',
                        //           style: TextStyle(color: Colors.white))),
                        //   trailing: IgnorePointer(
                        //     child: Switch(
                        //       // This bool value toggles the switch.
                        //       value: switchValues["once"],
                        //       activeColor: themePurple,
                        //       onChanged: (bool value) {
                        //         // This is called when the user toggles the switch.
                        //         handleSwitch("once", value);
                        //       },
                        //     ),
                        //   ),
                        //   initiallyExpanded: switchValues["once"],
                        //   onExpansionChanged: (bool value) {
                        //     handleSwitch("once", value);
                        //   },
                        //   children: <Widget>[
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectDate(context);
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setOnceDate,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //         SizedBox(width: 10),
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectTime(context);
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setTime,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                        // ExpansionTile(
                        //   title: Container(
                        //       child: const Text('Every year',
                        //           style: TextStyle(color: Colors.white))),
                        //   trailing: IgnorePointer(
                        //     child: Switch(
                        //       // This bool value toggles the switch.
                        //       value: switchValues["everyYear"],
                        //       activeColor: themePurple,
                        //       onChanged: (bool value) {
                        //         handleSwitch("everyYear", value);
                        //       },
                        //     ),
                        //   ),
                        //   initiallyExpanded: switchValues["everyYear"],
                        //   onExpansionChanged: (bool value) {
                        //     handleSwitch("everyYear", value);
                        //   },
                        //   children: <Widget>[
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectDate(
                        //               context,
                        //             );
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setYearDate,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //         SizedBox(width: 10),
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectTime(context);
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setTime,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                        // ExpansionTile(
                        //   title: Container(
                        //       child: const Text('Every month',
                        //           style: TextStyle(color: Colors.white))),
                        //   trailing: IgnorePointer(
                        //     child: Switch(
                        //       value: switchValues["everyMonth"],
                        //       activeColor: themePurple,
                        //       onChanged: (bool value) {
                        //         handleSwitch("everyMonth", value);
                        //       },
                        //     ),
                        //   ),
                        //   initiallyExpanded: switchValues["everyMonth"],
                        //   onExpansionChanged: (bool value) {
                        //     handleSwitch("everyMonth", value);
                        //   },
                        //   children: <Widget>[
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectDate(
                        //               context,
                        //             );
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setYearDate,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //         SizedBox(width: 10),
                        //         TextButton(
                        //           onPressed: () {
                        //             _selectTime(context);
                        //           },
                        //           style: TextButton.styleFrom(
                        //               padding: EdgeInsets.all(12),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     new BorderRadius.circular(30.0),
                        //               ),
                        //               primary: Colors.white,
                        //               elevation: 2,
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 39, 37, 37)),
                        //           child: Text(
                        //             setTime,
                        //             style: TextStyle(fontSize: 16),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
