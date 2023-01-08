import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/BottomButtons.dart';
import 'package:conquer_flutter_app/components/EachDayCell.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/components/IncompleteTodos.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/states/startTodos.dart';
import 'package:conquer_flutter_app/states/todoDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';

class DayNavigator extends StatefulWidget {
  DayNavigator({Key? key}) : super(key: key);

  @override
  State<DayNavigator> createState() => _DayNavigatorState();
}

class _DayNavigatorState extends State<DayNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: dayNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        // Cast the arguments to the correct
        // type: ScreenArguments.
        if (settings.name == "/todos") {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return Todos(time: args.time, timeType: args.timeType);
            },
          );
        } else {
          return MaterialPageRoute(
            builder: (context) {
              return DayPage();
            },
          );
        }
      },
    );
  }
}

class DayPage extends StatefulWidget {
  DayPage({Key? key}) : super(key: key);

  @override
  State<DayPage> createState() => _DayPageState();
}

String formattedDate(DateTime date) {
  final DateFormat formatter = DateFormat("d/M/y");
  final String formatted = formatter.format(date);
  return formatted;
}

class _DayPageState extends State<DayPage> {
  String timeType = "day";
  final DateRangePickerController _controller = DateRangePickerController();

  TodoDAO todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();
  StartTodos startTodos = GetIt.I.get();

  List<Todo> todos = [];
  List<String> unfinishedDays = [];
  List<Todo> currentTodos = [];

  // bool currentFirst = false;
  // bool ascending = false;

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
    var finder = Finder(
      filter: Filter.equals(
            'timeType',
            timeType,
          ) &
          Filter.inList("labelName", selectedFilters.selectedLabels) &
          Filter.equals('finished', false),
    );
    List<Todo> todosTemp = await todosdb.getAllTodos(finder);
    List<Todo> currentTodosTemp = [];
    setState(() {
      unfinishedDays = [];
    });
    todosTemp.forEach((element) {
      if (element.time == formattedDate(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedDays.contains(element.time)) {
        List<String> tempUnfinishedDates = [...unfinishedDays, element.time];
        setState(() {
          unfinishedDays = tempUnfinishedDates;
        });
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

    setState(() {
      todos = todosTemp;
      currentTodos = currentTodosTemp;
    });
  }

  createTodo(Todo todo) async {
    await todosdb.createTodo(todo);
    loadTodos();
  }

  @override
  void initState() {
    _controller.selectedDate = null;
    todos = startTodos.todos;
    currentTodos = startTodos.currentTodos;
    unfinishedDays = startTodos.unfinishedDays;
    // debugPrint("todos: $todos");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 330,
          child: SfDateRangePicker(
            controller: _controller,
            initialSelectedDate: null,
            headerStyle: const DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontFamily: "EuclidCircular",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xffffffff),
              ),
            ),
            monthViewSettings: const DateRangePickerMonthViewSettings(
              viewHeaderStyle: DateRangePickerViewHeaderStyle(
                textStyle: TextStyle(color: Color(0xffEADA76)),
              ),
              firstDayOfWeek: 1,
            ),
            todayHighlightColor: Color(0xffEADA76),
            headerHeight: 40,
            selectionColor: Colors.transparent,
            onSelectionChanged: (args) {
              if (_controller.selectedDate != null) {
                Navigator.pushNamed(context, "/todos",
                        arguments: ScreenArguments(
                            formattedDate(args.value), timeType))
                    .whenComplete(() => loadTodos());
              }
            },
            cellBuilder:
                (BuildContext context, DateRangePickerCellDetails details) {
              return EachDayCell(
                key: UniqueKey(),
                date: details.date,
                unfinishedDays: unfinishedDays,
                currentView: _controller.view,
              );
            },
          ),
        ),
        IncompleteTodos(
          timeType: timeType,
          todos: todos,
          loadTodos: loadTodos,
        ),
        BottomButtons(
          time: formattedDate(DateTime.now()),
          timeType: timeType,
          loadTodos: loadTodos,
          createTodo: createTodo,
          tasksPage: false,
        )
      ],
    );
  }
}
