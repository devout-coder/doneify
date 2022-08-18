import 'dart:convert';

import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedFilters {
  List<String> selectedLabels = [];
  bool currentFirst = true;
  bool ascending = false;

  Future<void> fetchFiltersFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime =
        prefs.getStringList("selectedLabels") != null ? false : true;
    selectedLabels = prefs.getStringList('selectedLabels') ?? ["General"];
    currentFirst = prefs.getBool("filtersCurrentFirst") ?? true;
    ascending = prefs.getBool("filtersAscending") ?? false;
    if (firstTime) {
      prefs.setStringList('selectedLabels', ["General"]);
      prefs.setBool("filtersCurrentFirst", true);
      prefs.setBool("filtersAscending", false);
    }
  }

  void setCurrentFirst(bool newCurrentFirstVal) async {
    currentFirst = newCurrentFirstVal;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('filtersCurrentFirst', currentFirst);
    });
  }

  void setAscending(bool newAscendingVal) async {
    ascending = newAscendingVal;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('filtersAscending', ascending);
    });
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
