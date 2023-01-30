import 'package:conquer_flutter_app/impClasses.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  User? user;

  Future fetchUserFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = prefs.getString('userName') ?? "";
    String email = prefs.getString('userEmail') ?? "";
    String token = prefs.getString('userToken') ?? "";
    if (name.isNotEmpty) {
      user = User(name, email, token);

      debugPrint("fetched user from storage: $user");
    }
  }

  void saveUserToStorage(User newUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = newUser;

    debugPrint("new user: $user");

    prefs.setString('userName', newUser.name);
    prefs.setString('userEmail', newUser.email);
    prefs.setString('userToken', newUser.token);
  }

  void logOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    googleSignIn.signOut();

    prefs.setString('userName', "");
    prefs.setString('userEmail', "");
    prefs.setString('userToken', "");
    user = null;
  }
}
