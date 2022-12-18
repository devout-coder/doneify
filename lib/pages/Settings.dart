import 'package:conquer_flutter_app/components/GradientText.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/pages/AccountSettings.dart';
import 'package:conquer_flutter_app/pages/Auth.dart';
import 'package:conquer_flutter_app/pages/FriendsSettings.dart';
import 'package:conquer_flutter_app/pages/LabelsSettings.dart';
import 'package:conquer_flutter_app/pages/NudgerSettings.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatefulWidget {
  String pageName;
  Widget page;
  double buttonWidth;
  SettingsButton({
    super.key,
    required this.buttonWidth,
    required this.page,
    required this.pageName,
  });

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.page),
        ); //throws error
      },
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Color.fromRGBO(217, 217, 217, 0.16))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.pageName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(width: widget.buttonWidth, height: 50),
          Icon(
            Icons.keyboard_arrow_right,
            size: 24.0,
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool signedUp = true;
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
                          'Tony Stark',
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
                                builder: (context) => Auth(type: "login")),
                          ); //throws error
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Auth(type: "signup")),
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
                ],
              ),
        SizedBox(height: 80),
        SettingsButton(
          buttonWidth: 205,
          page: NudgerSettings(),
          pageName: "Nudger",
        ),
        SizedBox(height: 20),
        SettingsButton(
          buttonWidth: 210,
          page: LabelsSettingsPage(),
          pageName: "Labels",
        ),
        SizedBox(height: 20),
        signedUp
            ? Column(
                children: [
                  SettingsButton(
                    buttonWidth: 205,
                    page: FriendsSettingsPage(),
                    pageName: "Friends",
                  ),
                  SizedBox(height: 20),
                  SettingsButton(
                    buttonWidth: 185,
                    page: AccountSettingsPage(),
                    pageName: "Accounts",
                  ),
                ],
              )
            : Container()
      ],
    );
  }
}
