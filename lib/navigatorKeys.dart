import 'package:flutter/material.dart';

GlobalKey<NavigatorState> dayNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> weekNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> monthNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> yearNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> longTermNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> settingsNavigatorKey = GlobalKey<NavigatorState>();

List<GlobalKey<NavigatorState>> navigatorKeys = [
  dayNavigatorKey,
  weekNavigatorKey,
  monthNavigatorKey,
  yearNavigatorKey,
  longTermNavigatorKey,
  settingsNavigatorKey
];
