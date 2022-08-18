import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
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

class _EachTodoState extends State<EachTodo> {
  LabelDB labelsDB = GetIt.I.get();

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
    if (widget.todo.time == formattedDate(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.finished == widget.todo.finished
        ? OpenContainer(
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
                    Expanded(
                      flex: 1,
                      child: widget.incompleteTodos != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/todos",
                                        arguments: ScreenArguments(
                                            widget.todo.time, "day"))
                                    .whenComplete(() => widget.loadTodos!());
                              },
                              child: Text(
                                formattedDateTodosPage(widget.todo.time),
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
                action: action,
                editTodo: widget.editTodo,
                onDelete: () {
                  widget.deleteTodo(widget.todo.index);
                  action.call();
                },
                todo: widget.todo,
                time: widget.todo.time,
                timeType: widget.todo.timeType,
              );
            },
          )
        : Container();
  }
}