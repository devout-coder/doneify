import 'package:flutter/material.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:[
            Color(0xff404049),
            Color(0xff09090E),
          ],
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            buildOffstatgeNavigator(0),
            buildOffstatgeNavigator(1),
            buildOffstatgeNavigator(2),
            buildOffstatgeNavigator(3),
            buildOffstatgeNavigator(4),
            buildOffstatgeNavigator(5),
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

  Widget buildOffstatgeNavigator(int index) {
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
