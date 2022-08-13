import 'dart:async';

import 'package:conquer_flutter_app/states/labelsDB.dart';
import 'package:conquer_flutter_app/states/selectedLabelsFilter.dart';
import 'package:conquer_flutter_app/states/todosDB.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class GetItRegister {
  Future initializeGlobalStates() async {
    String dbPath = 'conquer.db';
    final appDocDir = await getApplicationDocumentsDirectory();
    Database db = await databaseFactoryIo
        .openDatabase(join(appDocDir.path, dbPath), version: 1);

    GetIt.I.registerSingleton<Database>(db);
    GetIt.I.registerLazySingleton<TodosDB>(() => TodosDB());
    GetIt.I.registerLazySingleton<LabelDB>(() => LabelDB());
    GetIt.I.registerLazySingleton<SelectedLabel>(() => SelectedLabel());
    //lazy singleton won't be initialized until its resource is used for the first time
  }
}
