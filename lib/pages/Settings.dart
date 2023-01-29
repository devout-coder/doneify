import 'package:conquer_flutter_app/components/GradientText.dart';
import 'package:conquer_flutter_app/components/SettingsButton.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/AccountSettings.dart';
import 'package:conquer_flutter_app/pages/Auth.dart';
import 'package:conquer_flutter_app/pages/FriendsSettings.dart';
import 'package:conquer_flutter_app/pages/LabelsSettings.dart';
import 'package:conquer_flutter_app/pages/NudgerSettings.dart';
import 'package:conquer_flutter_app/states/nudgerState.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsNavigator extends StatefulWidget {
  SettingsNavigator({Key? key}) : super(key: key);

  @override
  State<SettingsNavigator> createState() => _SettingsNavigatorState();
}

class _SettingsNavigatorState extends State<SettingsNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: settingsNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == "/nudgerSettings") {
          return MaterialPageRoute(
            builder: (context) {
              return NudgerSettings();
            },
          );
        } else if (settings.name == "/labelsSettings") {
          return MaterialPageRoute(
            builder: (context) {
              return LabelsSettingsPage();
            },
          );
        } else if (settings.name == "/friendsSettings") {
          return MaterialPageRoute(
            builder: (context) {
              return FriendsSettingsPage();
            },
          );
        } else if (settings.name == "/accountSettings") {
          return MaterialPageRoute(
            builder: (context) {
              return AccountSettingsPage();
            },
          );
        } else {
          return MaterialPageRoute(
            builder: (context) {
              return SettingsPage();
            },
          );
        }
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool signedUp = false;
  @override
  void initState() {
    debugPrint("settings page loaded");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: UniqueKey(),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        signedUp
            ? Container(
                padding: EdgeInsets.only(left: 35),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GradientText(
                          'Bruce Wayne',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 173, 133, 255),
                              // Color(0xffC5A9FF),
                              Color(0xffEDE4FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        Text(
                          "ts@gmial.com",
                          style:
                              TextStyle(fontSize: 18, color: Color(0xff9A9A9A)),
                        )
                      ],
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Text(
                    "Not signed up yet",
                    style: TextStyle(
                      fontFamily: "EuclidCircular",
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Auth(
                                    type: "login"); //this is giving an error
                              },
                            ),
                          ).whenComplete(() {
                            debugPrint("gone back");
                            //make sure that latest signup state is fetched here
                            setState(() {});
                          });
                        },
                        child: GradientText(
                          'Log In',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 173, 133, 255),
                              // Color(0xffC5A9FF),
                              Color(0xffEDE4FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Auth(
                                    type: "signup"); //this is giving an error
                              },
                            ),
                          ).whenComplete(() {
                            debugPrint("gone back");
                            //make sure that latest signup state is fetched here
                            setState(() {});
                          });
                        },
                        child: GradientText(
                          'Sign Up',
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 173, 133, 255),
                              // Color(0xffC5A9FF),
                              Color(0xffEDE4FF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        SizedBox(height: 80),
        SettingsButton(
          buttonWidth: 205,
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/nudgerSettings",
            );
          },
          title: "Nudger",
          icon: Icon(
            Icons.keyboard_arrow_right,
            size: 24.0,
          ),
        ),
        SizedBox(height: 20),
        SettingsButton(
          buttonWidth: 210,
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/labelsSettings",
            );
          },
          title: "Labels",
          icon: Icon(
            Icons.keyboard_arrow_right,
            size: 24.0,
          ),
        ),
        SizedBox(height: 20),
        signedUp
            ? Column(
                children: [
                  SettingsButton(
                    buttonWidth: 205,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/friendsSettings",
                      );
                    },
                    title: "Friends",
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      size: 24.0,
                    ),
                  ),
                  SizedBox(height: 20),
                  SettingsButton(
                    buttonWidth: 185,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/accountSettings",
                      );
                    },
                    title: "Account",
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      size: 24.0,
                    ),
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
