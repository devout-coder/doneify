import 'package:conquer_flutter_app/components/EachTodo.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class IncompleteTodos extends StatefulWidget {
  final String timeType;
  List<Todo> todos;
  final Function loadTodos;
  IncompleteTodos({
    Key? key,
    required this.timeType,
    required this.todos,
    required this.loadTodos,
  }) : super(key: key);

  @override
  State<IncompleteTodos> createState() => _IncompleteTodosState();
}

class _IncompleteTodosState extends State<IncompleteTodos> {
  List<Todo> todosOfSameTime = [];

  final ScrollController unfinishedScrollController = ScrollController();

  bool scrolledUp = false;

  TodosDB todosdb = GetIt.I.get();

  editTodo(Todo todo) async {
    await todosdb.updateTodo(todo);
    widget.loadTodos();
  }

  editTodoWithoutReload(Todo todo) async {
    await todosdb.updateTodo(todo);
  }

  deleteTodo(int todoId) async {
    try {
      await todosdb.deleteTodo(todoId);
      await widget.loadTodos();
    } catch (e, s) {
      print("exception e");
      print("Stacktrace $s");
    }
  }

  

  // @override
  // void initState() {
  //   widget.loadTodos();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      width: screenWidth * 0.9,
      height: scrolledUp ? screenHeight * 0.9 : screenHeight * 0.39,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(33, 255, 255, 255),
      ),
      child: Column(
        children: [
          Text(
            "${widget.todos.length} unfinished",
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
          Container(
            height: scrolledUp ? 0.85 * screenHeight : 0.33 * screenHeight,
            width: screenWidth * 0.9,
            child: Theme(
              data: ThemeData(canvasColor: Colors.transparent),
              child: Scrollbar(
                thumbVisibility: true,
                controller: unfinishedScrollController,
                child: ListView.builder(
                    itemCount: widget.todos.length,
                    controller: unfinishedScrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return EachTodo(
                        todo: widget.todos[index],
                        editTodo: editTodo,
                        deleteTodo: deleteTodo,
                        loadTodos: widget.loadTodos,
                        finished: false,
                        incompleteTodos: true,
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
