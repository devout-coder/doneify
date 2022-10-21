import 'package:conquer_flutter_app/globalColors.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:conquer_flutter_app/pages/LongTerm.dart';
import 'package:conquer_flutter_app/pages/Month.dart';
import 'package:conquer_flutter_app/pages/Week.dart';
import 'package:conquer_flutter_app/pages/Year.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/Settings.dart';
import 'package:conquer_flutter_app/icons/time_type_icons.dart';
import 'package:conquer_flutter_app/navigatorKeys.dart';
import 'package:conquer_flutter_app/states/labelsAPI.dart';
import 'package:conquer_flutter_app/states/selectedFilters.dart';

class HomePage extends StatefulWidget {
  String? launchFromWidgetTimeType;
  String? launchFromWidgetCommand;
  HomePage({
    Key? key,
    required this.launchFromWidgetTimeType,
    required this.launchFromWidgetCommand,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  var timeTypeMap = {
    'Day': 0,
    'Week': 1,
    "Month": 2,
    "Year": 3,
    "Long Term": 4
  };

  @override
  void initState() {
    super.initState();
    debugPrint("In Home ${widget.launchFromWidgetTimeType}");
    if (widget.launchFromWidgetTimeType == null) {
      currentPage = 0;
    } else {
      currentPage = timeTypeMap[widget.launchFromWidgetTimeType]!;
    }
    // currentPage = timeType != null ? timeTypeMap[timeType]! : 0;
  }

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
                DayNavigator(),
                WeekNavigator(),
                MonthNavigator(),
                YearNavigator(),
                LongTermPage(),
                SettingsPage()
              ],
            ),
            backgroundColor: Colors.transparent,
            bottomNavigationBar: GNav(
              tabBorderRadius: 25,
              gap: 5, // the tab button gap between icon and text
              color: const Color(0xff9A9A9A),
              activeColor: themeDarkPurple, // selected icon and text color
              tabBackgroundColor:
                  themePurple.withOpacity(0.9), // selected tab background color
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
