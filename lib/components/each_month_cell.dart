import 'package:doneify/components/each_week_cell.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/pages/day.dart';
import 'package:doneify/pages/month.dart';
import 'package:doneify/pages/week.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EachMonthCell extends StatefulWidget {
  DateTime date;
  List<String> unfinishedMonths;
  DateRangePickerView? currentView;

  EachMonthCell({
    Key? key,
    required this.date,
    required this.unfinishedMonths,
    required this.currentView,
  }) : super(key: key);

  @override
  State<EachMonthCell> createState() => _EachMonthCellState();
}

class _EachMonthCellState extends State<EachMonthCell> {
  bool unfinishedMonth() {
    return widget.unfinishedMonths.contains(formattedMonth(widget.date));
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
              color: DateTime.now().month == widget.date.month &&
                      DateTime.now().year == widget.date.year
                  ? (unfinishedMonth() ? Color(0xffFFA1C3) : themePurple)
                  : Colors.transparent,
            ),
            width: 80,
            height: 50,
          ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.currentView == DateRangePickerView.year
                    ? DateFormat("MMM").format(widget.date)
                    : widget.currentView == DateRangePickerView.decade
                        ? widget.date.year.toString()
                        : "${widget.date.year.toString()} - ${(widget.date.year + 9).toString()}",
                style: DateTime.now().month == widget.date.month &&
                        DateTime.now().year == widget.date.year
                    ? TextStyle(
                        color: themeDarkPurple,
                        fontSize: 15,
                        fontFamily: 'EuclidCircular',
                        fontWeight: FontWeight.w600,
                      )
                    : TextStyle(
                        color: unfinishedMonth()
                            ? Color.fromARGB(255, 255, 142, 142)
                            : Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontFamily: 'EuclidCircular',
                        fontWeight: unfinishedMonth()
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
