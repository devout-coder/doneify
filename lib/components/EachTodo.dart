import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/AddOrEditLabelDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EachTodo extends StatefulWidget {
  Todo todo;
  bool finished;
  final Function editTodo;
  final Function deleteTodo;
  EachTodo({
    Key? key,
    required this.todo,
    required this.finished,
    required this.editTodo,
    required this.deleteTodo,
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
    debugPrint(reqColor.toString());
    return reqColor;
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
                // padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(3),
                child: Row(
                  children: [
                    !widget.finished
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
                    Text(
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
                    )
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
