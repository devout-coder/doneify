import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:flutter/cupertino.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class NudgerStates {
  bool accessibilityTurnedOn = false;
  bool nudgerTurnedOn = false;
  List<AppInfo> installedApps = [];
  List<String> blacklistedApps = [];
  String interval = "1";
  String timeType = "Day";
  bool onlyPresent = false;

  void fetchNudgerStates() async {
    accessibilityTurnedOn =
        await platform.invokeMethod("getAccessibilityStatus");
    nudgerTurnedOn = await platform.invokeMethod("getNudgerSwitch");
    if (nudgerTurnedOn && accessibilityTurnedOn) {
      installedApps = await InstalledApps.getInstalledApps(true, true);
      List<Object?> blacklistedAppsObj =
          await platform.invokeMethod("getBlacklistedApps");
      blacklistedApps = blacklistedAppsObj.map((e) => e.toString()).toList();
      timeType = await platform.invokeMethod("getNudgerTimeType");
      interval = await platform.invokeMethod("getInterval");
      onlyPresent = await platform.invokeMethod("getOnlyPresent");
      debugPrint(
          "fetched installed apps while loading the app ${installedApps.length}");
    }
  }

  Future<bool> requestAccessibilityPermission() async {
    bool didEnable =
        await platform.invokeMethod("requestAccessibilityPermission");
    return didEnable;
  }

  Future setNudgerSwitch(bool newState) async {
    nudgerTurnedOn = newState;
    platform.invokeMethod("setNudgerSwitch", {"nudgerSwitch": newState});
    if (newState) {
      accessibilityTurnedOn = true;
      List<Object?> blacklistedAppsObj =
          await platform.invokeMethod("getBlacklistedApps");
      blacklistedApps = blacklistedAppsObj.map((e) => e.toString()).toList();
      timeType = await platform.invokeMethod("getNudgerTimeType");
      interval = await platform.invokeMethod("getInterval");
      onlyPresent = await platform.invokeMethod("getOnlyPresent");

      // if (installedApps != []) {
      //   installedApps = await InstalledApps.getInstalledApps(true, true);
      // }
    }
  }

  void setBlacklistedApps(List<String> newBlacklistedApps) {
    blacklistedApps = newBlacklistedApps;
    platform.invokeMethod(
        "setBlacklistedApps", {"blacklistedApps": newBlacklistedApps});
  }

  void setTimeType(String newTimeType) {
    timeType = newTimeType;
    platform.invokeMethod("setNudgerTimeType", {"timeType": newTimeType});
  }

  void setInterval(String newInterval) {
    if (newInterval != "") {
      interval = newInterval;
      platform.invokeMethod("setInterval", {"interval": newInterval});
    }
  }

  void setOnlyPresent(bool newOnlyPresent) {
    onlyPresent = newOnlyPresent;
    platform.invokeMethod("setOnlyPresent", {"onlyPresent": newOnlyPresent});
  }
}
