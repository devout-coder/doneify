import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sembast/sembast.dart';

class TodosDB {
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
    await _store.record(todo.id).put(_db, todo.toMap());
    storeDataInWidget();
  }

  Future<List<Todo>> getAllTodos(Finder finder) async {
    final snapshots = await _store.find(_db, finder: finder);
    return snapshots
        .map((snapshot) => Todo.fromMap(snapshot.value))
        .toList(growable: true);
  }

  Future updateTodo(Todo todo) async {
    final updated =
        await _store.record(todo.id).put(_db, todo.toMap(), merge: true);
    storeDataInWidget();
  }

  Future deleteTodo(int todoId) async {
    await _store.record(todoId).delete(_db);
    storeDataInWidget();
  }
}
