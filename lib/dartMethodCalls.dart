import 'dart:convert';

import 'package:doneify/impClasses.dart';
import 'package:doneify/main.dart';
import 'package:doneify/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

void kotlinMethodCallHandler(MethodCall call) async {
  if (call.method == 'task_done') {
    String dbPath = 'doneify.db';
    final appDocDir = await getApplicationDocumentsDirectory();
    Database db = await databaseFactoryIo
        .openDatabase(join(appDocDir.path, dbPath), version: 1);
    debugPrint("opened new db");

    int todoId = int.parse(call.arguments);

    final StoreRef store = intMapStoreFactory.store("todos");
    // debugPrint("fetched store");
    final snapshot = await store.record(todoId).getSnapshot(db);
    // debugPrint("got a todo");

    Map<String, dynamic> map = snapshot?.value as Map<String, dynamic>;
    Todo todo = Todo.fromMap(map);
    todo.finished = true;
    await store.record(todoId).put(db, todo.toMap(), merge: true);
    // debugPrint("updated todo record in storage");
    bool receivedVal =
        await channel.invokeMethod("setWidgetChanged", {"widgetChanged": true});
    debugPrint("in dart set val, $receivedVal");

    Map updatedTodo = {
      "id": todo.id.toString(),
      "taskName": todo.taskName,
      "taskDesc": todo.taskDesc,
      "finished": true,
      "labelName": todo.labelName,
      "timeStamp": todo.timeStamp,
      "time": todo.time,
      "timeType": todo.timeType,
      "index": todo.index,
    };
    try {
      // debugPrint("updating todo for system ${todo.id}");
      channel.invokeMethod("updateTodo", updatedTodo).then((_) async {
        channel.invokeMethod("updateWidget");
      });
    } on PlatformException catch (e) {
      debugPrint("some fuckup happended while updating todo: $e");
    }

    socket?.emitWithAck(
      "update_todo",
      json.encode(updatedTodo),
      ack: (response) {
        debugPrint("ack from server $response");
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastOfflineUpdated', todo.timeStamp);
  }
  //  else if (call.method == "event") {
  //   Map details = call.arguments;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (details["isFocused"] && details["isActive"]) {
  //     if (prefs.getString("currentBlacklisted") != details["packageName"]) {
  //       prefs.setString("currentBlacklisted", "");
  //       debugPrint("gotta cancel alarm");
  //       channel.invokeMethod("cancelNudgerAlarm");
  //       if (prefs
  //           .getStringList("blacklistedApps")!
  //           .contains(details["packageName"])) {
  //         prefs.setString("currentBlacklisted", details["packageName"]);
  //         debugPrint("gotta set alarm");
  //         channel.invokeMethod("setNudgerAlarm");
  //       }
  //     }
  //   }
  // } else if (call.method == "reset_accessibility") {
  //   debugPrint("accesibility is gonna be reset");
  //   FlutterAccessibilityService.accessStream.listen((event) {});
  // }
}
