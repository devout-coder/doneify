import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class ActiveAlarmsAPI {
  final Database _db = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("active_alarms");

  Future setAlarm(
    String alarmId,
    String time,
    String repeatStatus,
    String repeatEnd,
    String taskId,
    String taskName,
    String taskDesc,
    String labelName,
    bool finished,
  ) async {
    debugPrint("new active alarm being set");
    await _store.record(int.parse(alarmId)).put(
        _db,
        {
          "alarmId": alarmId,
          "time": time,
          "repeatStatus": repeatStatus,
          "repeatEnd": repeatEnd,
          "taskId": taskId,
          "taskName": taskName,
          "taskDesc": taskDesc,
          "labelName": labelName,
          "finished": finished,
        },
        merge: true);
  }

  Future getAlarm(int alarmId) async {
    final snapshot = await _store.record(alarmId).getSnapshot(_db);
    return Future<Map?>.value(snapshot != null
        ? {
            "alarmId": snapshot.value["alarmId"],
            "time": snapshot.value["time"],
            "repeatStatus": snapshot.value["repeatStatus"],
            "repeatEnd": snapshot.value["repeatEnd"],
            "taskId": snapshot.value["taskId"],
            "taskName": snapshot.value["taskName"],
            "taskDesc": snapshot.value["taskDesc"],
            "labelName": snapshot.value["labelName"],
            "finished": snapshot.value["finished"],
          }
        : null);
  }

  Future<List<Map>> getActiveAlarms(String taskId) async {
    var finder = Finder(
      filter: Filter.equals(
        'taskId',
        taskId,
      ),
    );
    final snapshots = await _store.find(_db, finder: finder);
    return snapshots
        .map((snapshot) => {
              "alarmId": snapshot.value["alarmId"],
              "time": snapshot.value["time"],
              "repeatStatus": snapshot.value["repeatStatus"],
              "repeatEnd": snapshot.value["repeatEnd"],
              "taskId": snapshot.value["taskId"],
              "taskName": snapshot.value["taskName"],
              "taskDesc": snapshot.value["taskDesc"],
              "labelName": snapshot.value["labelName"],
              "finished": snapshot.value["finished"],
            })
        .toList(growable: true);
  }

  Future deleteAlarm(int alarmId) async {
    debugPrint("deleting alarm id from active alarms " + alarmId.toString());
    // debugPrint('rem active alarms');
    // final snapshots = await _store.find(_db);
    // snapshots.forEach((element) {
    //   debugPrint(element.value.toString());
    // });
    await _store.record(alarmId).delete(_db);
  }
}
