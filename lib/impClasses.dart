import 'package:flutter/material.dart';
import 'package:sembast/timestamp.dart';

class Label {
  String name;
  String color;

  Label(this.name, this.color);
}

class User {
  String name;
  String email;
  String token;

  User(this.name, this.email, this.token);
}

class Alarm {
  int alarmId;
  int taskId;
  String repeatStatus;
  String time;
  Alarm(this.alarmId, this.taskId, this.repeatStatus, this.time);

  Map<String, dynamic> toMap() {
    return {
      "alarmId": alarmId,
      "taskId": taskId,
      'repeatStatus': repeatStatus,
      'time': time,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      map["alarmId"],
      map["taskId"],
      map["repeatStatus"],
      map["time"],
    );
  }
}

class Todo {
  int id;
  String taskName;
  String taskDesc;
  bool finished;
  String labelName;
  int timeStamp;
  String time;
  String timeType;
  int index;
  // List<Map<String, int>> indices;
  // List<String> users;

  Todo(this.taskName, this.taskDesc, this.finished, this.labelName,
      this.timeStamp, this.time, this.timeType, this.index, this.id
      // this.indices,
      // this.users,
      );
  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'taskDesc': taskDesc,
      'finished': finished,
      'labelName': labelName,
      'timeStamp': timeStamp,
      'time': time,
      'timeType': timeType,
      'index': index,
      'id': id,
      // 'indices': indices,
      // 'users': users
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      map["taskName"],
      map["taskDesc"],
      map["finished"],
      map["labelName"],
      map["timeStamp"],
      map["time"],
      map["timeType"],
      map["index"],
      map["id"],
      // map["indices"],
      // map["users"],
    );
  }
}
