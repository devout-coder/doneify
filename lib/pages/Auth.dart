import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Auth extends StatefulWidget {
  String type;
  Auth({super.key, required this.type});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  double borderRadius = 10;
  bool _passwordVisible = false;
  Color textFieldActiveColor = Color.fromARGB(255, 230, 230, 230);
  Color textFieldInactiveColor = Colors.grey;

  String username = '';
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: OutlinedButton(
              onPressed: () {},
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
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
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
                            hintStyle: TextStyle(color: textFieldInactiveColor),
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
                debugPrint("username:$username, email:$email, password:$password");
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
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
        ],
      ),
    );
  }
}
