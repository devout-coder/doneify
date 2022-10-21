import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/components/EachWeekCell.dart';
import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/components/SelectTimeDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/Month.dart';
import 'package:conquer_flutter_app/pages/Week.dart';
import 'package:conquer_flutter_app/pages/Year.dart';
import 'package:conquer_flutter_app/states/alarmsAPI.dart';
import 'package:conquer_flutter_app/states/labelsAPI.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class InputModal extends StatefulWidget {
  final goBack;
  Todo? todo;
  final createTodo;
  final editTodo;
  final onDelete;
  String time;
  String timeType;

  InputModal({
    Key? key,
    // this.action,
    this.goBack,
    this.todo,
    this.createTodo,
    this.editTodo,
    this.onDelete,
    required this.time,
    required this.timeType,
  }) : super(key: key);

  @override
  State<InputModal> createState() => _InputModalState();
}

List<DateTime> allDatesInWeek(DateTime day) {
  List<DateTime> allDates = [];
  DateTime startDate = day.subtract(Duration(days: day.weekday - 1));
  for (int i = 0; i < 7; i++) {
    allDates.add(justDate(startDate.add(Duration(days: i))));
  }
  return allDates;
}

class _InputModalState extends State<InputModal> {
  int selectedLabel = 0;
  List<DateTime> selectedWeekDates = [];
  DateTime? selectedTime;
  List<Alarm>? taskAlarms = [];
  List<Alarm> deletedTaskAlarms = [];

  LabelAPI labelsDB = GetIt.I.get();
  AlarmsAPI alarmsDB = GetIt.I.get();

  final taskName = TextEditingController();
  final taskDesc = TextEditingController();
  int? taskId;

  static const platform = MethodChannel('alarm_method_channel');

  Future<void> saveAlarm() async {
    try {
      debugPrint("$taskId");
      final String formatted = DateFormat("d/M/y,H:m").format(DateTime.now());
      await platform.invokeMethod("setAlarm", {
        "repeat_status": "once",
        "taskId": taskId.toString(),
        "taskName": taskName.text,
        "taskDesc": taskDesc.text,
        "label": labelsDB.labels[selectedLabel].name,
        "time": formatted,
      });
      // batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      // batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }

  int getRandInt() {
    var random = Random.secure();
    var values = List<String>.generate(18, (i) => random.nextInt(9).toString());
    var stringList = values.join("");
    return int.parse(stringList);
  }

  int findLabelIndex(String labelName) {
    int index = 0;
    // debugPrint("now index ${index.toString()} ");
    // debugPrint
    for (int i = 0; i < labelsDB.labels.length; i++) {
      if (labelsDB.labels[i].name == labelName) {
        index = i;
      }
    }
    return index;
  }

  String figureOutTime() {
    switch (widget.timeType) {
      case "day":
        return formattedDate(selectedTime!);
      case "week":
        return formattedWeek(selectedWeekDates[0]);
      case "month":
        return formattedMonth(selectedTime!);
      case "year":
        return formattedYear(selectedTime!);
      default:
        return "longTerm";
    }
  }

  void _saveTodo() async {
    // debugPrint(figureOutTime());
    Todo newTodo;
    if (taskName.text != "") {
      if (widget.todo != null) {
        newTodo = Todo(
          taskName.text,
          taskDesc.text,
          false,
          labelsDB.labels[selectedLabel].name,
          DateTime.now().millisecondsSinceEpoch,
          figureOutTime(),
          widget.timeType,
          widget.todo!.index,
          taskId!,
        );
        await widget.editTodo(newTodo);
      } else {
        newTodo = Todo(
          taskName.text,
          taskDesc.text,
          false,
          labelsDB.labels[selectedLabel].name,
          DateTime.now().millisecondsSinceEpoch,
          figureOutTime(),
          widget.timeType,
          0, //this is going to be changed in createTodo method
          taskId!,
        );
        await widget.createTodo(newTodo);
      }
      Fluttertoast.showToast(
        msg: "Task saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      widget.goBack();
    } else {
      Fluttertoast.showToast(
        msg: "Task saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void setValues() async {
    taskId = widget.todo != null ? widget.todo!.id : getRandInt();
    taskName.text = widget.todo != null ? widget.todo!.taskName : '';
    taskDesc.text = widget.todo != null ? widget.todo!.taskDesc : '';
    selectedLabel =
        widget.todo != null ? findLabelIndex(widget.todo!.labelName) : 0;
    taskAlarms = await alarmsDB.getAlarms(taskId!);

    setState(() {
      switch (widget.timeType) {
        case "week":
          selectedWeekDates = allDatesInWeek(DateTime.now());
          break;
        default:
          selectedTime = DateTime.now();
      }
    });
    // debugPrint(widget.todo!.index.toString());
  }

  @override
  void initState() {
    setValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Todo newTodo = Todo("", "");

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: themePurple,
      height: screenHeight,
      padding: const EdgeInsets.fromLTRB(20, 40, 5, 20),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          TextFormField(
            //! taskName text field
            controller: taskName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: "Task Name",
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          LayoutBuilder(
            //! task description text field
            builder: (context, constraints) => Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).viewInsets.bottom != 0
                      ? screenHeight * 0.7 - 250
                      : screenHeight * 0.65),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: TextFormField(
                    controller: taskDesc,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: null,
                    // minLines: 15,
                    decoration: const InputDecoration(
                      hintText: "Task Description",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            //! bottom icon row
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.label,
                      size: 30,
                    ),
                    tooltip: "Add label",
                    onPressed: () => {
                      showGeneralDialog(
                        //! add label dialog box
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Select Label",
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Container();
                        },
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return SelectLabelDialog(
                            curve: curve,
                            selectedLabel: selectedLabel,
                            updateSelectedLabel: (newLabel) {
                              setState(() {
                                selectedLabel = newLabel;
                              });
                            },
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      )
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Select Time",
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Container();
                        },
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return SelectTimeDialog(
                            curve: curve,
                            timeType: widget.timeType,
                            taskAlarms: taskAlarms,
                            updateTaskAlarms: (newAlarms) {
                              setState(() {
                                taskAlarms = newAlarms;
                              });
                            },
                            deletedTaskAlarms: deletedTaskAlarms,
                            updateDeletedTaskAlarms: (newDeletedAlarms) {
                              setState(() {
                                deletedTaskAlarms = newDeletedAlarms;
                              });
                            },
                            selectedTime: selectedTime,
                            selectedWeekDates: selectedWeekDates,
                            updateSelectedWeekDates: (newWeekDates) {
                              setState(() {
                                selectedWeekDates = newWeekDates;
                              });
                            },
                            updateSelectedTime: (newTime) {
                              setState(() {
                                selectedTime = newTime;
                              });
                            },
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      );
                      // saveReminder();
                      // widget.goBack();
                    },
                    tooltip: "Add reminder",
                    icon: const Icon(
                      Icons.access_alarm,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // action.call();
                    },
                    tooltip: "Share task with friends",
                    icon: const Icon(
                      Icons.people,
                      size: 30,
                    ),
                  ),
                  widget.todo != null
                      ? IconButton(
                          onPressed: widget.onDelete,
                          tooltip: "Delete this task",
                          icon: const Icon(
                            Icons.delete,
                            size: 30,
                          ),
                        )
                      : SizedBox(),
                  IconButton(
                    onPressed: () {
                      _saveTodo();
                    },
                    tooltip: "Save this task",
                    icon: const Icon(
                      Icons.save,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
