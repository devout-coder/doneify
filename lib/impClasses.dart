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
  Label label;
  int timeStamp;
  String time;
  String timeType;
  int index;
  // List<Map<String, int>> indices;
  // List<String> users;

  Todo(this.taskName, this.taskDesc, this.finished, this.label, this.timeStamp,
      this.time, this.timeType, this.index, this.id
      // this.indices,
      // this.users,
      );
  Map<String, dynamic> toMap() {
    Map compatibleLabel = {
      'name': label.name,
      'color': label.color,
    };
    return {
      'taskName': taskName,
      'taskDesc': taskDesc,
      'finished': finished,
      'label': compatibleLabel,
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
      Label(map["label"]["name"], map["label"]["color"]),
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
