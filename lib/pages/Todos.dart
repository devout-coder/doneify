import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/BottomButtons.dart';
import 'package:conquer_flutter_app/components/EachTodo.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todoDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
// import 'package:animations/animations.dart';

import 'package:conquer_flutter_app/pages/Day.dart';
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

String formattedDateTodosPage(String time, String timeType) {
  if (timeType == 'day') {
    DateTime dateTime = DateFormat('d/M/y').parse(time);
    String formatted = DateFormat('d MMM').format(dateTime);
    return formatted;
  } else if (timeType == 'week') {
    List<String> bothDates = time.split('-');
    String startDateString = bothDates[0];
    String endDateString = bothDates[1];
    DateTime dateTime = DateFormat('d/M/y').parse(time);
    String formatted =
        "${DateFormat("d MMM").format(DateFormat("d/M/y").parse(startDateString))} - ${DateFormat("d MMM").format(DateFormat("d/M/y").parse(endDateString))}";

    return formatted;
  } else if (timeType == "longTerm") {
    return "Long Term";
  } else {
    return time;
  }
}

class _TodosState extends State<Todos> {
  TodoDAO todosdb = GetIt.I.get();
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
    // todosTemp.forEach(
    //     (element) => debugPrint("${element.taskName} ${element.index}"));
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

  deleteTodo(int todoId) async {
    try {
      await todosdb.deleteTodo(todoId);
      await loadTodos();
    } catch (e, s) {
      print("exception e");
      print("Stacktrace $s");
    }
  }

  rearrangeTodos(int oldIndex, int newIndex) async {
    // debugPrint("${oldIndex} ${newIndex}");
    newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    todosdb.rearrangeTodos(oldIndex, newIndex, widget.time);
    List<Todo> newTodos = todos;
    final Todo item = newTodos.removeAt(oldIndex);
    newTodos.insert(newIndex, item);
    setState(() {
      todos = newTodos;
    });
  }

  @override
  void initState() {
    // debugPrint(widget.time + widget.timeType);
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
          formattedDateTodosPage(widget.time, widget.timeType),
          style: const TextStyle(
            fontFamily: "EuclidCircular",
            fontWeight: FontWeight.w600,
            fontSize: 23,
            color: Color(0xffffffff),
          ),
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
                todos.isEmpty
                    ? Text(
                        "No tasks added yet",
                        style: const TextStyle(
                          fontFamily: "EuclidCircular",
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                          color: Color.fromARGB(255, 173, 219, 255),
                        ),
                      )
                    : Container(),
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
        BottomButtons(
          time: widget.time,
          timeType: widget.timeType,
          loadTodos: loadTodos,
          createTodo: createTodo,
          tasksPage: true,
        )
      ],
    );
  }
}
