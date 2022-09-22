import 'dart:ffi';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/initStates.dart';
import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:flutter/material.dart';
import 'package:conquer_flutter_app/pages/Home.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  runApp(const MyApp());
}

dynamic backgroundCallback(Uri? uri) async {
  debugPrint(uri.toString());
  // if (uri.host == 'todo_checked') {
    // debugPrint(uri.toString());
    // await HomeWidget.getWidgetData<int>('_counter', defaultValue: 0)
    //     .then((value) {
    //   _counter = value;
    //   _counter++;
    // });
    // await HomeWidget.saveWidgetData<int>('_counter', _counter);
    // await HomeWidget.updateWidget(
    //     name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  // }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final Future _init = GetItRegister().initializeGlobalStates();
  String? launchFromWidgetTimeType;
  String? launchFromWidgetCommand;

  MaterialColor purple = const MaterialColor(
    0xffe55f48, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: themePurple, //10%
      100: const Color(0xffa78ae6), //20%
      200: const Color(0xff957acc), //30%
      300: const Color(0xff826bb3), //40%
      400: const Color(0xff705c99), //50%
      500: const Color(0xff5d4d80), //60%
      600: const Color(0xff4a3d66), //70%kj
      700: const Color(0xff382e4c), //80%
      800: const Color(0xff382e4c), //90%
      900: const Color(0xff382e4c), //100%
    },
  );

  Future registerDB() async {
    await GetItRegister().initializeGlobalStates();
    LabelDB labelsDB = GetIt.I.get();
    SelectedFilters selectedFilters = GetIt.I.get();

    await selectedFilters.fetchFiltersFromStorage();
    await labelsDB.readLabelsFromStorage();
  }

  @override
  void initState() {
    super.initState();
  }

  createTodo(Todo todo) async {
    TodosDB todosdb = GetIt.I.get();
    await todosdb.createTodo(todo);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      String parsedURI = uri.toString().split("://")[1];
      String command = parsedURI.split("/")[0];
      String timeType = parsedURI.split("/")[1];
      debugPrint(command);
      debugPrint(timeType);
      setState(() {
        launchFromWidgetCommand = command;
        launchFromWidgetTimeType = timeType;
      });
      debugPrint("in main $timeType");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: "EuclidCircular",
      ),
      home: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff404049),
              Color(0xff09090E),
            ],
          ),
        ),
        child: Scaffold(
          body: Center(
              child: FutureBuilder(
                  future: registerDB(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (launchFromWidgetCommand == "add_todo") {
                        return Navigator(
                          onGenerateRoute: (RouteSettings settings) {
                            return MaterialPageRoute(builder: (context) {
                              return InputModal(
                                goBack: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(
                                      key: UniqueKey(),
                                      launchFromWidgetTimeType:
                                          launchFromWidgetTimeType,
                                      launchFromWidgetCommand:
                                          launchFromWidgetCommand,
                                    ),
                                  ),
                                ),
                                timeType: "day", //!hardcoded value
                                time: formattedDate(
                                    DateTime.now()), //!hardcoded value
                                index: 2, //!hardcoded value
                                addTodo: createTodo,
                              );
                            });
                          },
                        );
                      } else {
                        return HomePage(
                          key: UniqueKey(),
                          launchFromWidgetTimeType: launchFromWidgetTimeType,
                          launchFromWidgetCommand: launchFromWidgetCommand,
                        );
                      }
                    } else {
                      return const Material(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  })),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
