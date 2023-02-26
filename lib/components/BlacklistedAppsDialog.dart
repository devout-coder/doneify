import 'package:doneify/states/nudgerState.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class EachApp extends StatefulWidget {
  String appName;
  Uint8List icon;
  bool blacklisted;
  Function checked;
  EachApp(
      {required this.appName,
      required this.icon,
      required this.blacklisted,
      required this.checked,
      super.key});

  @override
  State<EachApp> createState() => _EachAppState();
}

class _EachAppState extends State<EachApp> {
  bool blacklisted = false;
  @override
  void initState() {
    blacklisted = widget.blacklisted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          blacklisted = !blacklisted;
        });
        widget.checked();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 9, 0, 9),
        child: Row(
          children: [
            Checkbox(
                value: blacklisted,
                onChanged: (bool? val) {
                  setState(() {
                    blacklisted = !blacklisted;
                  });
                  widget.checked();
                }),
            Image.memory(
              widget.icon,
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Text(widget.appName),
          ],
        ),
      ),
    );
  }
}

class BlacklistedAppsDialog extends StatefulWidget {
  final double curve;
  BlacklistedAppsDialog({
    super.key,
    required this.curve,
  });

  @override
  State<BlacklistedAppsDialog> createState() => _BlacklistedAppsDialogState();
}

class _BlacklistedAppsDialogState extends State<BlacklistedAppsDialog> {
  NudgerStates nudgerStates = GetIt.I.get();
  List<AppInfo> installedApps = [];
  List<String> blacklistedApps = [];
  String searchQuery = "";

  final ScrollController appScrollController = ScrollController();

  Future loadStuff() async {
    installedApps = nudgerStates.installedApps;
    blacklistedApps = nudgerStates.blacklistedApps;
    // debugPrint("installed apps: $installedApps");
    if (installedApps.isEmpty) {
      installedApps = await InstalledApps.getInstalledApps(true, true);
      nudgerStates.installedApps = installedApps;
    }
  }

  Future? loadedStuff;
  @override
  void initState() {
    super.initState();
    loadedStuff = loadStuff();
  }

  void saveBlacklistedApps() {
    nudgerStates.setBlacklistedApps(blacklistedApps);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        saveBlacklistedApps();
        return true;
      },
      child: Transform.scale(
        scale: widget.curve,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SimpleDialog(
                    contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    children: [
                      TextField(
                        cursorColor: Colors.grey,
                        onChanged: ((value) {
                          List<AppInfo> newApps =
                              nudgerStates.installedApps.where((element) {
                            String appName = element.name!.toLowerCase();
                            return appName.contains(value);
                          }).toList();
                          setState(() {
                            installedApps = newApps;
                          });
                          debugPrint(value);
                        }),
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            hintText: 'Search',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 18),
                            prefixIcon: Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 99, 99, 99),
                              ),
                              width: 18,
                            )),
                      ),
                      FutureBuilder(
                          future: loadedStuff,
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Container(
                                height: screenHeight * 0.6,
                                width: screenWidth * 0.9,
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  controller: appScrollController,
                                  child: ListView.builder(
                                    itemCount: installedApps.length,
                                    itemBuilder: (ctx, index) {
                                      AppInfo app = installedApps[index];
                                      return EachApp(
                                        key: UniqueKey(),
                                        appName: app.name!,
                                        icon: app.icon!,
                                        blacklisted: blacklistedApps
                                            .contains(app.packageName),
                                        checked: () {
                                          if (blacklistedApps
                                              .contains(app.packageName)) {
                                            blacklistedApps
                                                .remove(app.packageName);
                                          } else {
                                            blacklistedApps = [
                                              ...blacklistedApps,
                                              app.packageName!
                                            ];
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                height: screenHeight * 0.6,
                                width: screenWidth * 0.9,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          })
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
