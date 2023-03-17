import 'dart:convert';

import 'package:doneify/impClasses.dart';
import 'package:doneify/ip.dart';
import 'package:doneify/states/authState.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Auth extends StatefulWidget {
  String type;
  Auth({super.key, required this.type});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  double borderRadius = 10;
  bool _passwordVisible = true;
  Color textFieldActiveColor = Color.fromARGB(255, 230, 230, 230);
  Color textFieldInactiveColor = Colors.grey;

  AuthState authState = GetIt.I.get();

  bool loading = false;

  String username = '';
  String email = "";
  String password = "";

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool fieldsValid() {
    bool ret = true;
    if ((widget.type == "login" && (email.isEmpty || password.isEmpty)) ||
        (widget.type == "signup" &&
            (email.isEmpty || password.isEmpty || username.isEmpty))) {
      ret = false;
      Fluttertoast.showToast(
        msg: "No field should be empty",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } else if (password.length < 8) {
      ret = false;
      Fluttertoast.showToast(
        msg: "Password should be atleast 8 characters long",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    return ret;
  }

  void dealWithResponse(int statusCode, String body) {
    if (statusCode == 200) {
      Map res = json.decode(body);
      debugPrint(res.toString());
      User newUser = User(
        res["data"]["_id"],
        res["data"]["username"],
        res["data"]["email"],
        res["token"],
      );
      authState.saveUserToStorage(newUser);
      setState(() {
        loading = false;
      });
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: json.decode(body)["message"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void signup() async {
    if (fieldsValid()) {
      setState(() {
        loading = true;
      });
      Map data = {
        'username': username,
        'email': email,
        'password': password,
      };
      var body = json.encode(data);
      var response = await http.post(
        Uri.parse("$serverUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      dealWithResponse(response.statusCode, response.body);
    }
  }

  void login() async {
    if (fieldsValid()) {
      setState(() {
        loading = true;
      });
      Map data = {
        'email': email,
        'password': password,
      };
      var body = json.encode(data);
      var response = await http.post(
        Uri.parse("$serverUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      dealWithResponse(response.statusCode, response.body);
    }
  }

  Future<void> signinGoogle(BuildContext context) async {
    try {
      setState(() {
        loading = true;
      });
      GoogleSignInAccount? signIn = await _googleSignIn.signIn();
      if (signIn != null) {
        Map data = {
          "username": signIn.displayName,
          'email': signIn.email,
        };
        var body = json.encode(data);
        var response = await http.post(
          Uri.parse("$serverUrl/signupGoogle"),
          headers: {"Content-Type": "application/json"},
          body: body,
        );
        dealWithResponse(response.statusCode, response.body);
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    // _googleSignIn.signOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff404049),
              Color(0xff09090E),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: OutlinedButton(
                onPressed: () {
                  signinGoogle(context);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(BorderSide(
                      width: 1, color: Color.fromARGB(85, 255, 255, 255))),
                  overlayColor: MaterialStateProperty.all(
                      Color.fromARGB(71, 217, 217, 217)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child: Container(
                  height: 50,
                  width: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(15, 217, 217, 217),
                        Color.fromARGB(71, 217, 217, 217),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 25),
                      Image.asset("assets/images/Google.png"),
                      SizedBox(width: 15),
                      Text(
                        "Continue with Google",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "or",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 15),
            widget.type == "signup"
                ? (Column(
                    children: [
                      SizedBox(
                        width: 315,
                        height: 85,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: TextField(
                            style: TextStyle(color: textFieldActiveColor),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: textFieldInactiveColor, width: 1),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(borderRadius)),
                              ),
                              hintStyle:
                                  TextStyle(color: textFieldInactiveColor),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: textFieldActiveColor, width: 1),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(borderRadius)),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(borderRadius)),
                              ),
                              hintText: "Username",
                            ),
                            onChanged: (text) {
                              username = text;
                            },
                          ),
                        ),
                      ),
                    ],
                  ))
                : (Container()),
            SizedBox(
              width: 315,
              height: 85,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  style: TextStyle(color: textFieldActiveColor),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textFieldInactiveColor, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    hintStyle: TextStyle(color: textFieldInactiveColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textFieldActiveColor, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    hintText: "Email",
                  ),
                  onChanged: (text) {
                    email = text;
                  },
                ),
              ),
            ),
            SizedBox(
              width: 315,
              height: 85,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextField(
                  obscureText: _passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  style: TextStyle(color: textFieldActiveColor),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textFieldInactiveColor, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    hintStyle: TextStyle(color: textFieldInactiveColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textFieldActiveColor, width: 1),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                    hintText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  onChanged: (text) {
                    password = text;
                  },
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.type == "login") {
                    login();
                  } else {
                    signup();
                  }
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  width: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffF476FF),
                        Color(0xffBA99FF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius)),
                  ),
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 120),
                        Text(widget.type == "login" ? "Log In" : "Sign Up",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            )),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            loading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}
