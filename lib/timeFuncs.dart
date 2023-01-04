import 'package:intl/intl.dart';

String formattedTime(String timeType, DateTime time) {
  DateFormat formatter = timeType == "day"
      ? DateFormat("d/M/y")
      : timeType == "month"
          ? DateFormat("MMM y")
          : DateFormat("y");
  String formatted;
  if (timeType == "week") {
    DateTime startDate = time.subtract(Duration(days: time.weekday - 1));
    DateTime endDate = startDate.add(Duration(days: 6));
    formatted =
        "${formattedTime("day", startDate)}-${formattedTime("day", endDate)}";
  } else if (timeType == "longTerm") {
    formatted = "longTerm";
  } else {
    formatted = formatter.format(time);
  }
  return formatted;
}
