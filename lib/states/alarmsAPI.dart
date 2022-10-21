import 'package:conquer_flutter_app/impClasses.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class AlarmsAPI {
  final Database _db = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("alarms");

  Future setAlarms(List<Alarm> taskAlarms, int taskId) async {
    await _store.record(taskId).put(
        _db, taskAlarms.map((alarm) => alarm.toMap()).toList(),
        merge: true);
  }

  Future<List<Alarm>?> getAlarms(int taskId) async {
    final snapshot = await _store.record(taskId).getSnapshot(_db);
    List<Map<String, dynamic>>? alarms = snapshot?.value;
    return Future.value(alarms?.map((alarm) => Alarm.fromMap(alarm)).toList());
  }
}
