import 'package:flutter/material.dart';
import 'package:sembast/timestamp.dart';

class Label {
  String name;
  String color;

  Label(this.name, this.color);
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
