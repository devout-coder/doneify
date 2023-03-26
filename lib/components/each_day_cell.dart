import 'package:doneify/components/each_week_cell.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/pages/day.dart';
import 'package:doneify/pages/week.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EachDayCell extends StatefulWidget {
  DateTime date;
  List<String> unfinishedDays;
  DateRangePickerView? currentView;

  EachDayCell({
    Key? key,
    required this.date,
    required this.unfinishedDays,
    required this.currentView,
  }) : super(key: key);

  @override
  State<EachDayCell> createState() => _EachDayCellState();
}

class _EachDayCellState extends State<EachDayCell> {
  bool unfinishedDay() {
    return widget.unfinishedDays.contains(formattedDate(widget.date));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: justDate(DateTime.now()) == widget.date
            ? (unfinishedDay() ? Color(0xffFFA1C3) : themePurple)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.currentView == DateRangePickerView.month
                ? widget.date.day.toString()
                : widget.currentView == DateRangePickerView.year
                    ? DateFormat("MMM").format(widget.date)
                    : widget.currentView == DateRangePickerView.decade
                        ? widget.date.year.toString()
                        : "${widget.date.year.toString()} - ${(widget.date.year + 9).toString()}",
            style: justDate(DateTime.now()) == widget.date
                ? TextStyle(
                    color: themeDarkPurple,
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    color: unfinishedDay()
                        ? Color.fromARGB(255, 255, 142, 142)
                        : Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight:
                        unfinishedDay() ? FontWeight.w500 : FontWeight.w400,
                  ),
          ),
        ],
      ),
    );
  }
}
