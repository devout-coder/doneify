import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:flutter/material.dart';

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
            closedBuilder: (context, action) {
              return Row(
                children: [
                  Checkbox(
                    value: widget.todo.finished,
                    onChanged: (val) {
                      // setState(() {
                      widget.todo.finished = val!;
                      widget.editTodo(widget.todo);
                      // });
                    },
                  ),
                  Text(widget.todo.taskName),
                ],
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
