import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/AccountSettings.dart';
import 'package:conquer_flutter_app/pages/Auth.dart';
import 'package:conquer_flutter_app/pages/FriendsSettings.dart';
import 'package:conquer_flutter_app/pages/LabelsSettings.dart';
import 'package:conquer_flutter_app/pages/NudgerSettings.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

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
        // Cast the arguments to the correct
        // type: ScreenArguments.
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        Text(
          "Not signed up yet",
          style: TextStyle(
            fontFamily: "EuclidCircular",
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 30,
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
                  MaterialPageRoute(builder: (context) => Auth(type: "login")),
                ); //throws error
              },
              child: GradientText(
                'Log In',
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
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Auth(type: "signup")),
                ); //throws error
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
        SizedBox(height: 80),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/nudgerSettings",
            );
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Color.fromRGBO(217, 217, 217, 0.16))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nudger',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(width: 200, height: 50),
              Icon(
                Icons.keyboard_arrow_right,
                size: 24.0,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/labelsSettings",
            );
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Color.fromRGBO(217, 217, 217, 0.16))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Labels',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(width: 210, height: 50),
              Icon(
                Icons.keyboard_arrow_right,
                size: 24.0,
              ),
            ],
          ),
        ),
      ],
    );
    // return ListView.builder(itemBuilder: (BuildContext context, int index) {
    //   return ListTile(
    //     title: Text("Setting $index"),
    //     onTap: () {
    //       debugPrint("setting $index tapped");
    //     },
    //   );
    // });
    return Container();
  }
}
