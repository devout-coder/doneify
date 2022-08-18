import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/components/IncompleteTodos.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/components/FiltersDialog.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DailyNavigator extends StatefulWidget {
  DailyNavigator({Key? key}) : super(key: key);

  @override
  State<DailyNavigator> createState() => _DailyNavigatorState();
}

class _DailyNavigatorState extends State<DailyNavigator> {
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
              return DailyPage();
            },
          );
        }
      },
    );
  }
}

class ScreenArguments {
  final String time;
  final String timeType;

  ScreenArguments(this.time, this.timeType);
}

class DailyPage extends StatefulWidget {
  DailyPage({Key? key}) : super(key: key);

  @override
  State<DailyPage> createState() => _DailyPageState();
}

String formattedDate(DateTime date) {
  final DateFormat formatter = DateFormat("d/M/y");
  final String formatted = formatter.format(date);
  return formatted;
}

class _DailyPageState extends State<DailyPage> {
  // CalendarFormat _calendarFormat = CalendarFormat.week;

  TodosDB todosdb = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();

  List<Todo> todos = [];
  List<String> unfinishedDates = [];
  List<Todo> currentTodos = [];

  // bool currentFirst = false;
  // bool ascending = false;

  int comparingDates(Todo todo1, Todo todo2) {
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
    // debugPrint(selectedLabelsClass.selectedLabels.toString());
    // debugPrint("todos loaded");
    debugPrint("loading...");
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
    setState(() {
      unfinishedDates = [];
    });
    todosTemp.forEach((element) {
      if (element.time == formattedDate(DateTime.now())) {
        currentTodosTemp.add(element);
      }
      if (!unfinishedDates.contains(element.time)) {
        List<String> tempUnfinishedDates = [...unfinishedDates, element.time];
        setState(() {
          unfinishedDates = tempUnfinishedDates;
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
    // DateTime now = new DateTime.now();
    // DateTime lastDayOfMonth = new DateTime(now.year, now.month + 1, 0);
    // debugPrint("${lastDayOfMonth.month}/${lastDayOfMonth.day}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2099, 12, 31),
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            leftChevronIcon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xff9A9A9A),
            ),
            rightChevronIcon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xff9A9A9A),
            ),
            titleCentered: true,
            titleTextStyle: TextStyle(
                fontFamily: "EuclidCircular",
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color(0xffffffff)),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Color(0xffEADA76)),
            weekendStyle: TextStyle(color: Color(0xffEADA76)),
          ),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: TextStyle(
              color: Color(0xffFFFFFF),
            ),
            holidayTextStyle: TextStyle(
              color: Color(0xffFFFFFF),
            ),
            weekendTextStyle: TextStyle(
              color: Color(0xffFFFFFF),
            ),
            outsideTextStyle: TextStyle(
              color: Color(0xff797979),
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xffBA99FF),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Color.fromARGB(255, 47, 15, 83),
              fontWeight: FontWeight.w600,
            ),
          ),
          eventLoader: (DateTime date) {
            if (unfinishedDates.contains(formattedDate(date))) {
              List<String> shit = ["todo"];
              return shit;
            } else {
              return [];
            }
          },
          calendarBuilders: CalendarBuilders(
            singleMarkerBuilder: (context, date, _) {
              return Container(
                margin: EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 255, 29, 29),
                  ), //Change color
                  width: 7,
                  height: 7,
                ),
              );
            },
          ),
          onDaySelected: (focussedDay, selectedDay) {
            Navigator.pushNamed(context, "/todos",
                    arguments:
                        ScreenArguments(formattedDate(selectedDay), "day"))
                .whenComplete(() => loadTodos());
          },
        ),
        IncompleteTodos(
          timeType: "day",
          todos: todos,
          loadTodos: loadTodos,
        ),
        Expanded(
          //! bottom buttons
          child: Align(
            alignment: FractionalOffset.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 15, 5),
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
                        barrierLabel: "Choose filters",
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
                            homePage: true,
                            // currentFirst: currentFirst,
                            // ascending: ascending,
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
                        time: formattedDate(DateTime.now()),
                        timeType: "day",
                        index: currentTodos.length,
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
