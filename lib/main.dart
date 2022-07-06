import 'dart:ffi';
import 'package:conquer_flutter_app/pages/LongTerm.dart';
import 'package:conquer_flutter_app/pages/Monthly.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/pages/Weekly.dart';
import 'package:conquer_flutter_app/pages/Yearly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:conquer_flutter_app/pages/Settings.dart';
import 'package:conquer_flutter_app/icons/time_type_icons.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primarySwatch: Colors.deepPurple, fontFamily: "Cantarell"),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;
  List<Widget> pages = [
    DailyPage(),
    WeeklyPage(),
    MonthlyPage(),
    YearlyPage(),
    LongTermPage(),
    SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
          _buildOffstageNavigator(2),
          _buildOffstageNavigator(3),
          _buildOffstageNavigator(4),
          _buildOffstageNavigator(5),
        ],
      ),
      backgroundColor: const Color(0xff262647),
      bottomNavigationBar: GNav(
        tabBorderRadius: 25,
        gap: 5, // the tab button gap between icon and text
        color: const Color(0xff9A9A9A),
        activeColor: const Color.fromARGB(
            255, 47, 15, 83), // selected icon and text color
        tabBackgroundColor: const Color(0xffBA99FF)
            .withOpacity(0.9), // selected tab background color
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 15), // navigation bar padding

        tabs: const [
          GButton(
            icon: TimeTypeIcons.day,
            text: "Day",
          ),
          GButton(
            icon: TimeTypeIcons.week,
            text: "Week",
          ),
          GButton(
            icon: TimeTypeIcons.month,
            text: "Month",
          ),
          GButton(
            icon: TimeTypeIcons.year,
            text: "Year",
          ),
          GButton(
            icon: TimeTypeIcons.longterm,
            text: "Long Term",
          ),
          GButton(
            icon: Icons.settings,
            text: "Settings",
          ),
        ],
        selectedIndex: currentPage,
        onTabChange: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          DailyPage(),
          WeeklyPage(),
          MonthlyPage(),
          YearlyPage(),
          LongTermPage(),
          SettingsPage()
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: currentPage != index,
      child: Navigator(
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }
}
