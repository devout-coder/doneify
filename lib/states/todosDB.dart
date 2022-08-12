import 'package:conquer_flutter_app/impClasses.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class TodosDB {
  final Database _db = GetIt.I.get();

  final StoreRef _store = intMapStoreFactory.store("todos");

  Future createTodo(Todo todo) async {
    await _store.record(todo.id).put(_db, todo.toMap());
  }

  Future<List<Todo>> getAllTodos(Finder finder) async {
    final snapshots = await _store.find(_db, finder: finder);
    return snapshots
        .map((snapshot) => Todo.fromMap(snapshot.value))
        .toList(growable: false);
  }

  Future updateTodo(Todo todo) async {
    final updated =
        await _store.record(todo.id).put(_db, todo.toMap(), merge: true);
    print(updated);
  }

  Future deleteTodo(int todoId) async {
    await _store.record(todoId).delete(_db);
  }
}
