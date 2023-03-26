import 'dart:convert';
import 'package:doneify/pages/home.dart';

import 'package:doneify/impClasses.dart';
import 'package:doneify/pages/input_modal.dart';
import 'package:doneify/pages/nudger_settings.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/todoDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelDAO {
  List<Label> labels = [];
  SelectedFilters selectedFilters = GetIt.I.get();
  final TodoDAO _todosdb = GetIt.I.get();
  SharedPreferences? prefs;

  Label? getLabelById(int labelId) {
    for (Label label in labels) {
      if (label.id == labelId) {
        return label;
      }
    }
    return null;
  }

  int getLabelPosition(int labelId) {
    for (int i = 0; i < labels.length; i++) {
      if (labels[i].id == labelId) {
        return i;
      }
    }
    return -1;
  }

  List<Map<String, dynamic>> stringifyLabels(List<Label> labels) {
    List<Map<String, dynamic>> jsonLabels = [];

    for (Label label in labels) {
      Map<String, dynamic> jsonLabel = {
        "id": label.id,
        "name": label.name,
        "color": label.color.toString(),
      };
      jsonLabels.add(jsonLabel);
    }

    return jsonLabels;
  }

  List<Label> extractLabels(String labelsString) {
    List<dynamic> decodedMap = jsonDecode(labelsString);
    List<Label> storedLabels = [];
    for (var element in decodedMap) {
      int id = element["id"];
      String name = element["name"];
      String color = element["color"];
      Label thisLabel = Label(id, name, color);
      storedLabels.add(thisLabel);
    }
    return storedLabels;
  }

  Future<void> readLabelsFromStorage() async {
    prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    String stringStoredLabels = prefs?.getString('labels') ?? "";
    debugPrint("string labels in storage : $stringStoredLabels");
    if (stringStoredLabels == "" || stringStoredLabels == "[]") {
      int newId = getRandInt(10);
      Label newLabel = Label(newId, "General", Colors.white.toString());
      List<Map<String, dynamic>> mapList = [
        {'id': newId, 'name': newLabel.name, 'color': newLabel.color.toString()}
      ];

      // socket?.emitWithAck(
      //   "add_label",
      //   json.encode({
      //     "id": newLabel.id.toString(),
      //     "name": newLabel.name,
      //     "color": newLabel.color,
      //     "timeStamp": DateTime.now().millisecondsSinceEpoch,
      //   }),
      //   ack: (response) {
      //     debugPrint("ack from server $response");
      //   },
      // );

      String labelsJSON = jsonEncode(mapList);
      prefs?.setString('labels', labelsJSON);
      stringStoredLabels = labelsJSON;
    }
    // debugPrint(stringStoredLabels);
    labels = extractLabels(stringStoredLabels);
    // notifyListeners();
  }

  Future addLabel(Label newLabel, bool receivedFromServer) async {
    // int newId = getRandInt(10);
    Label? oldLabel = getLabelById(newLabel.id);
    if (oldLabel == null) {
      await selectedFilters.addLabel(newLabel.name);

      List<Label> newLabelList = [...labels, newLabel];
      labels = newLabelList;

      List<Map<String, dynamic>> mapList = stringifyLabels(newLabelList);
      String labelsJSON = jsonEncode(mapList);

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setString('labels', labelsJSON);

      // debugPrint("labels are now: $labels");
      debugPrint("in storage, labels are now: ${prefs?.getString('labels')}");

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      if (!receivedFromServer) {
        socket?.emitWithAck(
          "add_label",
          json.encode({
            "id": newLabel.id.toString(),
            "name": newLabel.name,
            "color": newLabel.color,
            "timeStamp": timestamp,
          }),
          ack: (response) {
            debugPrint("ack from server $response");
          },
        );
      }
      prefs?.setInt('lastOfflineUpdated', timestamp);
    }
  }

  Future editLabel(Label newLabel, bool receivedFromServer) async {
    Label? oldLabel = getLabelById(newLabel.id);
    int oldLabelPosition = getLabelPosition(newLabel.id);

    if (oldLabel != null) {
      if (selectedFilters.selectedLabels.contains(oldLabel.name)) {
        await selectedFilters.deleteLabel(oldLabel.name);
        await selectedFilters.addLabel(newLabel.name);
      }

      if (!receivedFromServer) {
        var finder = Finder(
          filter: Filter.equals(
            'labelName',
            oldLabel.name,
          ),
        );
        List<Todo> requiredTodos = await _todosdb.getAllTodos(finder);
        for (Todo todo in requiredTodos) {
          todo.labelName = newLabel.name;
          _todosdb.updateTodo(todo, false);
        }
      }

      // Label newLabel = Label(labelId, labelName, labelColor.toString());
      List<Label> newLabelList = [...labels];
      newLabelList[oldLabelPosition] = newLabel;
      labels = newLabelList;
      List<Map<String, dynamic>> mapList = [];
      for (var element in newLabelList) {
        Map<String, dynamic> eachMap = {
          'id': element.id,
          'name': element.name,
          'color': element.color.toString()
        };
        mapList.add(eachMap);
      }
      String labelsJSON = jsonEncode(mapList);

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setString('labels', labelsJSON);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      if (!receivedFromServer) {
        socket?.emitWithAck(
          "edit_label",
          json.encode({
            "id": newLabel.id.toString(),
            "name": newLabel.name,
            "color": newLabel.color,
            "timeStamp": timestamp,
          }),
          ack: (response) {
            debugPrint("ack from server $response");
          },
        );
      }

      prefs?.setInt('lastOfflineUpdated', timestamp);
    } else {
      debugPrint("no label found");
    }
  }

  Future deleteLabel(int labelId, bool receivedFromServer) async {
    Label? oldLabel = getLabelById(labelId);
    int oldLabelPosition = getLabelPosition(labelId);

    if (oldLabel != null) {
      if (selectedFilters.selectedLabels.contains(oldLabel.name)) {
        await selectedFilters.deleteLabel(oldLabel.name);
      }

      var finder = Finder(
        filter: Filter.equals(
          'labelName',
          oldLabel.name,
        ),
      );
      if (!receivedFromServer) {
        List<Todo> requiredTodos = await _todosdb.getAllTodos(finder);
        for (Todo todo in requiredTodos) {
          todo.labelName = labels[0].name;
          _todosdb.updateTodo(todo, false);
        }
      }

      labels.removeAt(oldLabelPosition);
      List<Map<String, dynamic>> mapList = [];
      for (Label element in labels) {
        Map<String, dynamic> eachMap = {
          'id': element.id,
          'name': element.name,
          'color': element.color
        };
        mapList.add(eachMap);
      }
      String labelsJSON = jsonEncode(mapList);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setString('labels', labelsJSON);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      if (!receivedFromServer) {
        socket?.emitWithAck(
          "delete_label",
          json.encode({
            "id": labelId.toString(),
            "timeStamp": timestamp,
          }),
          ack: (response) {
            debugPrint("ack from server $response");
          },
        );
      }

      prefs?.setInt('lastOfflineUpdated', timestamp);
    } else {
      debugPrint("label not found");
    }
  }
}
