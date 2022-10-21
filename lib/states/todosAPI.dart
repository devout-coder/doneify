import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sembast/sembast.dart';

class TodosAPI {
  final Database _db = GetIt.I.get();

  final StoreRef _store = intMapStoreFactory.store("todos");

  Future storeDataInWidget() async {
    var finder = Finder();
    final todos = await getAllTodos(finder);
    List<Map<String, dynamic>> storeableTodos = [];
    todos.forEach((todo) {
      storeableTodos.add(todo.toMap());
    });
    await HomeWidget.saveWidgetData<String>(
        'todos', jsonEncode({"todos": storeableTodos}));
    await HomeWidget.updateWidget(
      name: 'WidgetProvider',
      iOSName: 'WidgetProvider',
    );
  }

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
    storeDataInWidget();
  }

  Future<Todo?> getTodo(int key) async {
    final snapshot = await _store.record(key).getSnapshot(_db);
    return Future<Todo?>.value(
        snapshot != null ? Todo.fromMap(snapshot.value) : null);
  }

  Future<List<Todo>> getAllTodos(Finder finder) async {
    final snapshots = await _store.find(_db, finder: finder);
    return snapshots
        .map((snapshot) => Todo.fromMap(snapshot.value))
        .toList(growable: true);
  }

  Future updateTodo(Todo todo) async {
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
    storeDataInWidget();
  }

  Future deleteTodo(int todoId) async {
    Todo? todo = await getTodo(todoId);
    var finder = Finder(
      filter: Filter.equals(
        'time',
        todo!.time,
      ),
    );
    final presentTodos = await getAllTodos(finder);
    presentTodos.forEach((element) {
      if (element.index > todo.index) {
        element.index--;
        updateTodo(element);
      }
    });
    await _store.record(todoId).delete(_db);
    storeDataInWidget();
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
