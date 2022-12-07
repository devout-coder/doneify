import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';
import 'package:conquer_flutter_app/states/todoDAO.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelDAO {
  List<Label> labels = [];
  SelectedFilters selectedFilters = GetIt.I.get();
  TodoDAO _todosdb = GetIt.I.get();

  List<Map<String, dynamic>> stringifyLabels(List<Label> labels) {
    List<Map<String, dynamic>> jsonLabels = [];
    labels.forEach((label) {
      Map<String, dynamic> jsonLabel = {
        "name": label.name,
        "color": label.color.toString(),
      };
      jsonLabels.add(jsonLabel);
    });
    return jsonLabels;
  }

  List<Label> extractLabels(String labelsString) {
    List<dynamic> decodedMap = jsonDecode(labelsString);
    List<Label> storedLabels = [];
    decodedMap.forEach((element) {
      String name = element["name"];
      String color = element["color"];
      Label thisLabel = Label(name, color);
      storedLabels.add(thisLabel);
    });
    return storedLabels;
  }

  Future<void> readLabelsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    String stringStoredLabels = prefs.getString('labels') ?? "";
    if (stringStoredLabels == "") {
      Label newLabel = Label("General", Colors.white.toString());
      List<Map<String, dynamic>> mapList = [
        {'name': newLabel.name, 'color': newLabel.color.toString()}
      ];

      String labelsJSON = jsonEncode(mapList);
      prefs.setString('labels', labelsJSON);
      stringStoredLabels = labelsJSON;
    }
    // debugPrint(stringStoredLabels);
    labels = extractLabels(stringStoredLabels);
    // notifyListeners();
  }

  void addLabel(String labelName, Color labelColor) {
    selectedFilters.addLabel(labelName);

    Label newLabel = Label(labelName, labelColor.toString());
    List<Label> newLabelList = [...labels, newLabel];
    // setState(() {
    //   widget.labels = newLabelList;
    // });
    labels = newLabelList;

    List<Map<String, dynamic>> mapList = stringifyLabels(newLabelList);
    String labelsJSON = jsonEncode(mapList);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
    // notifyListeners();
    // widget.readLabels();
  }

  void editLabel(String labelName, Color labelColor, int index) async {
    if (selectedFilters.selectedLabels.contains(labels[index].name)) {
      selectedFilters.deleteLabel(labels[index].name);
      selectedFilters.addLabel(labelName);
    }

    var finder = Finder(
      filter: Filter.equals(
        'labelName',
        labels[index].name,
      ),
    );
    List<Todo> requiredTodos = await _todosdb.getAllTodos(finder);
    requiredTodos.forEach((todo) {
      todo.labelName = labelName;
      _todosdb.updateTodo(todo);
    });

    Label newLabel = Label(labelName, labelColor.toString());
    List<Label> newLabelList = [...labels];
    newLabelList[index] = newLabel;
    labels = newLabelList;
    List<Map<String, dynamic>> mapList = [];
    newLabelList.forEach((element) {
      Map<String, dynamic> eachMap = {
        'name': element.name,
        'color': element.color.toString()
      };
      mapList.add(eachMap);
    });
    String labelsJSON = jsonEncode(mapList);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
    // notifyListeners();
  }

  void deleteLabel(int labelIndex) async {
    if (selectedFilters.selectedLabels.contains(labels[labelIndex].name)) {
      selectedFilters.deleteLabel(labels[labelIndex].name);
    }

    var finder = Finder(
      filter: Filter.equals(
        'labelName',
        labels[labelIndex].name,
      ),
    );
    List<Todo> requiredTodos = await _todosdb.getAllTodos(finder);
    requiredTodos.forEach((todo) {
      todo.labelName = labels[0].name;
      _todosdb.updateTodo(todo);
    });

    labels.removeAt(labelIndex);
    List<Map<String, dynamic>> mapList = [];
    labels.forEach((element) {
      Map<String, dynamic> eachMap = {
        'name': element.name,
        'color': element.color.toString()
      };
      mapList.add(eachMap);
    });
    String labelsJSON = jsonEncode(mapList);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('labels', labelsJSON);
    });
    // notifyListeners();
  }
}
