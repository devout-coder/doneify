import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class AlarmDAO {
  final Database _db = GetIt.I.get();
  // ActiveAlarmDAO ac = GetIt.I.get();
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
    // debugPrint("while creating alarm id: " + alarm.taskId.toString());
    await _store.record(alarm.alarmId).put(_db, alarm.toMap(), merge: true);
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
    debugPrint("deleting alarm id " + alarmId.toString());
    debugPrint("deleting alarm, kotlin id $alarmId");
    try {
      await platform.invokeMethod("deleteAlarm", {
        "alarmId": alarmId.toString(),
      });
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while deleting alarm: $e");
    }
  }
}
