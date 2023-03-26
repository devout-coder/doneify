import 'package:doneify/impClasses.dart';
import 'package:doneify/states/labelDAO.dart';
import 'package:doneify/states/selectedFilters.dart';
import 'package:doneify/states/todoDAO.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState extends ChangeNotifier {
  final user = ValueNotifier<User?>(null);

  Future fetchUserFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String id = prefs.getString('id') ?? "";
    String name = prefs.getString('userName') ?? "";
    String email = prefs.getString('userEmail') ?? "";
    String token = prefs.getString('userToken') ?? "";
    // debugPrint("current token is $token");
    if (name.isNotEmpty) {
      user.value = User(id, name, email, token);
      // debugPrint("fetched user from storage: $user");
    }
  }

  Future saveUserToStorage(User newUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user.value = newUser;

    debugPrint("new user: $user");

    prefs.setString('id', newUser.id);
    prefs.setString('userName', newUser.name);
    prefs.setString('userEmail', newUser.email);
    prefs.setString('userToken', newUser.token);
  }

  Future logOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    googleSignIn.signOut();

    prefs.setString('id', "");
    prefs.setString('userName', "");
    prefs.setString('userEmail', "");
    prefs.setString('userToken', "");
    user.value = null;

    //deleting everything
    TodoDAO todoDAO = GetIt.I.get();
    List<Todo> allTodos = await todoDAO.getAllTodos(Finder());
    for (Todo todo in allTodos) {
      await todoDAO.deleteTodo(todo.id, true);
    }
    LabelDAO labelDAO = GetIt.I.get();
    String stringStoredLabels = prefs.getString('labels') ?? "";
    List<Label> labels = LabelDAO().extractLabels(stringStoredLabels);
    for (Label label in labels) {
      await labelDAO.deleteLabel(label.id, true);
    }

    //create default labels
    SelectedFilters selectedFilters = GetIt.I.get();
    await selectedFilters.fetchFiltersFromStorage();
    await labelDAO.readLabelsFromStorage();
  }
}
