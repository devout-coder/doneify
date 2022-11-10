import 'package:conquer_flutter_app/components/SelectTimeDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/pages/Week.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EachWeekCell extends StatefulWidget {
  DateTime date;
  List<String> unfinishedWeeks;
  DateRangePickerView? currentView;

  EachWeekCell({
    Key? key,
    required this.date,
    required this.unfinishedWeeks,
    required this.currentView,
  }) : super(key: key);

  @override
  State<EachWeekCell> createState() => _EachWeekCellState();
}

DateTime justDate(DateTime entireDate) {
  return DateTime(entireDate.year, entireDate.month, entireDate.day);
}

class _EachWeekCellState extends State<EachWeekCell> {
  List<DateTime> thisWeekDates = [];

  void markThisWeek() {
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(Duration(days: today.weekday - 1));
    for (int i = 0; i < 7; i++) {
      thisWeekDates.add(justDate(startDate.add(Duration(days: i))));
    }
  }

  bool unfinishedWeek() {
    return widget.unfinishedWeeks.contains(formattedWeek(widget.date));
  }

  @override
  void initState() {
    markThisWeek();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: thisWeekDates[0] == widget.date ||
                  startOrEndOfMonth(thisWeekDates, widget.date) == "start"
              ? Radius.circular(25)
              : Radius.circular(0),
          topRight: thisWeekDates[6] == widget.date ||
                  startOrEndOfMonth(thisWeekDates, widget.date) == "end"
              ? Radius.circular(25)
              : Radius.circular(0),
          bottomLeft: thisWeekDates[0] == widget.date ||
                  startOrEndOfMonth(thisWeekDates, widget.date) == "start"
              ? Radius.circular(25)
              : Radius.circular(0),
          bottomRight: thisWeekDates[6] == widget.date ||
                  startOrEndOfMonth(thisWeekDates, widget.date) == "end"
              ? Radius.circular(25)
              : Radius.circular(0),
        ),
        color: thisWeekDates.contains(widget.date)
            ? (unfinishedWeek() ? Color(0xffFFA1C3) : themePurple)
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
            style: thisWeekDates.contains(widget.date)
                ? TextStyle(
                    color: themeDarkPurple,
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    color: widget.unfinishedWeeks
                            .contains(formattedWeek(widget.date))
                        ? Color.fromARGB(255, 255, 142, 142)
                        : Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight:
                        unfinishedWeek() ? FontWeight.w500 : FontWeight.w400,
                  ),
          ),
        ],
      ),
    );
  }
}
