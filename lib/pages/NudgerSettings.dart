import 'dart:convert';

import 'package:conquer_flutter_app/components/BlacklistedAppsDialog.dart';
import 'package:conquer_flutter_app/components/NudgerConfirmationDialog.dart';
import 'package:conquer_flutter_app/components/SettingsButton.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:conquer_flutter_app/states/nudgerState.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NudgerSettings extends StatefulWidget {
  const NudgerSettings({super.key});

  @override
  State<NudgerSettings> createState() => _NudgerSettingsState();
}

class _NudgerSettingsState extends State<NudgerSettings> {
  NudgerStates nudgerStates = GetIt.I.get();

  bool nudgerSwitch = false;
  bool accessibilityTurnedOn = false;
  bool nudgerTurnedOn = false;
  // bool loading = false;

  void handleSwitch() {
    bool newState = !nudgerSwitch;
    if (newState == true) {
      if (!accessibilityTurnedOn) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Choose filters",
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Container();
          },
          transitionBuilder: (ctx, a1, a2, child) {
            var curve = Curves.easeInOut.transform(a1.value);
            return NudgerConfirmationModal(
                curve: curve,
                turnOn: () async {
                  setState(() {
                    nudgerSwitch = true;
                  });
                  nudgerStates.setNudgerSwitch(true);
                });
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      } else {
        setState(() {
          nudgerSwitch = true;
        });
        nudgerStates.setNudgerSwitch(true);
      }
    } else {
      setState(() {
        nudgerSwitch = false;
      });
      nudgerStates.setNudgerSwitch(false);
    }
  }

  void checkSwitch() {
    accessibilityTurnedOn = nudgerStates.accessibilityTurnedOn;
    nudgerTurnedOn = nudgerStates.nudgerTurnedOn;
    if (accessibilityTurnedOn && nudgerTurnedOn) {
      setState(() {
        nudgerSwitch = true;
      });
    }
  }

  @override
  void initState() {
    checkSwitch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              handleSwitch();
            },
            child: AppBar(
              title: Text(
                "Nudger",
                // style: TextStyle(color: Colors.black),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Switch(
                  activeTrackColor: themePurple,
                  activeColor: themeMediumPurple,
                  value: nudgerSwitch,
                  onChanged: (bool value) {
                    handleSwitch();
                  },
                )
              ],
            ),
          ),
          nudgerSwitch
              ? Column(
                  children: [
                    SizedBox(height: 30),
                    SettingsButton(
                      buttonWidth: 100,
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Blacklisted Apps",
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation) {
                            return Container();
                          },
                          transitionBuilder: (ctx, a1, a2, child) {
                            var curve = Curves.easeInOut.transform(a1.value);
                            return BlacklistedAppsDialog(
                              curve: curve,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        );
                      },
                      title: "Blacklisted Apps",
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24.0,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(height: 15),
                    Container(
                      width: screenWidth * 0.9,
                      child: Text(
                        "Once you turn nudger on, you will be able to blacklist apps installed on your device. Overusing the blacklisted apps will result in a reminder about all the incomplete tasks.",
                        style: TextStyle(
                          height: 2,
                          color: Color.fromARGB(255, 195, 195, 195),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
