import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/EachTodo.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
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

String formattedDateTodosPage(String date) {
  final DateTime dateTime = DateFormat('d/M/y').parse(date);
  final DateFormat formatter = DateFormat('d MMM');
  final String formatted = formatter.format(dateTime);
  return formatted;
}

class _TodosState extends State<Todos> {
  TodosDB todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();
  // List<String> selectedLabels = [];
  List<Todo> todos = [];
  List<Todo> unfinishedTodos = [];
  List<Todo> finishedTodos = [];

  final ScrollController unfinishedScrollController = ScrollController();
  final ScrollController finishedScrollController = ScrollController();

  loadTodos() async {
    var finder = Finder(
        filter: Filter.equals(
              'time',
              widget.time,
            ) &
            Filter.inList("labelName", selectedFilters.selectedLabels),
        sortOrders: [
          SortOrder("index"),
        ]);

    // debugPrint(selectedLabelsClass.selectedLabels.toString());
    final todosTemp = await todosdb.getAllTodos(finder);
    List<Todo> unfinishedTodosTemp = [];
    List<Todo> finishedTodosTemp = [];
    todosTemp.forEach((element) {
      if (element.finished) {
        finishedTodosTemp.add(element);
      } else {
        unfinishedTodosTemp.add(element);
      }
    });

    // debugPrint("todos");
    todosTemp.forEach(
        (element) => debugPrint("${element.taskName} ${element.index}"));
    // debugPrint("unfinished");
    // unfinishedTodosTemp.forEach((element) => debugPrint(element.taskName));
    // debugPrint("finished");
    // finishedTodosTemp.forEach((element) => debugPrint(element.taskName));

    setState(() {
      unfinishedTodos = unfinishedTodosTemp;
      finishedTodos = finishedTodosTemp;
      todos = todosTemp;
    });
  }

  createTodo(Todo todo) async {
    await todosdb.createTodo(todo);
    loadTodos();
  }

  editTodo(Todo todo) async {
    await todosdb.updateTodo(todo);
    loadTodos();
  }

  editTodoWithoutReload(Todo todo) async {
    await todosdb.updateTodo(todo);
  }

  deleteTodo(int todoIndex) async {
    todos.forEach((element) {
      if (element.index > todoIndex) {
        element.index--;
        editTodoWithoutReload(element);
      }
    });
    try {
      await todosdb.deleteTodo(todos[todoIndex].id);
      await loadTodos();
    } catch (e, s) {
      print("exception e");
      print("Stacktrace $s");
    }
  }

  rearrangeTodos(int oldIndex, int newIndex) async {
    // debugPrint("${oldIndex} ${newIndex}");
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
      todos.forEach((element) {
        if (element.index == oldIndex) {
          element.index = newIndex;
          editTodoWithoutReload(element);
        } else if (element.index > oldIndex && element.index <= newIndex) {
          element.index -= 1;
          editTodoWithoutReload(element);
        }
      });
    } else if (oldIndex > newIndex) {
      todos.forEach((element) {
        if (element.index == oldIndex) {
          element.index = newIndex;
          editTodoWithoutReload(element);
        } else if (element.index < oldIndex && element.index >= newIndex) {
          element.index += 1;
          editTodoWithoutReload(element);
        }
      });
    }
    List<Todo> _todos = todos;
    final Todo item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    setState(() {
      todos = _todos;
    });
  }

  @override
  void initState() {
    loadTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          formattedDateTodosPage(widget.time),
          style: const TextStyle(
              fontFamily: "EuclidCircular",
              fontWeight: FontWeight.w600,
              fontSize: 23,
              color: Color(0xffffffff)),
        ),
        SizedBox(
          height: 12,
        ),
        Flexible(
          flex: 7,
          child: Container(
            decoration: const BoxDecoration(
                // color: Colors.white,
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  width: screenWidth * 0.9,
                  height: unfinishedTodos.isNotEmpty && finishedTodos.isEmpty
                      ? screenHeight * 0.65
                      : unfinishedTodos.isNotEmpty
                          ? screenHeight * 0.34
                          : 0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(33, 255, 255, 255),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${unfinishedTodos.length} unfinished",
                        style: const TextStyle(
                          fontFamily: "EuclidCircular",
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Color(0xffC6C4C4),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        height: finishedTodos.isEmpty
                            ? screenHeight * 0.59
                            : screenHeight * 0.28,
                        width: screenWidth * 0.9,
                        child: Theme(
                          data: ThemeData(canvasColor: Colors.transparent),
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: unfinishedScrollController,
                            child: ReorderableListView(
                              onReorder: rearrangeTodos,
                              scrollController: unfinishedScrollController,
                              children: <Widget>[
                                for (Todo todo in todos)
                                  EachTodo(
                                    key: ValueKey(todo.id),
                                    todo: todo,
                                    editTodo: editTodo,
                                    deleteTodo: deleteTodo,
                                    finished: false,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  width: screenWidth * 0.9,
                  height: finishedTodos.isNotEmpty && unfinishedTodos.isEmpty
                      ? screenHeight * 0.65
                      : finishedTodos.isNotEmpty
                          ? screenHeight * 0.34
                          : 0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(33, 255, 255, 255),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${finishedTodos.length} finished",
                        style: const TextStyle(
                            fontFamily: "EuclidCircular",
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Color(0xffC6C4C4)),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: unfinishedTodos.isEmpty
                            ? screenHeight * 0.59
                            : screenHeight * 0.28,
                        width: screenWidth * 0.9,
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: unfinishedScrollController,
                          child: ListView.builder(
                              itemCount: finishedTodos.length,
                              controller: finishedScrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return EachTodo(
                                  todo: finishedTodos[index],
                                  editTodo: editTodo,
                                  deleteTodo: deleteTodo,
                                  finished: true,
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          //! bottom buttons
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
                        barrierDismissible: true,
                        barrierLabel: "Label filters",
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Container();
                        },
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return FiltersDialog(
                            curve: curve,
                            reloadTodos: loadTodos(),
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
                        addTodo: createTodo,
                        time: widget.time,
                        timeType: widget.timeType,
                        index: todos.length,
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
