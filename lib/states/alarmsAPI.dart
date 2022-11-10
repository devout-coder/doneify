import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/activeAlarmsAPI.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class AlarmsAPI {
  final Database _db = GetIt.I.get();
  ActiveAlarmsAPI ac = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("alarms");
  static const platform = MethodChannel('alarm_method_channel');

  Future setAlarm(
    Alarm alarm,
    String kotlinAlarmTime,
    String kotlinAlarmRepeatEnd,
    String taskId,
    String taskName,
    String taskDesc,
    String labelName,
    bool finished,
  ) async {
    debugPrint("while creating alarm id: " + alarm.taskId.toString());
    await _store.record(alarm.alarmId).put(_db, alarm.toMap(), merge: true);
    await ac.setAlarm(
      alarm.alarmId.toString(),
      kotlinAlarmTime,
      alarm.repeatStatus,
      kotlinAlarmRepeatEnd,
      taskId,
      taskName,
      taskDesc,
      labelName,
      finished,
    );
    try {
      await platform.invokeMethod("setAlarm", {
        "alarmId": alarm.alarmId.toString(),
        "time": kotlinAlarmTime,
        "repeatStatus": alarm.repeatStatus,
        "repeatEnd": kotlinAlarmRepeatEnd,
        "taskId": taskId,
        "taskName": taskName,
        "taskDesc": taskDesc,
        "label": labelName,
        "finished": finished,
      });
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while creating alarm: $e");
    }
  }

  Future<List<Alarm>> getAlarms(int taskId) async {
    debugPrint("while getting alarms id: " + taskId.toString());
    var finder = Finder(
      filter: Filter.equals(
        'taskId',
        taskId,
      ),
    );
    final snapshots = await _store.find(_db, finder: finder);
    return snapshots
        .map((snapshot) => Alarm.fromMap(snapshot.value))
        .toList(growable: true);
  }

  Future deleteAlarm(int alarmId) async {
    await _store.record(alarmId).delete(_db);
    Map? activeAlarm = await ac.getAlarm(alarmId);
    debugPrint("deleting alarm id " + alarmId.toString());
    if (activeAlarm != null) {
      await ac.deleteAlarm(alarmId);
      debugPrint(
          "deleting alarm, kotlin id ${activeAlarm["alarmId"]}, time ${activeAlarm["time"]}, ${activeAlarm["repeatStatus"]}, ${activeAlarm["repeatEnd"]}, ${activeAlarm["taskId"]}, ${activeAlarm["taskName"]}, ${activeAlarm["taskDesc"]}, ${activeAlarm["labelName"]}");
      try {
        await platform.invokeMethod("deleteAlarm", {
          "alarmId": activeAlarm["alarmId"],
          "time": activeAlarm["time"],
          "repeatStatus": activeAlarm["repeatStatus"],
          "repeatEnd": activeAlarm["repeatEnd"],
          "taskId": activeAlarm["taskId"],
          "taskName": activeAlarm["taskName"],
          "taskDesc": activeAlarm["taskDesc"],
          "label": activeAlarm["labelName"],
          "finished": activeAlarm["finished"],
        });
      } on PlatformException catch (e) {
        debugPrint("some fuckup happended while deleting alarm: $e");
      }
    } else {
      debugPrint("alarm already gone off, nothing to delete in kotlin side.");
    }
  }
}
