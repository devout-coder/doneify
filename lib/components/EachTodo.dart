import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:doneify/components/AddOrEditLabelDialog.dart';
import 'package:doneify/impClasses.dart';
import 'package:doneify/navigatorKeys.dart';
import 'package:doneify/pages/Day.dart';
import 'package:doneify/pages/InputModal.dart';
import 'package:doneify/pages/Month.dart';
import 'package:doneify/pages/Todos.dart';
import 'package:doneify/pages/Week.dart';
import 'package:doneify/pages/Year.dart';
import 'package:doneify/states/alarmDAO.dart';
import 'package:doneify/states/labelDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class EachTodo extends StatefulWidget {
  Todo todo;
  bool finished;
  bool? incompleteTodos;
  final Function editTodo;
  final Function deleteTodo;
  final Function? loadTodos;
  EachTodo({
    Key? key,
    this.incompleteTodos,
    required this.todo,
    required this.finished,
    required this.editTodo,
    required this.deleteTodo,
    this.loadTodos,
  }) : super(key: key);

  @override
  State<EachTodo> createState() => _EachTodoState();
}

Map findInMap(List<dynamic> maps, String key, String value) {
  Map reqMap = {};
  maps.forEach((map) {
    if (map[key] == value) {
      reqMap = map;
    }
  });
  return reqMap;
}

Future editAlarms(int todoId, bool val) async {
  AlarmDAO alarmsDB = GetIt.I.get();
  List<Alarm> alarms = await alarmsDB.getAlarms(todoId);

  List alarmIds = await platform.invokeMethod('getActiveIds');
  alarmIds = alarmIds.map((alarmId) => int.parse(alarmId)).toList();

  String activeAlarmsString = await platform.invokeMethod('getAllAlarms');
  List<dynamic> activeAlarms = jsonDecode(activeAlarmsString);

  alarms.forEach((alarm) {
    //an old alarm
    alarmsDB.deleteAlarm(alarm.alarmId);
    if (alarmIds.contains(alarm.alarmId)) {
      //alarm which isn't deleted
      Map activeAlarmMap =
          findInMap(activeAlarms, "alarmId", alarm.alarmId.toString());
      // debugPrint("activeAlarm : $activeAlarmMap");
      alarmsDB.setAlarm(
        alarm,
        activeAlarmMap["time"],
        activeAlarmMap["repeatEnd"],
        activeAlarmMap["taskId"],
        activeAlarmMap["taskName"],
        activeAlarmMap["taskDesc"],
        activeAlarmMap["label"],
        val,
      );
    }
  });
}

class _EachTodoState extends State<EachTodo> {
  LabelDAO labelsDB = GetIt.I.get();

  Color findLabelColor() {
    Color reqColor = Color(0xffffffff);
    labelsDB.labels.forEach((label) {
      if (label.name == widget.todo.labelName) {
        reqColor = stringToColor(label.color);
      }
    });
    // debugPrint(reqColor.toString());
    return reqColor;
  }

  bool isCurrentTime() {
    bool isCurrent = false;
    if (widget.todo.timeType == "day" &&
        widget.todo.time == formattedDate(DateTime.now())) {
      isCurrent = true;
    } else if (widget.todo.timeType == "week" &&
        widget.todo.time == formattedWeek(DateTime.now())) {
      isCurrent = true;
    } else if (widget.todo.timeType == "month" &&
        widget.todo.time == formattedMonth(DateTime.now())) {
      isCurrent = true;
    } else if (widget.todo.timeType == "year" &&
        widget.todo.time == formattedYear(DateTime.now())) {
      isCurrent = true;
    }
    return isCurrent;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.finished == widget.todo.finished
        ? OpenContainer<void>(
            useRootNavigator: true,
            transitionDuration: const Duration(milliseconds: 500),
            closedColor: Color.fromARGB(33, 255, 255, 255),
            closedBuilder: (context, action) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                margin: EdgeInsets.all(3),
                child: Row(
                  children: [
                    !widget.finished && widget.incompleteTodos == null
                        ? const Icon(
                            Icons.drag_indicator,
                            color: Color.fromARGB(255, 223, 223, 223),
                          )
                        : Container(),
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: findLabelColor(),
                      ),
                      child: Checkbox(
                        activeColor: widget.finished
                            ? Color.fromARGB(255, 109, 109, 109)
                            : findLabelColor(),
                        // checkColor: widget.finished
                        //     ? Color.fromARGB(255, 109, 109, 109)
                        //     : findLabelColor(),
                        checkColor: Colors.white,
                        // overlayColor:
                        //     MaterialStateProperty.all(findLabelColor()),
                        // fillColor: findLabelColor(),
                        value: widget.todo.finished,
                        onChanged: (val) {
                          widget.todo.finished = val!;
                          widget.editTodo(widget.todo);
                          editAlarms(widget.todo.id, val);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        widget.todo.taskName,
                        style: TextStyle(
                          fontFamily: "EuclidCircular",
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: widget.finished
                              ? Color.fromARGB(255, 130, 130, 130)
                              : findLabelColor(),
                          decoration: widget.finished
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      // flex: 1,
                      child: widget.incompleteTodos != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/todos",
                                        arguments: ScreenArguments(
                                            widget.todo.time,
                                            widget.todo.timeType))
                                    .whenComplete(() => widget.loadTodos!());
                              },
                              child: Text(
                                formattedDateTodosPage(
                                    widget.todo.time, widget.todo.timeType),
                                style: TextStyle(
                                  fontFamily: "EuclidCircular",
                                  fontWeight: isCurrentTime()
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  fontSize: 15,
                                  color: isCurrentTime()
                                      ? Color.fromARGB(255, 182, 182, 182)
                                      : Color.fromARGB(255, 130, 130, 130),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              );
            },
            openBuilder: (context, action) {
              return InputModal(
                goBack: () => action.call(),
                onEdit: widget.editTodo,
                onDelete: () {
                  widget.deleteTodo(widget.todo.id);
                  action.call();
                },
                // todoId: widget.todo.id,
                todo: widget.todo,
                time: widget.todo.time,
                timeType: widget.todo.timeType,
              );
            },
          )
        : Container();
  }
}
