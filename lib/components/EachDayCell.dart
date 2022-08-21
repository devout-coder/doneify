import 'package:conquer_flutter_app/components/EachWeekCell.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/pages/Day.dart';
import 'package:conquer_flutter_app/pages/Week.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: justDate(DateTime.now()) == widget.date
            ? themePurple
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
                    color: widget.unfinishedDays
                            .contains(formattedDate(widget.date))
                        ? Color.fromARGB(255, 170, 0, 0)
                        : Color.fromARGB(255, 47, 15, 83),
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight: FontWeight.w600,
                  )
                : TextStyle(
                    color: widget.unfinishedDays
                            .contains(formattedDate(widget.date))
                        ? Color.fromARGB(255, 255, 105, 105)
                        : Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                    fontFamily: 'EuclidCircular',
                    fontWeight: FontWeight.w400,
                  ),
          ),
        ],
      ),
    );
  }
}
