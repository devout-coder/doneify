import 'package:conquer_flutter_app/components/BottomButtons.dart';
import 'package:conquer_flutter_app/components/EachMonthCell.dart';
import 'package:conquer_flutter_app/components/IncompleteTodos.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class MonthNavigator extends StatefulWidget {
  MonthNavigator({Key? key}) : super(key: key);

  @override
  State<MonthNavigator> createState() => _MonthNavigatorState();
}

class _MonthNavigatorState extends State<MonthNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: monthNavigatorKey,
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
              return MonthPage();
            },
          );
        }
      },
    );
  }
}

class MonthPage extends StatefulWidget {
  const MonthPage({Key? key}) : super(key: key);

  @override
  State<MonthPage> createState() => _MonthPageState();
}

String formattedMonth(DateTime date) {
  final DateFormat formatter = DateFormat("MMM y");
  final String formatted = formatter.format(date);
  return formatted;
}

class _MonthPageState extends State<MonthPage> {
  String timeType = "month";
  final DateRangePickerController _controller = DateRangePickerController();

  TodosDB todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();

  List<Todo> todos = [];
  List<String> unfinishedMonths = [];
  List<Todo> currentTodos = [];

  // bool currentFirst = false;
  // bool ascending = false;

  int comparingDates(Todo todo1, Todo todo2) {
    DateTime time1 = DateFormat("MMM y").parse(todo1.time);
    DateTime time2 = DateFormat("MMM y").parse(todo2.time);
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
    // debugPrint(selectedLabelsClass.selectedLabels.toString());
    // debugPrint("todos loaded");
    // debugPrint("loading...");
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
      unfinishedMonths = [];
    });
    todosTemp.forEach((element) {
      if (element.time == formattedMonth(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedMonths.contains(element.time)) {
        List<String> tempUnfinishedDates = [...unfinishedMonths, element.time];
        setState(() {
          unfinishedMonths = tempUnfinishedDates;
        });
      }
    });
    if (selectedFilters.currentFirst) {
      todosTemp = todosTemp
          .where((element) => element.time != formattedMonth(DateTime.now()))
          .toList();
    }

    currentTodosTemp
        .sort((Todo todo1, Todo todo2) => todo1.index.compareTo(todo2.index));
    todosTemp.sort(comparingDates);
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 300,
          child: SfDateRangePicker(
            controller: _controller,
            view: DateRangePickerView.year,
            initialSelectedRange: null,
            // onViewChanged: (args) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     if (args.view == DateRangePickerView.month) {
            //       _controller.view = DateRangePickerView.year;
            //     } else if (args.view == DateRangePickerView.year) {
            //       PickerDateRange dateRange = args.visibleDateRange;
            //       if (dateRange.startDate != null) {
            //         Navigator.pushNamed(context, "/todos",
            //                 arguments: ScreenArguments(
            //                     formattedMonth(dateRange.startDate!), timeType))
            //             .whenComplete(() => loadTodos());
            //       }
            //     }
            //   });
            //   debugPrint(args.visibleDateRange.toString());
            // },
            allowViewNavigation: false,
            onSelectionChanged: (args) {
              Navigator.pushNamed(context, "/todos",
                      arguments:
                          ScreenArguments(formattedMonth(args.value), timeType))
                  .whenComplete(() => loadTodos());
            },
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
            cellBuilder:
                (BuildContext context, DateRangePickerCellDetails details) {
              return EachMonthCell(
                key: UniqueKey(),
                date: details.date,
                unfinishedMonths: unfinishedMonths,
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
          time: formattedMonth(DateTime.now()),
          timeType: timeType,
          index: currentTodos.length,
          loadTodos: loadTodos,
          createTodo: createTodo,
        )
      ],
    );
  }
}
