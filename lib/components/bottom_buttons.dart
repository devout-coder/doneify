import 'package:animations/animations.dart';
import 'package:doneify/components/filters_dialog.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/pages/input_modal.dart';
import 'package:flutter/material.dart';

class BottomButtons extends StatefulWidget {
  String time;
  String timeType;
  final Function loadTodos;
  final Function createTodo;
  bool tasksPage;

  BottomButtons({
    Key? key,
    required this.time,
    required this.timeType,
    required this.loadTodos,
    required this.createTodo,
    required this.tasksPage,
  }) : super(key: key);

  @override
  State<BottomButtons> createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<BottomButtons> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      //! bottom buttons
      child: Align(
        alignment: FractionalOffset.bottomRight,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 15, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: DateTime.now(),
                tooltip: "Choose label",
                onPressed: () {
                  showGeneralDialog(
                    //! select filter dialog box
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Choose filters",
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return Container();
                    },
                    transitionBuilder: (ctx, a1, a2, child) {
                      var curve = Curves.easeInOut.transform(a1.value);
                      return FiltersDialog(
                        curve: curve,
                        reloadTodos: widget.loadTodos(),
                        timeType: widget.timeType,
                        tasksPage: widget.tasksPage,
                        // currentFirst: currentFirst,
                        // ascending: ascending,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  );
                },
                backgroundColor:
                    Color.fromARGB(255, 48, 48, 48).withOpacity(0.9),
                child: const Icon(
                  Icons.filter_list,
                  size: 30,
                  color: Color.fromARGB(255, 206, 206, 206),
                ),
              ),
              const SizedBox(
                width: 35,
              ),
              OpenContainer(
                useRootNavigator: true,
                closedShape: const CircleBorder(),
                closedColor: themePurple.withOpacity(0.9),
                transitionDuration: const Duration(milliseconds: 500),
                closedBuilder: (context, action) {
                  return FloatingActionButton(
                    heroTag: DateTime.now(),
                    tooltip: "Add New Task",
                    onPressed: () {
                      action.call();
                    },
                    backgroundColor: themePurple.withOpacity(0.9),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: themeDarkPurple,
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return InputModal(
                    goBack: () => action.call(),
                    onCreate: widget.createTodo,
                    time: widget.time, //time
                    timeType: widget.timeType,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
