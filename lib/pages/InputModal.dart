import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/components/EachWeekCell.dart';
import 'package:conquer_flutter_app/components/SelectLabelDialog.dart';
import 'package:conquer_flutter_app/components/SelectTimeDialog.dart';
import 'package:conquer_flutter_app/components/SetAlarmDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/Month.dart';
import 'package:conquer_flutter_app/pages/Week.dart';
import 'package:conquer_flutter_app/pages/Year.dart';
import 'package:conquer_flutter_app/states/alarmDAO.dart';
import 'package:conquer_flutter_app/states/labelDAO.dart';
import 'package:conquer_flutter_app/states/todoDAO.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
  int? todoId;
  final onCreate;
  final onEdit;
  final onDelete;
  String? time;
  String? timeType;
  bool? loadedFromWidget;

  InputModal({
    Key? key,
    // this.action,
    this.goBack,
    this.todo,
    this.todoId,
    this.onCreate,
    this.onEdit,
    this.onDelete,
    this.time,
    this.timeType,
    this.loadedFromWidget,
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

String figureOutTime(
    String timeType, DateTime selectedTime, List<DateTime> selectedWeekDates) {
  // debugPrint(formattedDate(selectedTime!));
  switch (timeType) {
    case "day":
      return formattedDate(selectedTime);
    case "week":
      return formattedWeek(selectedWeekDates[0]);
    case "month":
      return formattedMonth(selectedTime);
    case "year":
      return formattedYear(selectedTime);
    default:
      return "longTerm";
  }
}

int getRandInt(int chars) {
  var random = Random.secure();
  var values =
      List<String>.generate(chars, (i) => random.nextInt(9).toString());
  var stringList = values.join("");
  return int.parse(stringList);
}

const platform = MethodChannel('alarm_method_channel');

class _InputModalState extends State<InputModal> {
  int selectedLabel = 0;
  List<DateTime> selectedWeekDates = [];
  DateTime selectedTime = DateTime.now();
  List<Alarm> alarms = [];
  List<Alarm> createdAlarms = [];
  List<Alarm> deletedAlarms = [];

  Todo? todo;

  LabelDAO labelsDB = GetIt.I.get();
  AlarmDAO alarmsDB = GetIt.I.get();

  final taskName = TextEditingController();
  final taskDesc = TextEditingController();
  int? taskId;
  String? time;
  String? timeType;

  bool futureTime(int hour, int minute) {
    bool future = false;
    DateTime currentTime = DateTime.now();
    if (hour > currentTime.hour) {
      future = true;
    } else if (hour == currentTime.hour && minute > currentTime.minute) {
      future = true;
    }
    return future;
  }

  // bool futureDate(int dayOfMonth, int hour, int minute) {
  //   DateTime currentTime = DateTime.now();
  //   return DateTime(currentTime.year, currentTime.month, dayOfMonth)
  //           .isAfter(currentTime) ||
  //       (DateTime(currentTime.year, currentTime.month, dayOfMonth)
  //               .isAtSameMomentAs(currentTime) &&
  //           futureTime(hour, minute));
  // }

  bool futureDateAndTime(DateTime date, int hour, int minute) {
    DateTime currentTime = DateTime.now();
    return date.isAfter(currentTime) ||
        date.isAtSameMomentAs(justDate(currentTime)) &&
            futureTime(hour, minute);
  }

  String amendAlarmTime(String time, String repeatStatus) {
    String prefixDate = "";
    DateTime currentTime = justDate(DateTime.now());
    switch (repeatStatus) {
      case "once":
        //time: 3 Nov 2022, 21:00
        List<String> splitTime = time.split(' ');
        String day = splitTime[0];
        String month = DateFormat("MMM").parse(splitTime[1]).month.toString();
        String year = splitTime[2];
        String hourTime = splitTime[3];
        return "$day/$month/$year $hourTime";
      case "everyDay":
        //time: 09:00
        DateTime nextDayTime =
            DateTime(currentTime.year, currentTime.month, currentTime.day + 1);
        switch (timeType!) {
          case "week":
            if (selectedWeekDates[0].isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(selectedWeekDates[0]);
            } else {
              prefixDate = futureTime(int.parse(time.split(":")[0]),
                      int.parse(time.split(":")[1]))
                  ? DateFormat("d/M/y").format(currentTime)
                  : DateFormat("d/M/y").format(nextDayTime);
            }
            return "$prefixDate, $time";
          case "month":
            if (selectedTime.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(selectedTime);
            } else {
              prefixDate = futureTime(int.parse(time.split(":")[0]),
                      int.parse(time.split(":")[1]))
                  ? DateFormat("d/M/y").format(currentTime)
                  : DateFormat("d/M/y").format(nextDayTime);
            }
            return "$prefixDate, $time";
          case "year":
            if (selectedTime.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(selectedTime);
            } else {
              prefixDate = futureTime(int.parse(time.split(":")[0]),
                      int.parse(time.split(":")[1]))
                  ? DateFormat("d/M/y").format(currentTime)
                  : DateFormat("d/M/y").format(nextDayTime);
            }
            return "$prefixDate, $time";
          default:
            return futureTime(int.parse(time.split(":")[0]),
                    int.parse(time.split(":")[1]))
                ? "${DateFormat("d/M/y").format(currentTime)}, $time"
                : "${DateFormat("d/M/y").format(nextDayTime)}, $time";
        }
      case "everyWeek":
        //time: Mon, 09:00
        List<String> splitStr = time.split(", ");
        String dayOfWeek = splitStr[0];
        String hourTime = splitStr[1];
        DateTime nextWeekTime =
            DateTime(currentTime.year, currentTime.month, currentTime.day + 7);
        switch (timeType!) {
          case "month":
            var firstOfMonth =
                DateTime(selectedTime.year, selectedTime.month, 1);
            var firstDay = firstOfMonth.add(
              Duration(
                  days: (7 -
                          (firstOfMonth.weekday -
                              daysOfWeek.indexOf(dayOfWeek) -
                              1)) %
                      7),
            );
            if (firstDay.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(firstDay);
            } else {
              firstDay = currentTime.add(
                Duration(
                    days: (7 -
                            (currentTime.weekday -
                                daysOfWeek.indexOf(dayOfWeek) -
                                1)) %
                        7),
              );
              prefixDate = futureDateAndTime(
                      justDate(firstDay),
                      int.parse(hourTime.split(":")[0]),
                      int.parse(hourTime.split(":")[1]))
                  ? DateFormat("d/M/y").format(firstDay)
                  : DateFormat("d/M/y").format(
                      nextWeekTime); //wont work, figure out the day after current date
            }
            return "$prefixDate, $hourTime";
          case "year":
            var firstOfYear = DateTime(selectedTime.year, 1, 1);
            var firstDay = firstOfYear.add(
              Duration(
                  days: (7 -
                          (firstOfYear.weekday -
                              daysOfWeek.indexOf(dayOfWeek) -
                              1)) %
                      7),
            );
            if (firstDay.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(firstDay);
            } else {
              firstDay = currentTime.add(
                Duration(
                    days: (7 -
                            (currentTime.weekday -
                                daysOfWeek.indexOf(dayOfWeek) -
                                1)) %
                        7),
              );
              prefixDate = futureDateAndTime(
                      justDate(firstDay),
                      int.parse(hourTime.split(":")[0]),
                      int.parse(hourTime.split(":")[1]))
                  ? DateFormat("d/M/y").format(firstDay)
                  : DateFormat("d/M/y").format(
                      nextWeekTime); //wont work, figure out the day after current date
            }
            return "$prefixDate, $hourTime";
          default:
            var firstDay = currentTime.add(
              Duration(
                  days: (7 -
                          (currentTime.weekday -
                              daysOfWeek.indexOf(dayOfWeek) -
                              1)) %
                      7),
            );
            prefixDate = futureDateAndTime(
                    justDate(firstDay),
                    int.parse(hourTime.split(":")[0]),
                    int.parse(hourTime.split(":")[1]))
                ? DateFormat("d/M/y").format(firstDay)
                : DateFormat("d/M/y").format(
                    nextWeekTime); //wont work, figure out the day after current date
            return "$prefixDate, $hourTime";
        }
      case "everyMonth":
        //time: 1, 09:00
        List<String> splitStr = time.split(", ");
        String dayOfMonth = splitStr[0];
        String hourTime = splitStr[1];
        DateTime nextMonthTime = DateTime(
            currentTime.year, currentTime.month + 1, int.parse(dayOfMonth));
        switch (timeType!) {
          case "year":
            var firstDay =
                DateTime(selectedTime.year, 1, int.parse(dayOfMonth));
            if (firstDay.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(firstDay);
            } else {
              prefixDate = futureDateAndTime(
                justDate(DateTime(currentTime.year, currentTime.month,
                    int.parse(dayOfMonth))),
                int.parse(hourTime.split(":")[0]),
                int.parse(hourTime.split(":")[1]),
              )
                  ? DateFormat("d/M/y").format(DateTime(currentTime.year,
                      currentTime.month, int.parse(dayOfMonth)))
                  : DateFormat("d/M/y").format(nextMonthTime);
            }
            return "$prefixDate, $hourTime";
          default:
            var firstDay = DateTime(
                currentTime.year, currentTime.month, int.parse(dayOfMonth));
            if (firstDay.isAfter(currentTime)) {
              prefixDate = DateFormat("d/M/y").format(firstDay);
            } else {
              prefixDate = futureDateAndTime(
                justDate(DateTime(currentTime.year, currentTime.month,
                    int.parse(dayOfMonth))),
                int.parse(hourTime.split(":")[0]),
                int.parse(hourTime.split(":")[1]),
              )
                  ? DateFormat("d/M/y").format(DateTime(currentTime.year,
                      currentTime.month + 1, int.parse(dayOfMonth)))
                  : DateFormat("d/M/y").format(nextMonthTime);
            }
            return "$prefixDate, $hourTime";
        }
      default:
        //every year
        //time: 1 Jan, 09:00
        List<String> mainSplit = time.split(", ");
        String day = mainSplit[0].split(" ")[0];
        String month = DateFormat("MMM")
            .parse(mainSplit[0].split(" ")[1])
            .month
            .toString();
        String hourTime = mainSplit[1];
        DateTime nextYearTime =
            DateTime(currentTime.year + 1, int.parse(month), int.parse(day));
        var firstDay =
            DateTime(currentTime.year, int.parse(month), int.parse(day));
        if (firstDay.isAfter(currentTime)) {
          prefixDate = DateFormat("d/M/y").format(firstDay);
        } else {
          prefixDate = futureDateAndTime(
                  firstDay,
                  int.parse(hourTime.split(":")[0]),
                  int.parse(hourTime.split(":")[1]))
              ? DateFormat("d/M/y").format(
                  DateTime(currentTime.year, int.parse(month), int.parse(day)))
              : DateFormat("d/M/y").format(nextYearTime);
        }
        return "$prefixDate, $hourTime";
    }
  }

  DateTime repeatingAlarmEndDate() {
    //time format: 31/10/2022,  31/10/2022-6/11/2022, Nov 2022, 2022
    switch (timeType!) {
      case "week":
        return selectedWeekDates[6];
      case "month":
        DateTime lastDate =
            DateTime(selectedTime.year, selectedTime.month + 1, 0);
        return lastDate;
      case "year":
        DateTime lastDate = DateTime(selectedTime.year, 12, 31);
        return lastDate;
      default:
        return DateTime(2200, 1, 1);
    }
  }

  void saveAlarms() async {
    if (todo != null) {
      //time modified
      if (taskName.text != todo!.taskName ||
          taskDesc.text != todo!.taskDesc ||
          labelsDB.labels[selectedLabel].name != todo!.labelName ||
          figureOutTime(timeType!, selectedTime, selectedWeekDates) != time) {
        List alarmIds = await platform.invokeMethod('getActiveIds');
        alarmIds = alarmIds.map((alarmId) => int.parse(alarmId)).toList();
        // debugPrint("alarm ids of active alarms: $alarmIds");
        alarms.forEach((alarm) async {
          if (!createdAlarms.contains(alarm)) {
            //an old alarm
            debugPrint("an old alarm:${alarm.alarmId.toString()}");
            alarmsDB.deleteAlarm(alarm.alarmId);
            if (alarmIds.contains(alarm.alarmId) &&
                (alarm.repeatStatus != "once" ||
                    figureOutTime(timeType!, selectedTime, selectedWeekDates) ==
                        time)) {
              //the alarm shouldn't have rung and repeat status shouldn't be once or time shouldn't be changed
              if (timeType! == "longTerm" ||
                  (timeType! == "week" &&
                      futureDateAndTime(selectedWeekDates[6], 0, 0)) ||
                  (futureDateAndTime(repeatingAlarmEndDate(), 0, 0))) {
                await alarmsDB.setAlarm(
                  alarm,
                  amendAlarmTime(alarm.time, alarm.repeatStatus),
                  DateFormat("d/M/y").format(repeatingAlarmEndDate()),
                  alarm.taskId.toString(),
                  taskName.text,
                  taskDesc.text,
                  labelsDB.labels[selectedLabel].name,
                  todo!.finished,
                );
              }
            }
          }
        });
      }
      createdAlarms.forEach((alarm) {
        alarmsDB.setAlarm(
          alarm,
          amendAlarmTime(alarm.time, alarm.repeatStatus),
          DateFormat("d/M/y").format(repeatingAlarmEndDate()),
          alarm.taskId.toString(),
          taskName.text,
          taskDesc.text,
          labelsDB.labels[selectedLabel].name,
          todo!.finished,
        );
      });
    } else {
      createdAlarms.forEach((alarm) {
        alarmsDB.setAlarm(
          alarm,
          amendAlarmTime(alarm.time, alarm.repeatStatus),
          DateFormat("d/M/y").format(repeatingAlarmEndDate()),
          alarm.taskId.toString(),
          taskName.text,
          taskDesc.text,
          labelsDB.labels[selectedLabel].name,
          false,
        );
      });
    }
    deletedAlarms.forEach((alarm) {
      alarmsDB.deleteAlarm(alarm.alarmId);
    });
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

  void _saveTodo() async {
    // debugPrint(figureOutTime());
    Todo newTodo;
    if (taskName.text != "") {
      // if (widget.loadedFromWidget != null) {
      //   if (widget.loadedFromWidget!) {
      //     debugPrint("this was loaded from widget");
      //     platform.invokeMethod("edited_from_widget", {"val": true});
      //   }
      // }
      if (todo != null) {
        newTodo = Todo(
          taskName.text,
          taskDesc.text,
          false,
          labelsDB.labels[selectedLabel].name,
          DateTime.now().millisecondsSinceEpoch,
          figureOutTime(timeType!, selectedTime, selectedWeekDates),
          timeType!,
          todo!.index,
          taskId!,
        );
        await widget.onEdit(newTodo);
      } else {
        newTodo = Todo(
          taskName.text,
          taskDesc.text,
          false,
          labelsDB.labels[selectedLabel].name,
          DateTime.now().millisecondsSinceEpoch,
          figureOutTime(timeType!, selectedTime, selectedWeekDates),
          timeType!,
          0, //this is going to be changed in onCreate method
          taskId!,
        );
        await widget.onCreate(newTodo);
      }
      saveAlarms();
      Fluttertoast.showToast(
        msg: "Task saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      widget.goBack();
    } else {
      Fluttertoast.showToast(
        msg: "Give the task a name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void strToTime() {
    setState(() {
      switch (timeType!) {
        case "day":
          selectedTime = DateFormat("d/M/y").parse(time!);
          break;
        case "week":
          selectedTime = DateFormat("d/M/y").parse(time!.split("-")[0]);
          selectedWeekDates = allDatesInWeek(selectedTime);
          break;
        case 'month':
          selectedTime = DateFormat("MMM y").parse(time!);
          break;
        case "year":
          selectedTime = DateFormat("y").parse(time!);
          break;
        default:
          break;
      }
    });
  }

  Future setValues() async {
    //todoId: edit todo widgeet
    // todo: edit todo each todo
    TodoDAO todosdb = GetIt.I.get();
    if (widget.todo != null) {
      todo = widget.todo;
    } else if (widget.todoId != null) {
      todo = await todosdb.getTodo(widget.todoId!);
      // debugPrint("fetched todo: $todo");
    }
    taskId = todo != null ? todo!.id : getRandInt(18);
    taskName.text = todo != null ? todo!.taskName : '';
    taskDesc.text = todo != null ? todo!.taskDesc : '';
    selectedLabel = todo != null ? findLabelIndex(todo!.labelName) : 0;
    time = todo != null ? todo!.time : widget.time;
    timeType = todo != null ? todo!.timeType : widget.timeType;
    alarms = await alarmsDB.getAlarms(taskId!);
    // debugPrint("fetched alarms $alarms");
    strToTime();
  }

  Future? init;
  @override
  void initState() {
    // setValues();
    init = setValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Todo newTodo = Todo("", "");

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
                          maxHeight:
                              MediaQuery.of(context).viewInsets.bottom != 0
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
                                  var curve =
                                      Curves.easeInOut.transform(a1.value);
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
                                transitionDuration:
                                    const Duration(milliseconds: 300),
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
                                  var curve =
                                      Curves.easeInOut.transform(a1.value);
                                  return SelectTimeDialog(
                                    // key: UniqueKey(),
                                    curve: curve,
                                    timeType: timeType!,
                                    alarms: alarms,
                                    taskId: taskId!,
                                    createdAlarms: createdAlarms,
                                    updateCreatedAlarms:
                                        (List<Alarm> newCreatedAlarms) {
                                      setState(() {
                                        // debugPrint(newCreatedAlarms.toString());
                                        createdAlarms = [
                                          ...createdAlarms,
                                          ...newCreatedAlarms
                                        ];
                                        alarms = [
                                          ...alarms,
                                          ...newCreatedAlarms
                                        ];
                                      });
                                    },
                                    deletedAlarms: deletedAlarms,
                                    updateDeletedAlarms: (Alarm deletedAlarm) {
                                      setState(() {
                                        alarms.remove(deletedAlarm);
                                        if (createdAlarms
                                            .contains(deletedAlarm)) {
                                          createdAlarms.remove(deletedAlarm);
                                        } else {
                                          deletedAlarms = [
                                            ...deletedAlarms,
                                            deletedAlarm
                                          ];
                                        }
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
                                transitionDuration:
                                    const Duration(milliseconds: 300),
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
                          todo != null
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
          } else {
            return Container(
              color: themePurple,
              height: screenHeight,
              padding: const EdgeInsets.fromLTRB(20, 40, 5, 20),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
