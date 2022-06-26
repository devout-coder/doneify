import 'dart:ffi';
import 'package:conquer_flutter_app/pages/LongTerm.dart';
import 'package:conquer_flutter_app/pages/Monthly.dart';
import 'package:conquer_flutter_app/pages/Weekly.dart';
import 'package:conquer_flutter_app/pages/Yearly.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:conquer_flutter_app/pages/Settings.dart';
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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
  List<Widget> pages = const [
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
      appBar: AppBar(
        title: const Text("Conquer"),
      ),
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            label: "Daily",
            icon: SvgPicture.asset(
              "images/Daily.svg",
              color: Colors.black,
              height: 30,
              width: 30,
            ),
          ),
          NavigationDestination(
            label: "Weekly",
            icon: SvgPicture.asset("images/Weekly.svg"),
          ),
          NavigationDestination(
            label: "Monthly",
            icon: SvgPicture.asset(
              "images/Monthly.svg",
              height: 30,
              width: 30,
            ),
          ),
          NavigationDestination(
            label: "Yearly",
            icon: SvgPicture.asset(
              "images/Yearly.svg",
              height: 30,
              width: 30,
            ),
          ),
          NavigationDestination(
            label: "Long Term",
            icon: SvgPicture.asset(
              "images/LongTerm.svg",
              height: 30,
              width: 30,
            ),
          ),
          const NavigationDestination(
            label: "Settings",
            icon: Icon(Icons.today),
          ),
        ],
        selectedIndex: currentPage,
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
      ),
    );
  }
}
