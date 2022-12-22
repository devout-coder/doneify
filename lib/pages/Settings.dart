import 'package:conquer_flutter_app/components/GradientText.dart';
import 'package:conquer_flutter_app/components/SettingsButton.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/AccountSettings.dart';
import 'package:conquer_flutter_app/pages/Auth.dart';
import 'package:conquer_flutter_app/pages/FriendsSettings.dart';
import 'package:conquer_flutter_app/pages/LabelsSettings.dart';
import 'package:conquer_flutter_app/pages/NudgerSettings.dart';
import 'package:flutter/material.dart';

// class SettingsNavigator extends StatefulWidget {
//   SettingsNavigator({Key? key}) : super(key: key);

//   @override
//   State<SettingsNavigator> createState() => _SettingsNavigatorState();
// }

// class _SettingsNavigatorState extends State<SettingsNavigator> {
//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: settingsNavigatorKey,
//       onGenerateRoute: (RouteSettings settings) {
//         if (settings.name == "/nudgerSettings") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return NudgerSettings();
//             },
//           );
//         } else if (settings.name == "/labelsSettings") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return LabelsSettingsPage();
//             },
//           );
//         } else if (settings.name == "/friendsSettings") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return FriendsSettingsPage();
//             },
//           );
//         } else if (settings.name == "/accountSettings") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return AccountSettingsPage();
//             },
//           );
//         } else if (settings.name == "/login") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return Auth(type: "login");
//             },
//           );
//         } else if (settings.name == "/signup") {
//           return MaterialPageRoute(
//             builder: (context) {
//               return Auth(type: "signup");
//             },
//           );
//         } else {
//           return MaterialPageRoute(
//             builder: (context) {
//               return SettingsPage();
//             },
//           );
//         }
//       },
//     );
//   }
// }

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool signedUp = false;
  @override
  Widget build(BuildContext context) {
    return Column(
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Auth(
                                    type: "login"); //this is giving an error
                              },
                            ),
                          );
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
                          Navigator.pushNamed(context, "/signup");
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
          page: "nudgerSettings",
          pageName: "Nudger",
        ),
        SizedBox(height: 20),
        SettingsButton(
          buttonWidth: 210,
          page: "labelsSettings",
          pageName: "Labels",
        ),
        SizedBox(height: 20),
        signedUp
            ? Column(
                children: [
                  SettingsButton(
                    buttonWidth: 205,
                    page: "friendsSettings",
                    pageName: "Friends",
                  ),
                  SizedBox(height: 20),
                  SettingsButton(
                    buttonWidth: 185,
                    page: "accountSettings",
                    pageName: "Account",
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
