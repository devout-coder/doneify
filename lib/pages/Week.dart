import 'package:conquer_flutter_app/components/BottomButtons.dart';
import 'package:conquer_flutter_app/components/EachWeekCell.dart';
import 'package:conquer_flutter_app/components/IncompleteTodos.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class WeekNavigator extends StatefulWidget {
  WeekNavigator({Key? key}) : super(key: key);

  @override
  State<WeekNavigator> createState() => _WeekNavigatorState();
}

class _WeekNavigatorState extends State<WeekNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: weekNavigatorKey,
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
              return WeekPage();
            },
          );
        }
      },
    );
  }
}

class WeekPage extends StatefulWidget {
  WeekPage({Key? key}) : super(key: key);

  @override
  State<WeekPage> createState() => _WeekPageState();
}

String formattedWeek(DateTime day) {
  DateTime startDate = day.subtract(Duration(days: day.weekday - 1));
  DateTime endDate = startDate.add(Duration(days: 6));
  String formattedString =
      "${formattedDate(startDate)}-${formattedDate(endDate)}";
  return formattedString;
}

class _WeekPageState extends State<WeekPage> {
  String timeType = "week";
  final DateRangePickerController _controller = DateRangePickerController();

  TodosDB todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();

  List<Todo> todos = [];
  List<String> unfinishedWeeks = [];
  List<Todo> currentTodos = [];

  int comparingTodos(Todo todo1, Todo todo2) {
    DateTime time1 = DateFormat("d/M/y").parse(todo1.time.split("-")[0]);
    DateTime time2 = DateFormat("d/M/y").parse(todo2.time.split("-")[0]);
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
    _controller.selectedDate = null;
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
      unfinishedWeeks = [];
    });
    todosTemp.forEach((element) {
      if (element.time == formattedWeek(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedWeeks.contains(element.time)) {
        List<String> tempUnfinishedWeeks = [...unfinishedWeeks, element.time];
        setState(() {
          unfinishedWeeks = tempUnfinishedWeeks;
        });
      }
    });
    if (selectedFilters.currentFirst) {
      todosTemp = todosTemp
          .where((element) => element.time != formattedWeek(DateTime.now()))
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
    loadTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                            formattedWeek(args.value), timeType))
                    .whenComplete(() => loadTodos());
              }
            },
            cellBuilder:
                (BuildContext context, DateRangePickerCellDetails details) {
              return EachWeekCell(
                key: UniqueKey(),
                date: details.date,
                unfinishedWeeks: unfinishedWeeks,
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
          time: formattedWeek(DateTime.now()),
          timeType: timeType,
          index: currentTodos.length,
          loadTodos: loadTodos,
          createTodo: createTodo,
        )
      ],
    );
  }
}
