import 'dart:convert';
import 'dart:io' show Platform;
import 'package:doneify/impClasses.dart';
import 'package:doneify/ip.dart';
import 'package:doneify/pages/home.dart';
import 'package:doneify/states/alarmDAO.dart';
import 'package:doneify/states/authState.dart';
import 'package:doneify/states/labelDAO.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sembast/sembast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoDAO {
  final Database _db = GetIt.I.get();

  final StoreRef _store = intMapStoreFactory.store("todos");
  static const platform = MethodChannel('alarm_method_channel');

  Future syncOnlineDBOnLogin() async {
    // debugPrint("this is run");
    LabelDAO labelDAO = GetIt.I.get();
    AuthState auth = GetIt.I.get();

    List<Todo> allTodos = await getAllTodos(Finder());
    List<Label> allLabels = labelDAO.labels;
    // debugPrint("all labels should be $allLabels");

    List<Map> allTodosMap = [];
    List<Map> allLabelsMap = [];
    for (Todo todo in allTodos) {
      Map newTodo = {
        "id": todo.id.toString(),
        "taskName": todo.taskName,
        "taskDesc": todo.taskDesc,
        "finished": todo.finished,
        "labelName": todo.labelName,
        "timeStamp": todo.timeStamp,
        "time": todo.time,
        "timeType": todo.timeType,
        "index": todo.index,
      };
      allTodosMap.add(newTodo);
    }

    for (Label label in allLabels) {
      Map newLabel = {
        "id": label.id.toString(),
        "name": label.name,
        "color": label.color,
      };
      // json.encode(allTodosMap);
      allLabelsMap.add(newLabel);
    }

    Map data = {
      "todos": allTodosMap,
      "labels": allLabelsMap,
    };
    debugPrint("data to be sent is $data");
    var body = json.encode(data);
    var response = await http.post(
      Uri.parse("$serverUrl/postLogin"),
      headers: {
        "Content-Type": "application/json",
        "authorization": auth.user.value!.token
      },
      body: body,
    );
    Map res = json.decode(response.body);

    for (Todo todo in allTodos) {
      debugPrint("deleting name ${todo.taskName}, index ${todo.index}");
      await deleteTodo(todo.id, true);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringStoredLabels = prefs.getString('labels') ?? "";
    List<Label> labels = LabelDAO().extractLabels(stringStoredLabels);
    for (Label label in labels) {
      await labelDAO.deleteLabel(label.id, true);
    }

    for (Map todo in res["todos"]) {
      debugPrint("created todo is $todo");
      Todo newTodo = Todo.fromMap(todo);
      await createTodo(newTodo, true);
    }
    for (Map label in res["labels"]) {
      debugPrint("created label is $label");
      Label newLabel = Label.fromMap(label);
      await labelDAO.addLabel(newLabel, true);
    }
  }

  Future syncOnlineDB() async {
    AuthState auth = GetIt.I.get();
    TodoDAO todosdb = GetIt.I.get();
    LabelDAO labelsdb = GetIt.I.get();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastOfflineUpdated =
        Platform.isLinux ? 0 : prefs.getInt('lastOfflineUpdated');
    // debugPrint("offline db was updated at $lastOfflineUpdated");
    // debugPrint("user is ${auth.user.value?.token}");

    if (auth.user.value != null) {
      var response = await http.get(
        Uri.parse("$serverUrl/todos/$lastOfflineUpdated"),
        headers: {
          "Content-Type": "application/json",
          "authorization": auth.user.value!.token
        },
      );
      debugPrint("todos reponse is ${response.body}");
      Map body = json.decode(response.body);
      if (body["message"] != "offline db up to date") {
        List newLabelList = body["labels"];
        List deletedLabelList = body["deletedLabels"];
        debugPrint("all labels are: $newLabelList");
        debugPrint("all deleted labels are: $deletedLabelList");

        for (Map each in newLabelList) {
          debugPrint("each label is $each");
          Label label = Label.fromMap(each);
          Label? labelFromDB = labelsdb.getLabelById(label.id);
          debugPrint("label from db is ${labelFromDB?.name}");
          if (labelFromDB == null) {
            debugPrint("gotta create ${label.name}");
            await labelsdb.addLabel(label, true);
          } else {
            debugPrint("gotta update ${label.name}");
            await labelsdb.editLabel(label, true);
          }
        }
        for (Map each in deletedLabelList) {
          int id = each["_id"];
          debugPrint("gotta delete $id");
          await labelsdb.deleteLabel(id, true);
          // Todo todo = Todo.fromMap(each);
          // newTodos.add(todo);
        }

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

  Future createTodo(Todo todo, bool receivedFromServer) async {
    var finder = Finder(
      filter: Filter.equals(
        'time',
        todo.time,
      ),
      sortOrders: [
        SortOrder("index"),
      ],
    );
    final allTodos = await getAllTodos(finder);
    todo.index = receivedFromServer ? todo.index : allTodos.length;
    // }
    await _store.record(todo.id).put(_db, todo.toMap());
    debugPrint("created todo ${todo.taskName} ${todo.index}");

    Map newTodo = {
      "id": todo.id.toString(),
      "taskName": todo.taskName,
      "taskDesc": todo.taskDesc,
      "finished": todo.finished,
      "labelName": todo.labelName,
      "timeStamp": todo.timeStamp,
      "time": todo.time,
      "timeType": todo.timeType,
      "index": todo.index,
    };
    try {
      // debugPrint("creating todo for system ${todo.id}");
      platform
          .invokeMethod("createTodo", newTodo)
          .then((_) => platform.invokeMethod("updateWidget"));
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while creating todo: $e");
    }

    if (!receivedFromServer) {
      socket?.emitWithAck("create_todo", json.encode(newTodo), ack: (response) {
        debugPrint("ack from server $response");
      });
    }

    // HomeWidget.updateWidget(
    //   name: 'WidgetProvider',
    //   iOSName: 'WidgetProvider',
    // );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastOfflineUpdated', todo.timeStamp);
  }

  Future<Todo?> getTodo(int key) async {
    // debugPrint("tryna fetch a todo id: $key");
    final snapshot = await _store.record(key).getSnapshot(_db);
    Map<String, dynamic>? map = snapshot?.value as Map<String, dynamic>?;
    return Future<Todo?>.value(
        snapshot != null && map != null ? Todo.fromMap(map) : null);
  }

  Future<List<Todo>> getAllTodos(Finder finder) async {
    final snapshots = await _store.find(_db, finder: finder);

    List<Map<String, dynamic>> maps = snapshots
        .map((snapshot) => snapshot.value as Map<String, dynamic>)
        .toList();
    return maps.map((map) => Todo.fromMap(map)).toList(growable: true);
  }

  Future updateTodo(Todo todo, bool receivedFromServer) async {
    // debugPrint("updating todo id: ${todo.id}");
    Todo? prevTodo = await getTodo(todo.id);
    if (prevTodo!.time != todo.time && !receivedFromServer) {
      var finder = Finder(
        filter: Filter.equals(
          'time',
          prevTodo.time,
        ),
      );
      List<Todo> prevTodos = await getAllTodos(finder);
      for (Todo element in prevTodos) {
        if (element.index > prevTodo.index) {
          element.index--;
          updateTodo(element, receivedFromServer);
        }
      }
      finder = Finder(
        filter: Filter.equals(
          'time',
          todo.time,
        ),
      );
      final presentTodos = await getAllTodos(finder);
      todo.index = presentTodos.length;
    }
    await _store.record(todo.id).put(_db, todo.toMap(), merge: true);
    debugPrint("updated todo ${todo.taskName} ${todo.index}");

    Map updatedTodo = {
      "id": todo.id.toString(),
      "taskName": todo.taskName,
      "taskDesc": todo.taskDesc,
      "finished": todo.finished,
      "labelName": todo.labelName,
      "timeStamp": todo.timeStamp,
      "time": todo.time,
      "timeType": todo.timeType,
      "index": todo.index,
    };
    try {
      // debugPrint("updating todo for system ${todo.id}");
      platform
          .invokeMethod("updateTodo", updatedTodo)
          .then((_) => platform.invokeMethod("updateWidget"));
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while updating todo: $e");
    }

    // AuthState auth = GetIt.I.get();
    if (!receivedFromServer) {
      socket?.emitWithAck(
        "update_todo",
        json.encode(updatedTodo),
        ack: (response) {
          debugPrint("ack from server $response");
        },
      );
    }

    // HomeWidget.updateWidget(
    //   name: 'WidgetProvider',
    //   iOSName: 'WidgetProvider',
    // );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastOfflineUpdated', todo.timeStamp);
  }

  Future deleteTodo(int todoId, bool receivedFromServer) async {
    Todo? todo = await getTodo(todoId);
    // debugPrint("deleting todo id: $todoId");
    if (todo != null) {
      var finder = Finder(
        filter: Filter.equals(
          'time',
          todo.time,
        ),
      );
      await _store.record(todoId).delete(_db);

      AlarmDAO alarmsdb = GetIt.I.get();
      List<Alarm> toDeleteAlarms = await alarmsdb.getAlarms(todoId);
      for (Alarm alarm in toDeleteAlarms) {
        alarmsdb.deleteAlarm(alarm.alarmId);
      }
      // debugPrint("working flawlessly till after alarms");

      try {
        debugPrint("deleting todo for system ${todo.id}");
        platform.invokeMethod("deleteTodo", {
          "id": todo.id.toString(),
        }).then((_) => platform.invokeMethod("updateWidget"));
      } on PlatformException catch (e) {
        debugPrint("some fuckup happended while deleting todo: $e");
      }

      if (!receivedFromServer) {
        List<Todo> presentTodos = await getAllTodos(finder);
        for (var element in presentTodos) {
          if (element.index > todo.index) {
            element.index--;
            await updateTodo(element, receivedFromServer);
          }
        }
        socket?.emitWithAck(
          "delete_todo",
          json.encode({
            "id": todo.id.toString(),
            "timeStamp": DateTime.now().millisecondsSinceEpoch,
          }),
          ack: (response) {
            debugPrint("ack from server $response");
          },
        );
      }

      // HomeWidget.updateWidget(
      //   name: 'WidgetProvider',
      //   iOSName: 'WidgetProvider',
      // );

      platform.invokeMethod("updateWidget");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('lastOfflineUpdated', todo.timeStamp);
    } else {
      debugPrint("couldn't find todo");
    }
  }

  Future rearrangeTodos(int oldIndex, int newIndex, String time) async {
    var finder = Finder(
      filter: Filter.equals(
        'time',
        time,
      ),
    );
    List<Todo> todos = await getAllTodos(finder);
    if (newIndex > oldIndex) {
      for (Todo element in todos) {
        if (element.index == oldIndex) {
          element.index = newIndex;
          await updateTodo(element, false);
        } else if (element.index > oldIndex && element.index <= newIndex) {
          element.index -= 1;
          await updateTodo(element, false);
        }
      }
    } else if (oldIndex > newIndex) {
      for (Todo element in todos) {
        if (element.index == oldIndex) {
          element.index = newIndex;
          await updateTodo(element, false);
        } else if (element.index < oldIndex && element.index >= newIndex) {
          element.index += 1;
          await updateTodo(element, false);
        }
      }
    }
  }
}
