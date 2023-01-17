import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:flutter/cupertino.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class NudgerStates {
  bool accessibilityTurnedOn = false;
  bool nudgerTurnedOn = false;
  List<AppInfo> installedApps = [];
  List<String> blacklistedApps = [];

  void setNudgerSwitch(bool newState) async {
    nudgerTurnedOn = newState;
    platform.invokeMethod("setNudgerSwitch", {"nudgerSwitch": newState});
    if (newState) {
      accessibilityTurnedOn = true;
      List<Object?> blacklistedAppsObj =
          await platform.invokeMethod("getBlacklistedApps");
      blacklistedApps = blacklistedAppsObj.map((e) => e.toString()).toList();
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

  Future<bool> requestAccessibilityPermission() async {
    bool didEnable =
        await platform.invokeMethod("requestAccessibilityPermission");
    return didEnable;
  }

  void fetchNudgerStates() async {
    accessibilityTurnedOn =
        await platform.invokeMethod("getAccessibilityStatus");
    nudgerTurnedOn = await platform.invokeMethod("getNudgerSwitch");
    if (nudgerTurnedOn && accessibilityTurnedOn) {
      installedApps = await InstalledApps.getInstalledApps(true, true);
      List<Object?> blacklistedAppsObj =
          await platform.invokeMethod("getBlacklistedApps");
      blacklistedApps = blacklistedAppsObj.map((e) => e.toString()).toList();
      debugPrint(
          "fetched installed apps while loading the app ${installedApps.length}");
    }
  }
}
