import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/LabelsFilterDialog.dart';
import 'package:conquer_flutter_app/database/todos_db.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedLabelsFilter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
// import 'package:animations/animations.dart';

import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

class Todos extends StatefulWidget {
  static const routeName = '/todos';
  final String time;
  final String timeType;
  const Todos({Key? key, required this.time, required this.timeType})
      : super(key: key);

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  TodosDB _todosdb = GetIt.I.get();
  SelectedLabel selectedLabelsClass = GetIt.I.get();
  // List<String> selectedLabels = [];
  List<Todo> _todos = [];

  _loadTodos() async {
    var finder = Finder(
        filter: Filter.equals(
              'time',
              widget.time,
            ) &
            Filter.inList("labelName", selectedLabelsClass.selectedLabels),
        sortOrders: [
          SortOrder("index"),
        ]);
    final todos = await _todosdb.getAllTodos(finder);
    setState(() => _todos = todos);
    debugPrint("this is runagain");
    // todos.forEach(
    //     (element) => debugPrint(element.taskName + " " + element.labelName));
  }

  _createTodo(Todo todo) async {
    await _todosdb.createTodo(todo);
    _loadTodos();
  }

  _editTodo(Todo todo) async {
    await _todosdb.updateTodo(todo);
    _loadTodos();
  }

  _deleteTodo(int todoId) async {
    try {
      await _todosdb.deleteTodo(todoId);
      await _loadTodos();
    } catch (e, s) {
      print("exception e");
      print("Stacktrace $s");
    }
  }

  String formattedDate() {
    final DateTime dateTime = DateFormat('d/M/y').parse(widget.time);
    final DateFormat formatter = DateFormat('d MMM');
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  Widget eachTodo(int index) {
    return OpenContainer(
      useRootNavigator: true,
      // closedShape: const CircleBorder(),
      // closedColor: const Color(0xffBA99FF).withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (context, action) {
        return Row(
          children: [
            Text(_todos.elementAt(index).taskName),
            // IconButton(
            //   tooltip: "Delete tag",
            //   onPressed: () {
            //     _deleteTodo(_todos.elementAt(index).id);
            //   },
            //   icon: const Icon(
            //     Icons.delete,
            //     color: Color.fromARGB(255, 99, 99, 99),
            //   ),
            // ),
          ],
        );
      },
      openBuilder: (context, action) {
        return InputModal(
          action: action,
          editTodo: _editTodo,
          onDelete: () {
            _deleteTodo(_todos.elementAt(index).id);
            action.call();
          },
          todo: _todos.elementAt(index),
          time: widget.time,
          timeType: widget.timeType,
        );
      },
    );
  }

  @override
  void initState() {
    _loadTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          // width: screenWidth * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(
              //   width: 60,
              // ),
              Text(
                formattedDate(),
                style: const TextStyle(
                    fontFamily: "EuclidCircular",
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xffffffff)),
              ),
              //   const SizedBox(
              //     width: 20,
              //   ),
              //   IconButton(
              //     onPressed: () {},
              //     tooltip: "Sort by category",
              //     icon: const Icon(
              //       Icons.filter_list,
              //       color: Color(0xffE2DDFF),
              //       size: 30,
              //     ),
              //   ),
            ],
          ),
        ),
        Container(
          height: screenHeight * 0.6,
          width: screenWidth * 0.9,
          child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (BuildContext context, int index) {
                _todos.forEach((element) {
                  debugPrint("In todos: " + element.taskName);
                });
                return eachTodo(
                  index,
                );
              }),
        ),
        Expanded(
          //! add button
          child: Align(
            alignment: FractionalOffset.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    tooltip: "Choose label",
                    onPressed: () {
                      showGeneralDialog(
                        //! select filter dialog box
                        context: context,
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Container();
                        },
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return LabelsFilterDialog(
                            curve: curve,
                            reloadTodos: _loadTodos(),
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
                    closedColor: const Color(0xffBA99FF).withOpacity(0.9),
                    transitionDuration: const Duration(milliseconds: 500),
                    closedBuilder: (context, action) {
                      return FloatingActionButton(
                        tooltip: "Add New Task",
                        onPressed: () {
                          action.call();
                        },
                        backgroundColor:
                            const Color(0xffBA99FF).withOpacity(0.9),
                        child: const Icon(
                          Icons.add,
                          size: 30,
                          color: Color.fromARGB(255, 47, 15, 83),
                        ),
                      );
                    },
                    openBuilder: (context, action) {
                      return InputModal(
                        action: action,
                        addTodo: _createTodo,
                        time: widget.time,
                        timeType: widget.timeType,
                        index: _todos.length,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
