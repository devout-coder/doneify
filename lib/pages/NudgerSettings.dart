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

List<String> times = ["Day", "Week", "Month", "Year", "Long Term"];

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
  String time = "Day";
  bool presentTodos = false;
  TextEditingController duration = TextEditingController();

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
        duration.text = nudgerStates.interval;
        time = nudgerStates.timeType;
        presentTodos = nudgerStates.onlyPresent;
      });
    }
  }

  @override
  void initState() {
    duration.text = "1";
    //this works when i turn on accessibility settings and go back to doneify
    checkSwitch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(height: 30),
                    Container(
                      width: screenWidth * 0.8,
                      child: Column(
                        children: [
                          Text(
                            "Tasks you want to be notified about: ",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 15),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 35,
                              width: 100,
                              child: DropdownButton<String>(
                                value: time,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                elevation: 16,
                                style: const TextStyle(color: Colors.white),
                                selectedItemBuilder: ((context) {
                                  return times.map((String value) {
                                    return Text(
                                      time,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'EuclidCircular',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }).toList();
                                }),
                                underline: Container(
                                  height: 2,
                                  color: themeMediumPurple,
                                ),
                                onChanged: (String? value) {
                                  nudgerStates.setTimeType(value!);
                                  setState(() {
                                    time = value;
                                  });
                                },
                                items: times.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 35),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Get notified every ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 35,
                                height: 30,
                                child: TextField(
                                  maxLength: 3,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.deepPurple),
                                    ),
                                  ),
                                  onChanged: (String val) {
                                    debugPrint(val);
                                    nudgerStates.setInterval(val);
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  controller: duration,
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                "minutes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                presentTodos = !presentTodos;
                              });
                            },
                            child: Text(
                              "Get notified only about present tasks",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Switch(
                              activeTrackColor: themePurple,
                              activeColor: themeMediumPurple,
                              value: presentTodos,
                              onChanged: (bool value) {
                                nudgerStates.setOnlyPresent(value);
                                setState(() {
                                  presentTodos = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
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
