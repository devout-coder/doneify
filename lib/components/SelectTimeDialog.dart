import 'package:conquer_flutter_app/components/EachWeekCell.dart';
import 'package:conquer_flutter_app/components/SetAlarmDialog.dart';
import 'package:conquer_flutter_app/globalColors.dart';
import 'package:conquer_flutter_app/impClasses.dart';
import 'package:conquer_flutter_app/pages/InputModal.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class SelectTimeDialog extends StatefulWidget {
  final double curve;
  String timeType;
  DateTime? selectedTime;
  List<DateTime> selectedWeekDates = [];
  List<Alarm>? taskAlarms;
  List<Alarm> deletedTaskAlarms;
  final Function updateSelectedWeekDates;
  final Function updateSelectedTime;
  final Function updateTaskAlarms;
  final Function updateDeletedTaskAlarms;
  SelectTimeDialog({
    Key? key,
    required this.curve,
    required this.timeType,
    required this.selectedTime,
    required this.selectedWeekDates,
    required this.updateSelectedWeekDates,
    required this.updateSelectedTime,
    required this.taskAlarms,
    required this.deletedTaskAlarms,
    required this.updateTaskAlarms,
    required this.updateDeletedTaskAlarms,
  }) : super(key: key);

  @override
  State<SelectTimeDialog> createState() => _SelectTimeDialogState();
}

class _SelectTimeDialogState extends State<SelectTimeDialog> {
  final DateRangePickerController _controller = DateRangePickerController();

  String startOrEndOfMonth(DateTime date) {
    String retString = "none";
    if (widget.selectedWeekDates.contains(justDate(date))) {
      DateTime reqDay = widget.selectedWeekDates[0];
      if (date.day == 1) {
        retString = "start";
      } else if (date.day == DateTime(reqDay.year, reqDay.month + 1, 0).day) {
        retString = "end";
      }
    }
    return retString;
  }

  bool isSelectedTime(DateTime date) {
    return (widget.timeType == "week" &&
            widget.selectedWeekDates.contains(date)) ||
        (widget.timeType == "day" &&
            justDate(widget.selectedTime!) == justDate(date)) ||
        (widget.timeType == "month" &&
            (widget.selectedTime!.month == date.month &&
                widget.selectedTime!.year == date.year)) ||
        (widget.timeType == "year" && widget.selectedTime!.year == date.year);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Transform.scale(
      scale: widget.curve,
      child: Column(
        children: [
          Expanded(
            child: SimpleDialog(
              contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 5),
              backgroundColor: modalDark,
              children: [
                Container(
                  height: screenHeight * 0.85,
                  width: screenWidth,
                  color: modalDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.timeType != "longTerm"
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: const Text(
                                    "Select time:",
                                    style: TextStyle(
                                      fontFamily: "EuclidCircular",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      color: Color(0xffffffff),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SfDateRangePicker(
                                  controller: _controller,
                                  initialSelectedDate: null,
                                  allowViewNavigation:
                                      widget.timeType == "week" ||
                                          widget.timeType == "day",
                                  view: widget.timeType == "month"
                                      ? DateRangePickerView.year
                                      : widget.timeType == "year"
                                          ? DateRangePickerView.decade
                                          : DateRangePickerView.month,
                                  headerStyle: const DateRangePickerHeaderStyle(
                                    textAlign: TextAlign.center,
                                    textStyle: TextStyle(
                                      fontFamily: "EuclidCircular",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 171, 171, 171),
                                    ),
                                  ),
                                  monthViewSettings:
                                      const DateRangePickerMonthViewSettings(
                                    viewHeaderStyle:
                                        DateRangePickerViewHeaderStyle(
                                      textStyle:
                                          TextStyle(color: Color(0xffEADA76)),
                                    ),
                                    firstDayOfWeek: 1,
                                  ),
                                  todayHighlightColor: Color(0xffEADA76),
                                  headerHeight: 40,
                                  selectionColor: Colors.transparent,
                                  onSelectionChanged: (args) {
                                    if (_controller.selectedDate != null) {
                                      setState(() {
                                        if (widget.timeType == "week") {
                                          widget.updateSelectedWeekDates(
                                              allDatesInWeek(
                                                  _controller.selectedDate!));
                                          widget.selectedWeekDates =
                                              allDatesInWeek(
                                                  _controller.selectedDate!);
                                        } else {
                                          widget.updateSelectedTime(
                                              _controller.selectedDate);
                                          widget.selectedTime =
                                              _controller.selectedDate;
                                        }
                                        debugPrint(
                                            widget.selectedTime.toString());
                                      });
                                    }
                                  },
                                  cellBuilder: (BuildContext context,
                                      DateRangePickerCellDetails details) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: widget.timeType == "week"
                                            ? BorderRadius.only(
                                                topLeft:
                                                    widget.selectedWeekDates[
                                                                    0] ==
                                                                details.date ||
                                                            startOrEndOfMonth(
                                                                    details
                                                                        .date) ==
                                                                "start"
                                                        ? Radius.circular(25)
                                                        : Radius.circular(0),
                                                topRight:
                                                    widget.selectedWeekDates[
                                                                    6] ==
                                                                details.date ||
                                                            startOrEndOfMonth(
                                                                    details
                                                                        .date) ==
                                                                "end"
                                                        ? Radius.circular(25)
                                                        : Radius.circular(0),
                                                bottomLeft:
                                                    widget.selectedWeekDates[
                                                                    0] ==
                                                                details.date ||
                                                            startOrEndOfMonth(
                                                                    details
                                                                        .date) ==
                                                                "start"
                                                        ? Radius.circular(25)
                                                        : Radius.circular(0),
                                                bottomRight:
                                                    widget.selectedWeekDates[
                                                                    6] ==
                                                                details.date ||
                                                            startOrEndOfMonth(
                                                                    details
                                                                        .date) ==
                                                                "end"
                                                        ? Radius.circular(25)
                                                        : Radius.circular(0),
                                              )
                                            : BorderRadius.all(
                                                Radius.circular(20)),
                                        color: isSelectedTime(details.date)
                                            ? themePurple
                                            : Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _controller.view ==
                                                    DateRangePickerView.month
                                                ? details.date.day.toString()
                                                : _controller.view ==
                                                        DateRangePickerView.year
                                                    ? DateFormat("MMM")
                                                        .format(details.date)
                                                    : _controller.view ==
                                                            DateRangePickerView
                                                                .decade
                                                        ? details.date.year
                                                            .toString()
                                                        : "${details.date.year.toString()} - ${(details.date.year + 9).toString()}",
                                            style: isSelectedTime(details.date)
                                                ? TextStyle(
                                                    color: themeDarkPurple,
                                                    fontSize: 15,
                                                    fontFamily:
                                                        'EuclidCircular',
                                                    fontWeight: FontWeight.w600,
                                                  )
                                                : TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    fontSize: 15,
                                                    fontFamily:
                                                        'EuclidCircular',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel: "Select Time",
                                        pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double>
                                                secondaryAnimation) {
                                          return Container();
                                        },
                                        transitionBuilder:
                                            (ctx, a1, a2, child) {
                                          var curve = Curves.easeInOut
                                              .transform(a1.value);
                                          return SetAlarmDialog(
                                            curve: curve,
                                            timeType: widget.timeType,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0),
                                        ),
                                        primary: themeDarkPurple,
                                        elevation: 2,
                                        backgroundColor: themePurple),
                                    child: Text(
                                      "Add alarm",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}