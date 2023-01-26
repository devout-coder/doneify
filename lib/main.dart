import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:conquer_flutter_app/components/EachTodo.dart';
import 'package:conquer_flutter_app/dartMethodCalls.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/states/initStates.dart';
import 'package:conquer_flutter_app/states/labelDAO.dart';
import 'package:conquer_flutter_app/states/nudgerState.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/startTodos.dart';
import 'package:conquer_flutter_app/states/todoDAO.dart';
import 'package:conquer_flutter_app/timeFuncs.dart';
import 'package:flutter/material.dart';
import 'package:conquer_flutter_app/pages/Home.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

final channel = MethodChannel('alarm_method_channel');

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // HomeWidget.registerBackgroundCallback(
  //     backgroundCallback); //replace this with method channel
  runApp(MyApp());
}

Future registerDB() async {
  await GetItRegister().initializeGlobalStates();
  LabelDAO labelsDB = GetIt.I.get();
  SelectedFilters selectedFilters = GetIt.I.get();
  StartTodos startTodos = GetIt.I.get();

  //don't fuck up this order
  await selectedFilters.fetchFiltersFromStorage();
  await labelsDB.readLabelsFromStorage();
  await startTodos.loadTodos();

  NudgerStates nudgerStates = GetIt.I.get();
  nudgerStates.fetchNudgerStates();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void handleKotlinEvents() async {
    channel.setMethodCallHandler((call) async {
      // debugPrint( //     "call received method ${call.method} argument ${call.arguments}");
      kotlinMethodCallHandler(call);
      return Future<dynamic>.value();
    });
  }

  @override
  void initState() {
    handleKotlinEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: "EuclidCircular",
      ),
      onGenerateRoute: (RouteSettings settings) {
        String? entirePath = settings.name;
        return MaterialPageRoute(
          builder: (context) => MainContainer(
            entirePath: entirePath ?? "/",
          ),
        );
      },
    );
  }
}

class MainContainer extends StatefulWidget {
  String entirePath;
  MainContainer({super.key, required this.entirePath});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer>
    with WidgetsBindingObserver {
  String? path;
  String? timeType;
  int? todoId;

  @override
  void initState() {
    // debugPrint("entire path ${widget.entirePath}");
    path = widget.entirePath.split("?")[0];

    if (path == "/createInputModal") {
      timeType = widget.entirePath.split("?")[1];
    } else if (path == "/editInputModal") {
      todoId = int.parse(widget.entirePath.split("?")[1]);
    }
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        // print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        // String dbPath = 'conquer.db';
        // final appDocDir = await getApplicationDocumentsDirectory();
        // Database db = await databaseFactoryIo
        //     .openDatabase(join(appDocDir.path, dbPath), version: 1);
        // final StoreRef _store = intMapStoreFactory.store("todos");

        // var finder = Finder(
        //     filter: Filter.equals(
        //   'timeType',
        //   "day",
        // ));
        // final snapshots = await _store.find(db, finder: finder);
        // List<Todo> todos = snapshots
        //     .map((snapshot) => Todo.fromMap(snapshot.value))
        //     .toList(growable: true);
        // todos.forEach((element) {
        //   debugPrint("todo: ${element.taskName}");
        // });

        bool widgetChanged = await platform.invokeMethod("getWidgetChanged");
        debugPrint("in dart, $widgetChanged");
        if (widgetChanged) {
          bool receivedVal = await platform
              .invokeMethod("setWidgetChanged", {"widgetChanged": false});
          debugPrint("in dart set val, $receivedVal");
          Restart.restartApp();
        }
        // String received = await platform.invokeMethod('get_edited_from_widget');
        // debugPrint("received in main $received");
        // if (received == "true") {
        // platform.invokeMethod("edited_from_widget", {"val": false});
        // }

        break;
      case AppLifecycleState.paused:
        // print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        // print('appLifeCycleState detached');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        resizeToAvoidBottomInset: false,
        body: Center(
            child: FutureBuilder(
                future: registerDB(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    TodoDAO todosdb = GetIt.I.get();
                    switch (path) {
                      case '/createInputModal':
                        return WillPopScope(
                          onWillPop: () async {
                            debugPrint("going back");
                            SystemChannels.platform
                                .invokeMethod<void>('SystemNavigator.pop');
                            return false;
                          },
                          child: InputModal(
                            goBack: () {
                              SystemChannels.platform.invokeMethod<void>(
                                  'SystemNavigator.pop'); // debugPrint("entire path $entirePath");
                            },
                            loadedFromWidget: true,
                            timeType: timeType!,
                            time: formattedTime(timeType!, DateTime.now()),
                            onCreate: (Todo todo) async {
                              await todosdb.createTodo(todo);
                              bool receivedVal = await platform.invokeMethod(
                                  "setWidgetChanged", {"widgetChanged": true});
                              debugPrint("in dart set val, $receivedVal");
                            },
                          ),
                        );
                      case "/editInputModal":
                        // debugPrint(
                        //     "todoId $todoId time $time timeType $timeType");
                        return WillPopScope(
                          onWillPop: () async {
                            debugPrint("going back");
                            SystemChannels.platform
                                .invokeMethod<void>('SystemNavigator.pop');
                            return false;
                          },
                          child: InputModal(
                            goBack: () {
                              SystemChannels.platform
                                  .invokeMethod<void>('SystemNavigator.pop');
                            },
                            todoId: todoId!,
                            loadedFromWidget: true,
                            onEdit: (Todo todo) async {
                              await todosdb.updateTodo(todo);
                              bool receivedVal = await platform.invokeMethod(
                                  "setWidgetChanged", {"widgetChanged": true});
                              debugPrint("in dart set val, $receivedVal");
                            },
                            onDelete: () async {
                              // debugPrint(
                              //     "this gets run even if i don't want it to");
                              // platform.invokeMethod(
                              //     "edited_from_widget", {"val": true});
                              await todosdb.deleteTodo(todoId!);
                              bool receivedVal = await platform.invokeMethod(
                                  "setWidgetChanged", {"widgetChanged": true});
                              debugPrint("in dart set val, $receivedVal");
                              SystemChannels.platform
                                  .invokeMethod<void>('SystemNavigator.pop');
                            },
                          ),
                        );
                      case "/":
                        return HomePage(key: UniqueKey());
                      default:
                        debugPrint("default contianer");
                        return HomePage(
                            // key: UniqueKey()
                            );
                    }
                  } else {
                    return Container(
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                })),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
