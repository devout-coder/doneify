import 'dart:convert';

import 'package:doneify/ip.dart';
import 'package:doneify/states/authState.dart';
import 'package:http/http.dart' as http;
import 'package:doneify/impClasses.dart';
import 'package:doneify/pages/day.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/todoDAO.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartTodos {
  //already loading the day todos so that after circular progress stops there is no delay before the todos are shown
  //index fuck up
  List<Todo> todos = [];
  List<Todo> currentTodos = [];
  List<String> unfinishedDays = [];

  final reloadDayTodos = ValueNotifier<bool>(false);
  final reloadWeekTodos = ValueNotifier<bool>(false);
  final reloadMonthTodos = ValueNotifier<bool>(false);
  final reloadYearTodos = ValueNotifier<bool>(false);
  final reloadLongTermTodos = ValueNotifier<bool>(false);
  final reloadTodos = ValueNotifier<String>("");

  SelectedFilters selectedFilters = GetIt.I.get();

  int comparingTodos(Todo todo1, Todo todo2) {
    DateTime time1 = DateFormat("d/M/y").parse(todo1.time);
    DateTime time2 = DateFormat("d/M/y").parse(todo2.time);
    int compared = selectedFilters.ascending
        ? time1.compareTo(time2)
        : time2.compareTo(time1);
    if (compared == 0) {
      return todo1.index - todo2.index;
    } else {
      return compared;
    }
  }

  Future fetchOnlineTodos() async {
    AuthState auth = GetIt.I.get();
    TodoDAO todosdb = GetIt.I.get();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastOfflineUpdated = prefs.getInt('lastOfflineUpdated');
    // debugPrint("offline db was updated at $lastOfflineUpdated");
    debugPrint("user is ${auth.user.value!.token}");

    if (auth.user.value != null) {
      var response = await http.get(
        Uri.parse("$serverUrl/todos/$lastOfflineUpdated"),
        headers: {
          "Content-Type": "application/json",
          "authorization": auth.user.value!.token
        },
      );
      // debugPrint("todos reponse is ${response.body}");
      Map body = json.decode(response.body);
      if (body["message"] != "offline db up to date") {
        List newTodoList = body["todos"];
        List deletedTodoList = body["deletedTodos"];
        debugPrint("all todos are: $newTodoList");
        // debugPrint("deleted todos are: $deletedTodoMap");

        // List<Todo> newTodos = [];
        for (Map each in newTodoList) {
          debugPrint("each todo is $each");
          Todo todo = Todo.fromMap(each);
          Todo? todoFromDb = await todosdb.getTodo(todo.id);
          if (todoFromDb == null) {
            debugPrint("gotta create ${todo.taskName}");
            await todosdb.createTodo(todo, true);
          } else {
            debugPrint("gotta update ${todo.taskName}");
            await todosdb.updateTodo(todo, true);
          }
        }
        for (Map each in deletedTodoList) {
          int id = each["_id"];
          debugPrint("gotta delete $id");
          await todosdb.deleteTodo(id, true);
          // Todo todo = Todo.fromMap(each);
          // newTodos.add(todo);
        }
        // debugPrint("todos reponse ${todos}");
      }
    }
  }

  loadTodos() async {
    await fetchOnlineTodos();
    TodoDAO todosdb = GetIt.I.get();

    var finder = Finder(
      filter: Filter.equals(
            'timeType',
            "day",
          ) &
          Filter.inList("labelName", selectedFilters.selectedLabels) &
          Filter.equals('finished', false),
    );
    List<Todo> todosTemp = await todosdb.getAllTodos(finder);
    List<Todo> currentTodosTemp = [];
    todosTemp.forEach((element) {
      if (element.time == formattedDate(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedDays.contains(element.time)) {
        List<String> tempUnfinishedDates = [...unfinishedDays, element.time];
        unfinishedDays = tempUnfinishedDates;
      }
    });
    if (selectedFilters.currentFirst) {
      todosTemp = todosTemp
          .where((element) => element.time != formattedDate(DateTime.now()))
          .toList();
    }

    currentTodosTemp
        .sort((Todo todo1, Todo todo2) => todo1.index.compareTo(todo2.index));
    todosTemp.sort(comparingTodos);
    if (selectedFilters.currentFirst) {
      todosTemp = [...currentTodosTemp, ...todosTemp];
    }
    todosTemp.forEach(
        (element) => debugPrint("${element.taskName} ${element.index}"));
    // debugPrint("unfinished");
    // unfinishedTodosTemp.forEach((element) => debugPrint(element.taskName));
    // debugPrint("finished");
    // finishedTodosTemp.forEach)((element) => debugPrint(element.taskName));
    todos = todosTemp;
    currentTodos = currentTodosTemp;
  }
}
