import 'package:doneify/components/each_week_cell.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/pages/day.dart';
import 'package:doneify/pages/week.dart';
import 'package:doneify/pages/year.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EachYearCell extends StatefulWidget {
  DateTime date;
  List<String> unfinishedYears;
  DateRangePickerView? currentView;

  EachYearCell({
    Key? key,
    required this.date,
    required this.unfinishedYears,
    required this.currentView,
  }) : super(key: key);

  @override
  State<EachYearCell> createState() => _EachYearCellState();
}

class _EachYearCellState extends State<EachYearCell> {
  bool unfinishedYear() {
    return widget.unfinishedYears.contains(formattedYear(widget.date));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.all(Radius.circular(30)),
      //   color: DateTime.now().month == widget.date.month &&
      //           DateTime.now().year == widget.date.year
      //       ? themePurple
      //       : Colors.transparent,
      // ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Align(
          //   alignment: AlignmentDirectional.topStart, // <-- SEE HERE
          //   child: Container(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: DateTime.now().year == widget.date.year
                  ? (unfinishedYear() ? Color(0xffFFA1C3) : themePurple)
                  : Colors.transparent,
            ),
            width: 70,
            height: 50,
          ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.date.year.toString(),
                style: DateTime.now().year == widget.date.year
                    ? TextStyle(
                        color: themeDarkPurple,
                        fontSize: 15,
                        fontFamily: 'EuclidCircular',
                        fontWeight: FontWeight.w600,
                      )
                    : TextStyle(
                        color: unfinishedYear()
                            ? Color.fromARGB(255, 255, 142, 142)
                            : Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontFamily: 'EuclidCircular',
                        fontWeight: unfinishedYear()
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
