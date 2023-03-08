import 'dart:async';
import 'package:get_it/get_it.dart';

import 'package:doneify/states/alarmDAO.dart';
import 'package:doneify/states/authState.dart';
import 'package:doneify/states/labelDAO.dart';
import 'package:doneify/states/nudgerState.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/startTodos.dart';
import 'package:doneify/states/todoDAO.dart';
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
    GetIt.I.registerLazySingleton<TodoDAO>(() => TodoDAO());
    GetIt.I.registerLazySingleton<LabelDAO>(() => LabelDAO());
    GetIt.I.registerLazySingleton<AlarmDAO>(() => AlarmDAO());
    GetIt.I.registerLazySingleton<SelectedFilters>(() => SelectedFilters());
    GetIt.I.registerLazySingleton<StartTodos>(() => StartTodos());
    GetIt.I.registerLazySingleton<NudgerStates>(() => NudgerStates());
    GetIt.I.registerLazySingleton<AuthState>(() => AuthState());
    //lazy singleton won't be initialized until its resource is used for the first time
  }
}

final _get = GetIt.I.get;
AuthState get auth => _get<AuthState>();
