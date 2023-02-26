import 'package:doneify/impClasses.dart';
import 'package:doneify/pages/Day.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/todoDAO.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:intl/intl.dart';

class StartTodos {
  //already loading the day todos so that after circular progress stops there is no delay before the todos are shown
  List<Todo> todos = [];
  List<Todo> currentTodos = [];
  List<String> unfinishedDays = [];

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

  loadTodos() async {
    // debugPrint("todos loaded");
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
    // todosTemp.forEach(
    //     (element) => debugPrint("${element.taskName} ${element.index}"));
    // debugPrint("unfinished");
    // unfinishedTodosTemp.forEach((element) => debugPrint(element.taskName));
    // debugPrint("finished");
    // finishedTodosTemp.forEach)((element) => debugPrint(element.taskName));
    todos = todosTemp;
    currentTodos = currentTodosTemp;
  }
}
