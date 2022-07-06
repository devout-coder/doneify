import 'dart:ui';

import 'package:conquer_flutter_app/pages/Todos.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// class DailyPage extends StatelessWidget {
//   const DailyPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TableCalendar(
//             focusedDay: DateTime.now(),
//             firstDay: DateTime.utc(2022, 1, 1),
//             lastDay: DateTime.utc(2099, 12, 31)),
//         TextButton(
//             onPressed: () {
//               Navigator.push(
//                   context, MaterialPageRoute(builder: (_) => Todos()));
//             },
//             child: Text("Todos")),
//       ],
//     );
//   }
// }

class DailyPage extends StatefulWidget {
  DailyPage({Key? key}) : super(key: key);

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2099, 12, 31)),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Todos()));
            },
            child: Text("Todos")),
      ],
    );
  }
}
