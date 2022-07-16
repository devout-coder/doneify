import 'dart:ui';

import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DailyPage extends StatefulWidget {
  DailyPage({Key? key}) : super(key: key);

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  // CalendarFormat _calendarFormat = CalendarFormat.week;
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2099, 12, 31),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              leftChevronIcon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xff9A9A9A),
              ),
              rightChevronIcon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xff9A9A9A),
              ),
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontFamily: "EuclidCircular",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xffffffff)),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Color(0xffEADA76)),
              weekendStyle: TextStyle(color: Color(0xffEADA76)),
            ),
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(
                color: Color(0xffFFFFFF),
              ),
              holidayTextStyle: TextStyle(
                color: Color(0xffFFFFFF),
              ),
              weekendTextStyle: TextStyle(
                color: Color(0xffFFFFFF),
              ),
              outsideTextStyle: TextStyle(
                color: Color(0xff797979),
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xffBA99FF),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Color.fromARGB(255, 47, 15, 83),
                fontWeight: FontWeight.w600,
              ),
            ),
            onDaySelected: (focussedDay, selectedDay) {
              // debugPrint(selectedDay.toString());
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Todos(day: selectedDay)));
            },
          ),
        ),
      ],
    );
  }
}
