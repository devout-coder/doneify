import 'package:doneify/components/each_week_cell.dart';
import 'package:doneify/components/my_expansion_panel.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/impClasses.dart';
import 'package:doneify/pages/input_modal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sembast/timestamp.dart';

class SetAlarmDialog extends StatefulWidget {
  final double curve;
  String timeType;
  DateTime? selectedTime;
  List<DateTime> selectedWeekDates;
  final updateCreatedAlarms;
  int taskId;
  SetAlarmDialog({
    Key? key,
    required this.taskId,
    required this.curve,
    required this.timeType,
    required this.selectedTime,
    required this.selectedWeekDates,
    required this.updateCreatedAlarms,
  }) : super(key: key);

  @override
  State<SetAlarmDialog> createState() => _SetAlarmDialogState();
}

class SwitchValue {
  String name;
  bool status;

  SwitchValue(this.name, this.status);
}

List<String> daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

class _SetAlarmDialogState extends State<SetAlarmDialog> {
  List<Alarm> newAlarms = [];

  DateTime onceDate = DateTime.now();
  TimeOfDay onceTime = TimeOfDay(hour: DateTime.now().hour + 1, minute: 00);
  DateTime onceFirstDate = DateTime.now();
  DateTime onceLastDate = DateTime.now();

  TimeOfDay everyDayTime = TimeOfDay(hour: 9, minute: 00);
  String everyWeekDay = "Mon";
  TimeOfDay everyWeekTime = TimeOfDay(hour: 9, minute: 00);
  TextEditingController everyMonthDay = TextEditingController();
  TimeOfDay everyMonthTime = TimeOfDay(hour: 9, minute: 00);
  DateTime everyYearDate = DateTime(DateTime.now().year, 1, 1);
  TimeOfDay everyYearTime = TimeOfDay(hour: 9, minute: 00);

  List<SwitchValue> switchValues = [
    SwitchValue("once", false),
    SwitchValue("everyDay", false),
    SwitchValue("everyWeek", false),
    SwitchValue("everyMonth", false),
    SwitchValue("everyYear", false),
  ];

  void setSwitchValue(String switchName, bool switchValue) {
    setState(() {
      for (SwitchValue element in switchValues) {
        if (switchName == element.name) {
          element.status = switchValue;
        }
      }
    });
  }

  bool getSwitchValue(String switchName) {
    bool switchStatus = false;
    for (SwitchValue element in switchValues) {
      if (switchName == element.name) {
        switchStatus = element.status;
      }
    }
    return switchStatus;
  }

  Future<Null> _selectDate(BuildContext context, String switchName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: switchName == "once" ? onceDate : everyYearDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: switchName != "everyYear"
          ? onceFirstDate
          : DateTime(DateTime.now().year, 1, 1),
      lastDate: switchName != "everyYear"
          ? onceLastDate
          : DateTime(DateTime.now().year, 12, 31),
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

  bool validDateOfMonth() {
    return int.parse(everyMonthDay.text.split(".")[0]) > 0 &&
        int.parse(everyMonthDay.text.split(".")[0]) <= 31;
  }

  void setFirstAndLastDate() {
    switch (widget.timeType) {
      case "week":
        onceFirstDate = widget.selectedWeekDates[0];
        onceLastDate = widget.selectedWeekDates[6];
        break;
      case "month":
        onceFirstDate = widget.selectedTime!;
        onceLastDate = DateTime(
            widget.selectedTime!.year, widget.selectedTime!.month + 1, 0);
        break;
      case "year":
        onceFirstDate = widget.selectedTime!;
        onceLastDate = DateTime(widget.selectedTime!.year, 12, 31);
        break;
      case "longTerm":
        onceFirstDate = DateTime(2022, 1, 1);
        onceLastDate = DateTime(2100, 12, 31);
    }
  }

  String addZero(int weirdLookingInt) {
    return weirdLookingInt.toString().padLeft(2, "0");
  }

  bool isInPast() {
    DateTime combinedDateTime = DateTime(onceDate.year, onceDate.month,
        onceDate.day, onceTime.hour, onceTime.minute);
    return (getSwitchValue("once") &&
            combinedDateTime.isBefore(DateTime.now())) ||
        (widget.timeType == "week" &&
            widget.selectedWeekDates[6].isBefore(justDate(DateTime.now()))) ||
        (widget.timeType == "month" &&
            DateTime(widget.selectedTime!.year, widget.selectedTime!.month + 1,
                    0)
                .isBefore(justDate(DateTime.now()))) ||
        (widget.timeType == "year" &&
            DateTime(widget.selectedTime!.year, 12, 31)
                .isBefore(justDate(DateTime.now())));
  }

  void saveAlarm(BuildContext context) {
    // DateTime combinedDateTime = DateTime(onceDate.year, onceDate.month,
    //     onceDate.day, onceTime.hour, onceTime.minute);
    // if (combinedDateTime.isBefore(DateTime.now()) && getSwitchValue("once")) {
    if (isInPast()) {
      Fluttertoast.showToast(
        msg: "Please select a date in the future",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } else {
      switchValues.forEach((element) {
        if (element.status) {
          String timeStr = element.name == "once"
              ? "${DateFormat("d MMM y").format(onceDate)}, ${addZero(onceTime.hour)}:${addZero(onceTime.minute)}"
              : element.name == "everyDay"
                  ? "${addZero(everyDayTime.hour)}:${addZero(everyDayTime.minute)}"
                  : element.name == "everyWeek"
                      ? "$everyWeekDay, ${addZero(everyWeekTime.hour)}:${addZero(everyWeekTime.minute)}"
                      : element.name == "everyMonth"
                          ? "${everyMonthDay.text}, ${addZero(everyMonthTime.hour)}:${addZero(everyMonthTime.minute)}"
                          : "${DateFormat("d MMM").format(everyYearDate)}, ${addZero(everyYearTime.hour)}:${addZero(everyYearTime.minute)}";
          newAlarms
              .add(Alarm(getRandInt(9), widget.taskId, element.name, timeStr));
        }
      });
      widget.updateCreatedAlarms(newAlarms);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // setValues();
    setFirstAndLastDate();
    onceDate = widget.selectedTime!;
    everyMonthDay.text = "1";

    super.initState();
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            // debugPrint("expansion callback");
                            setSwitchValue(switchValues[index].name,
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
                                          setSwitchValue(
                                              item.name, !item.status);
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
                                                // primary: Colors.white,
                                                elevation: 2,
                                                backgroundColor: Color.fromARGB(
                                                    255, 39, 37, 37)),
                                            child: Text(
                                              '${addZero(everyDayTime.hour)}:${addZero(everyDayTime.minute)}',
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
                                                        // primary: Colors.white,
                                                        elevation: 2,
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                39, 37, 37)),
                                                    child: Text(
                                                      '${addZero(everyWeekTime.hour)}:${addZero(everyWeekTime.minute)}',
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
                                                                      borderRadius: new BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    ),
                                                                    // primary: Colors
                                                                    //     .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${addZero(everyMonthTime.hour)}:${addZero(everyMonthTime.minute)}',
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
                                                                validDateOfMonth()
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
                                                                      borderRadius: new BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    ),
                                                                    // primary: Colors
                                                                    // .white,
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
                                                                      borderRadius: new BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    ),
                                                                    // primary: Colors
                                                                    //     .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${addZero(everyYearTime.hour)}:${addZero(everyYearTime.minute)}',
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
                                                          widget.timeType !=
                                                                  "day"
                                                              ? TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    _selectDate(
                                                                        context,
                                                                        "once");
                                                                  },
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                          padding: EdgeInsets.all(
                                                                              12),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                new BorderRadius.circular(30.0),
                                                                          ),
                                                                          // primary: Colors
                                                                          //     .white,
                                                                          elevation:
                                                                              2,
                                                                          backgroundColor: Color.fromARGB(
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
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                )
                                                              : Container(),
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
                                                                      borderRadius: new BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    ),
                                                                    // primary: Colors
                                                                    //     .white,
                                                                    elevation:
                                                                        2,
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            39,
                                                                            37,
                                                                            37)),
                                                            child: Text(
                                                              '${addZero(onceTime.hour)}:${addZero(onceTime.minute)}',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              tooltip: "Close",
                              color: Color.fromARGB(255, 202, 202, 202),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                            ),
                            IconButton(
                              tooltip: "Save Alarm",
                              color: Color.fromARGB(255, 202, 202, 202),
                              onPressed: !(getSwitchValue("everyMonth") &&
                                      !validDateOfMonth())
                                  ? () {
                                      saveAlarm(context);
                                    }
                                  : null,
                              icon: Icon(Icons.check_rounded),
                            ),
                          ],
                        ),
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
