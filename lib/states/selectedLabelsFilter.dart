import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedLabel {
  List<String> selectedLabels = [];

  Future<void> readLabelsFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? fetchedSelectedLabels =
        prefs.getStringList('selectedLabels') ?? null;
    if (fetchedSelectedLabels == null) {
      fetchedSelectedLabels = ["General"];
      prefs.setStringList('selectedLabels', ["General"]);
    }
    selectedLabels = fetchedSelectedLabels;
  }

  void addLabel(String labelName) {
    List<String> newLabelList = [...selectedLabels, labelName];
    selectedLabels = newLabelList;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('selectedLabels', newLabelList);
    });
  }

  void addLabels(List<String> newLabels) {
    List<String> newLabelList = [...newLabels];
    selectedLabels = newLabelList;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('selectedLabels', newLabelList);
    });
  }

  void deleteLabel(String labelName) {
    selectedLabels.remove(labelName);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('selectedLabels', selectedLabels);
    });
    // notifyListeners();
  }
}
