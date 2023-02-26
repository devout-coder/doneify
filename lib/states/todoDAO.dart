import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/Home.dart';
import 'package:conquer_flutter_app/states/alarmDAO.dart';
import 'package:conquer_flutter_app/states/authState.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sembast/sembast.dart';
import 'package:http/http.dart' as http;

class TodoDAO {
  final Database _db = GetIt.I.get();

  final StoreRef _store = intMapStoreFactory.store("todos");
  static const platform = MethodChannel('alarm_method_channel');

  Future createTodo(Todo todo) async {
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
    todo.index = allTodos.length;
    await _store.record(todo.id).put(_db, todo.toMap());

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
      debugPrint("creating todo for system ${todo.id}");
      platform.invokeMethod("createTodo", newTodo);
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while creating todo: $e");
    }
    AuthState auth = GetIt.I.get();

    if (auth.user.value != null) {
      socket?.emitWithAck("create_todo", json.encode(newTodo), ack: (response) {
        debugPrint("ack from server $response");
      });
    }

    HomeWidget.updateWidget(
      name: 'WidgetProvider',
      iOSName: 'WidgetProvider',
    );
  }

  Future<Todo?> getTodo(int key) async {
    debugPrint("tryna fetch a todo id: $key");
    final snapshot = await _store.record(key).getSnapshot(_db);
    Map<String, dynamic> map = snapshot?.value as Map<String, dynamic>;
    return Future<Todo?>.value(snapshot != null ? Todo.fromMap(map) : null);
  }

  Future<List<Todo>> getAllTodos(Finder finder) async {
    final snapshots = await _store.find(_db, finder: finder);

    List<Map<String, dynamic>> maps = snapshots
        .map((snapshot) => snapshot.value as Map<String, dynamic>)
        .toList();
    return maps.map((map) => Todo.fromMap(map)).toList(growable: true);
  }

  Future updateTodo(Todo todo) async {
    debugPrint("updating todo id: ${todo.id}");
    Todo? prevTodo = await getTodo(todo.id);
    if (prevTodo!.time != todo.time) {
      var finder = Finder(
        filter: Filter.equals(
          'time',
          prevTodo.time,
        ),
      );
      List<Todo> prevTodos = await getAllTodos(finder);
      prevTodos.forEach((element) {
        if (element.index > prevTodo.index) {
          element.index--;
          updateTodo(element);
        }
      });
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
      debugPrint("updating todo for system ${todo.id}");
      platform.invokeMethod("updateTodo", updatedTodo);
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while updating todo: $e");
    }

    AuthState auth = GetIt.I.get();
    if (auth.user.value != null) {
      socket?.emitWithAck(
        "update_todo",
        json.encode(updatedTodo),
        ack: (response) {
          debugPrint("ack from server $response");
        },
      );
    }

    HomeWidget.updateWidget(
      name: 'WidgetProvider',
      iOSName: 'WidgetProvider',
    );
  }

  Future deleteTodo(int todoId) async {
    Todo? todo = await getTodo(todoId);
    debugPrint("deleting todo id: $todoId");
    var finder = Finder(
      filter: Filter.equals(
        'time',
        todo!.time,
      ),
    );
    final presentTodos = await getAllTodos(finder);
    presentTodos.forEach((element) async {
      if (element.index > todo.index) {
        element.index--;
        await updateTodo(element);
      }
    });
    await _store.record(todoId).delete(_db);

    AlarmDAO alarmsdb = GetIt.I.get();
    List<Alarm> toDeleteAlarms = await alarmsdb.getAlarms(todoId);
    toDeleteAlarms.forEach((alarm) {
      alarmsdb.deleteAlarm(alarm.alarmId);
    });
    debugPrint("working flawlessly till after alarms");

    try {
      debugPrint("deleting todo for system ${todo.id}");
      platform.invokeMethod("deleteTodo", {
        "id": todo.id.toString(),
      });
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while deleting todo: $e");
    }

    AuthState auth = GetIt.I.get();
    if (auth.user.value != null) {
      socket?.emitWithAck(
        "delete_todo",
        json.encode({"id": todo.id.toString()}),
        ack: (response) {
          debugPrint("ack from server $response");
        },
      );
    }

    HomeWidget.updateWidget(
      name: 'WidgetProvider',
      iOSName: 'WidgetProvider',
    );
  }

  Future rearrangeTodos(int oldIndex, int newIndex, String time) async {
    var finder = Finder(
      filter: Filter.equals(
        'time',
        time,
      ),
    );
    final todos = await getAllTodos(finder);
    if (newIndex > oldIndex) {
      todos.forEach((element) async {
        if (element.index == oldIndex) {
          element.index = newIndex;
          await updateTodo(element);
        } else if (element.index > oldIndex && element.index <= newIndex) {
          element.index -= 1;
          await updateTodo(element);
        }
      });
    } else if (oldIndex > newIndex) {
      todos.forEach((element) async {
        if (element.index == oldIndex) {
          element.index = newIndex;
          await updateTodo(element);
        } else if (element.index < oldIndex && element.index >= newIndex) {
          element.index += 1;
          await updateTodo(element);
        }
      });
    }
  }
}
