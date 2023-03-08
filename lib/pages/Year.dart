import 'package:doneify/components/BottomButtons.dart';
import 'package:doneify/components/EachYearCell.dart';
import 'package:doneify/components/IncompleteTodos.dart';
import 'package:doneify/impClasses.dart';
import 'package:doneify/navigatorKeys.dart';
import 'package:doneify/pages/Todos.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/startTodos.dart';
import 'package:doneify/states/todoDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class YearlyPage extends StatelessWidget {
  const YearlyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class YearNavigator extends StatefulWidget {
  YearNavigator({Key? key}) : super(key: key);

  @override
  State<YearNavigator> createState() => _YearNavigatorState();
}

class _YearNavigatorState extends State<YearNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: yearNavigatorKey,
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
              return YearPage();
            },
          );
        }
      },
    );
  }
}

class YearPage extends StatefulWidget with GetItStatefulWidgetMixin {
  YearPage({Key? key}) : super(key: key);

  @override
  State<YearPage> createState() => _YearPageState();
}

String formattedYear(DateTime date) {
  final DateFormat formatter = DateFormat("y");
  final String formatted = formatter.format(date);
  return formatted;
}

class _YearPageState extends State<YearPage> with GetItStateMixin {
  String timeType = "year";
  final DateRangePickerController _controller = DateRangePickerController();

  TodoDAO todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();
  StartTodos startTodos = GetIt.I.get();

  List<Todo> todos = [];
  List<String> unfinishedYears = [];
  List<Todo> currentTodos = [];

  // bool currentFirst = false;
  // bool ascending = false;

  int comparingTodos(Todo todo1, Todo todo2) {
    DateTime time1 = DateFormat("y").parse(todo1.time);
    DateTime time2 = DateFormat("y").parse(todo2.time);
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
      unfinishedYears = [];
    });
    todosTemp.forEach((element) {
      if (element.time == formattedYear(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedYears.contains(element.time)) {
        List<String> tempUnfinishedYears = [...unfinishedYears, element.time];
        setState(() {
          unfinishedYears = tempUnfinishedYears;
        });
      }
    });
    if (selectedFilters.currentFirst) {
      todosTemp = todosTemp
          .where((element) => element.time != formattedYear(DateTime.now()))
          .toList();
    }

    currentTodosTemp
        .sort((Todo todo1, Todo todo2) => todo1.index.compareTo(todo2.index));
    todosTemp.sort(comparingTodos);
    if (selectedFilters.currentFirst) {
      todosTemp = [...currentTodosTemp, ...todosTemp];
    }

    setState(() {
      todos = todosTemp;
      currentTodos = currentTodosTemp;
    });
  }

  createTodo(Todo todo) async {
    await todosdb.createTodo(todo, false);
    loadTodos();
  }

  @override
  void initState() {
    loadTodos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool reloadTodos = watchX((StartTodos todos) => todos.reloadYearTodos);
    if (reloadTodos) {
      debugPrint("gotta reload");
      loadTodos();
      startTodos.reloadYearTodos.value = false;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 300,
          child: SfDateRangePicker(
            controller: _controller,
            view: DateRangePickerView.decade,
            initialSelectedDate: null,
            // onViewChanged: (args) {
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     if (args.view == DateRangePickerView.month) {
            //       _controller.view = DateRangePickerView.year;
            //     } else if (args.view == DateRangePickerView.year) {
            //       PickerDateRange dateRange = args.visibleDateRange;
            //       if (dateRange.startDate != null) {
            //         Navigator.pushNamed(context, "/todos",
            //                 arguments: ScreenArguments(
            //                     formattedYear(dateRange.startDate!), timeType))
            //             .whenComplete(() => loadTodos());
            //       }
            //     }
            //   });
            //   debugPrint(args.visibleDateRange.toString());
            // },
            allowViewNavigation: false,
            onSelectionChanged: (args) {
              if (_controller.selectedDate != null) {
                Navigator.pushNamed(context, "/todos",
                        arguments: ScreenArguments(
                            formattedYear(args.value), timeType))
                    .whenComplete(() => loadTodos());
              }
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
            headerHeight: 40,
            selectionColor: Colors.transparent,
            cellBuilder:
                (BuildContext context, DateRangePickerCellDetails details) {
              return EachYearCell(
                key: UniqueKey(),
                date: details.date,
                unfinishedYears: unfinishedYears,
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
          time: formattedYear(DateTime.now()),
          timeType: timeType,
          loadTodos: loadTodos,
          createTodo: createTodo,
          tasksPage: false,
        )
      ],
    );
  }
}
