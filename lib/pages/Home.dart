import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:conquer_flutter_app/pages/LongTerm.dart';
import 'package:conquer_flutter_app/pages/Monthly.dart';
import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:conquer_flutter_app/pages/Weekly.dart';
import 'package:conquer_flutter_app/pages/Yearly.dart';
import 'package:conquer_flutter_app/pages/Daily.dart';
import 'package:conquer_flutter_app/pages/Settings.dart';
import 'package:conquer_flutter_app/icons/time_type_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (navigatorKeys[currentPage].currentState!.canPop()) {
          navigatorKeys[currentPage]
              .currentState!
              .pop(navigatorKeys[currentPage].currentContext);
        }
        return false;
        //below code does navigate me back to the home page if I am on day page, but when I enter the app again and go to todos page, it navigates to homescreen if I press back button.
        // else {
        //   SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
        // }
      },
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff404049),
                Color(0xff09090E),
              ],
            ),
          ),
          child: Scaffold(
            body: IndexedStack(
              index: currentPage,
              children: [
                DailyNavigator(),
                WeeklyPage(),
                MonthlyPage(),
                YearlyPage(),
                LongTermPage(),
                SettingsPage()
              ],
            ),
            backgroundColor: Colors.transparent,
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
          ),
        ),
      ),
    );
  }
}
