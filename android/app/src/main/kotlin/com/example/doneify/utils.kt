package com.example.doneify
import java.time.DayOfWeek
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAdjusters

//fun formattedTime(timeType: String, time: LocalDateTime): String {
//    val formatter = when (timeType) {
//        "day" -> DateTimeFormatter.ofPattern("d/M/y")
//        "month" -> DateTimeFormatter.ofPattern("MMM y")
//        else -> DateTimeFormatter.ofPattern("y")
//    }
//
//    val formatted: String
//    when (timeType) {
//        "week" -> {
////            val startDate = time.minusDays(time.dayOfWeek.value - 1)
////            val endDate = startDate.plusDays(6)
//            val startDate = time.toLocalDate().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
//            val adjustedStartDate = startDate.atTime(time.toLocalTime())
//            val endDate = adjustedStartDate.plusDays(6)
//            formatted = "${formattedTime("day", adjustedStartDate)}-${formattedTime("day", endDate)}"
//        }
//        "longTerm" -> {
//            formatted = "longTerm"
//        }
//        else -> {
//            formatted = time.format(formatter)
//        }
//    }
//    return formatted
//}
//
//fun main() {
//    val today = LocalDateTime.now() // Get the current LocalDateTime
//    val formatted = formattedTime("day", today) // Call the function with "day" timeType and the LocalDateTime instance
//    println("Formatted time: $formatted")
//}

fun formattedTime(timeType: String, time: LocalDateTime): String {

    var formatter: DateTimeFormatter =
        if (timeType == "day") DateTimeFormatter.ofPattern("d/M/yyyy") else if (timeType == "month") DateTimeFormatter.ofPattern(
            "MMM yyyy"
        ) else DateTimeFormatter.ofPattern(
            "yyyy"
        )

    val formatted: String
    if (timeType == "week") {
        val firstDay = time.minusDays((time.dayOfWeek.value - 1).toLong())
        val lastDay = firstDay.plusDays(6)
        formatted =
            "${formattedTime("day", firstDay)}-${formattedTime("day", lastDay)}";
    } else if (timeType == "longTerm") {
        formatted = "longTerm";
    } else {
        formatted = formatter.format(time);
    }

    return formatted
}

fun isPresent(time: String, timeType: String): Boolean {
    val current = LocalDateTime.now()
//    val formatter: DateTimeFormatter
//    Log.d("debugging", "$timeType: ${formattedTime(timeType, current)}")
//    Log.d("debugging", "$timeType: ${time == formattedTime(timeType, current)}")

    return time == formattedTime(timeType, current)
}
