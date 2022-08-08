import 'dart:async';

import 'package:conquer_flutter_app/database/todos_db.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DB {
  Future initializeDB() async {
    String dbPath = 'conquer.db';
    final appDocDir = await getApplicationDocumentsDirectory();
    Database db = await databaseFactoryIo
        .openDatabase(join(appDocDir.path, dbPath), version: 1);
    GetIt.I.registerSingleton<Database>(db);
    GetIt.I.registerLazySingleton<TodosDB>(() => TodosDB());
  }
}
