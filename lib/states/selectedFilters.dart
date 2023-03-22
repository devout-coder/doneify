import 'package:shared_preferences/shared_preferences.dart';

class SelectedFilters {
  List<String> selectedLabels = [];
  bool currentFirst = true;
  bool ascending = false;
  SharedPreferences? prefs;

  Future<void> fetchFiltersFromStorage() async {
    prefs = await SharedPreferences.getInstance();
    bool firstTime =
        prefs?.getStringList("selectedLabels") != null ? false : true;
    selectedLabels = prefs?.getStringList('selectedLabels') ?? ["General"];
    currentFirst = prefs?.getBool("filtersCurrentFirst") ?? true;
    ascending = prefs?.getBool("filtersAscending") ?? false;
    if (firstTime) {
      prefs?.setStringList('selectedLabels', ["General"]);
      prefs?.setBool("filtersCurrentFirst", true);
      prefs?.setBool("filtersAscending", false);
    }
  }

  void setCurrentFirst(bool newCurrentFirstVal) async {
    currentFirst = newCurrentFirstVal;

    // SharedPreferences.getInstance().then((prefs) {
    prefs?.setBool('filtersCurrentFirst', currentFirst);
    // });
  }

  void setAscending(bool newAscendingVal) async {
    ascending = newAscendingVal;

    // SharedPreferences.getInstance().then((prefs) {
    prefs?.setBool('filtersAscending', ascending);
    // });
  }

  Future addLabel(String labelName) async {
    List<String> newLabelList = [...selectedLabels, labelName];
    selectedLabels = newLabelList;

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setStringList('selectedLabels', newLabelList);
  }

  void addLabels(List<String> newLabels) {
    List<String> newLabelList = [...newLabels];
    selectedLabels = newLabelList;

    // SharedPreferences.getInstance().then((prefs) {
    prefs?.setStringList('selectedLabels', newLabelList);
    // });
  }

  Future deleteLabel(String labelName) async {
    selectedLabels.remove(labelName);

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setStringList('selectedLabels', selectedLabels);
  }
}
