import 'package:doneify/components/each_week_cell.dart';
import 'package:doneify/components/set_alarm_dialog.dart';
import 'package:doneify/globalColors.dart';
import 'package:doneify/impClasses.dart';
import 'package:doneify/pages/input_modal.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class SelectTimeDialog extends StatefulWidget {
  final double curve;
  String timeType;
  DateTime? selectedTime;
  List<DateTime> selectedWeekDates = [];
  List<Alarm> alarms;
  List<Alarm> deletedAlarms;
  final Function updateDeletedAlarms;
  int taskId;
  List<Alarm> createdAlarms;
  final Function updateCreatedAlarms;
  final Function updateSelectedWeekDates;
  final Function updateSelectedTime;
  SelectTimeDialog({
    Key? key,
    required this.curve,
    required this.taskId,
    required this.timeType,
    required this.selectedTime,
    required this.selectedWeekDates,
    required this.updateSelectedWeekDates,
    required this.updateSelectedTime,
    required this.alarms,
    required this.createdAlarms,
    required this.updateCreatedAlarms,
    required this.deletedAlarms,
    required this.updateDeletedAlarms,
  }) : super(key: key);

  @override
  State<SelectTimeDialog> createState() => _SelectTimeDialogState();
}

String startOrEndOfMonth(List<DateTime> selectedWeekDates, DateTime date) {
  String retString = "none";
  if (selectedWeekDates.contains(justDate(date))) {
    DateTime reqDay = selectedWeekDates[0];
    if (date.day == 1) {
      retString = "start";
    } else if (date.day == DateTime(reqDay.year, reqDay.month + 1, 0).day) {
      retString = "end";
    }
  }
  return retString;
}

class _SelectTimeDialogState extends State<SelectTimeDialog> {
  final DateRangePickerController _controller = DateRangePickerController();

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
    debugPrint("selected time is ${widget.selectedTime}");
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
                                  initialDisplayDate: widget.selectedTime,
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
                                        // debugPrint(
                                        //     widget.selectedTime.toString());
                                      });
                                    }
                                  },
                                  cellBuilder: (BuildContext context,
                                      DateRangePickerCellDetails details) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: widget.timeType == "week"
                                            ? BorderRadius.only(
                                                topLeft: widget.selectedWeekDates[
                                                                0] ==
                                                            details.date ||
                                                        startOrEndOfMonth(
                                                                widget
                                                                    .selectedWeekDates,
                                                                details.date) ==
                                                            "start"
                                                    ? Radius.circular(25)
                                                    : Radius.circular(0),
                                                topRight: widget.selectedWeekDates[
                                                                6] ==
                                                            details.date ||
                                                        startOrEndOfMonth(
                                                                widget
                                                                    .selectedWeekDates,
                                                                details.date) ==
                                                            "end"
                                                    ? Radius.circular(25)
                                                    : Radius.circular(0),
                                                bottomLeft: widget.selectedWeekDates[
                                                                0] ==
                                                            details.date ||
                                                        startOrEndOfMonth(
                                                                widget
                                                                    .selectedWeekDates,
                                                                details.date) ==
                                                            "start"
                                                    ? Radius.circular(25)
                                                    : Radius.circular(0),
                                                bottomRight:
                                                    widget.selectedWeekDates[
                                                                    6] ==
                                                                details.date ||
                                                            startOrEndOfMonth(
                                                                    widget
                                                                        .selectedWeekDates,
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
                              ],
                            )
                          : Container(),
                      SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          child: Text(
                            "Add alarm",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              primary: themeDarkPurple,
                              elevation: 2,
                              backgroundColor: themePurple),
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Select Time",
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation) {
                                return Container();
                              },
                              transitionBuilder: (ctx, a1, a2, child) {
                                var curve =
                                    Curves.easeInOut.transform(a1.value);
                                return SetAlarmDialog(
                                  taskId: widget.taskId,
                                  curve: curve,
                                  timeType: widget.timeType,
                                  updateCreatedAlarms:
                                      widget.updateCreatedAlarms,
                                  selectedTime: widget.selectedTime,
                                  selectedWeekDates: widget.selectedWeekDates,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: screenHeight * 0.3,
                        child: ListView.builder(
                            itemCount: widget.alarms.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${widget.alarms[index].repeatStatus}, ${widget.alarms[index].time}"),
                                  IconButton(
                                    tooltip: "Delete",
                                    color: Color.fromARGB(255, 255, 103, 103),
                                    onPressed: () {
                                      setState(() {
                                        widget.updateDeletedAlarms(
                                            widget.alarms[index]);
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              );
                            }),
                      ),
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
