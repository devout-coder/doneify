package com.example.doneify

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter


//fun isPresent(time: String) : Boolean{
// 4/1/2023
// 2/1/2023-8/1/2023
// Aug 2023
//2024
//longTerm
// }

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
    Log.d("debugging", "$timeType: ${formattedTime(timeType, current)}")
    Log.d("debugging", "$timeType: ${time == formattedTime(timeType, current)}")

    return time == formattedTime(timeType, current)
}

class NudgerFlutterActivity : FlutterActivity() {

    companion object {
        var methodChannelInvoker: (MethodCall, MethodChannel.Result) -> Unit = { _, _ -> }

//        fun withCachedEngine(cachedEngineId: String): CachedEngineIntentBuilder {
//            return CachedEngineIntentBuilder(WidgetFlutterActivity::class.java, cachedEngineId)
//        }

        fun withNewEngine(): NewEngineIntentBuilder {
            return NewEngineIntentBuilder(NudgerFlutterActivity::class.java)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                methodChannelInvoker(call, result)
            }
    }
}

class NudgerAlarmReceiver : BroadcastReceiver() {

    private fun buildPendingIntent(
        context: Context,
    ): PendingIntent? {

        Log.d("debugging", "building app to be opened")
        NudgerFlutterActivity.methodChannelInvoker = { call, result ->
            handleMethodCalls(context, call, result)
        }
        return PendingIntent.getActivity(
            context,
            0,
            NudgerFlutterActivity
                .withNewEngine()
                .initialRoute("/")
                .build(context),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun buildNotification(
        context: Context,
        notifString: String,
        noTodos: Int
    ): NotificationCompat.Builder {
        val b: NotificationCompat.Builder = NotificationCompat.Builder(context, "alarms")
        b.setSmallIcon(R.drawable.doneify_notification_icon)
            .setContentTitle("$noTodos tasks are due")
            .setStyle(
                NotificationCompat.BigTextStyle().bigText(notifString)
            )
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setFullScreenIntent(
                buildPendingIntent(
                    context,
                ), true
            )
            .setAutoCancel(true)

        return (b)
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d("debugging", "received nudger alarm")
        Log.d("debugging", "navigating back home")


        var timeTypeHash: HashMap<String, String> = HashMap<String, String>()
        timeTypeHash.put("Day", "day")
        timeTypeHash.put("Week", "week")
        timeTypeHash.put("Month", "month")
        timeTypeHash.put("Year", "year")
        timeTypeHash.put("Long Term", "longTerm")


        val sharedPref: SharedPreferences = context!!.getSharedPreferences(
            "nudger", Context.MODE_PRIVATE
        )
        val timeType = timeTypeHash[sharedPref.getString("timeType", "Day")]
        CoroutineScope(Dispatchers.Main.immediate).launch {
            val db: AppDB = AppDB.getDatabase(context)
            val todoDAO = db.todoDAO()
            var todos: List<Todo> = todoDAO!!.getByTimeType(timeType!!)
            if (sharedPref.getBoolean("onlyPresent", false)) {
                Log.d("debugging", "this is run")
                todos = todos.filter { todo -> isPresent(todo.time!!, todo.timeType!!) }
            }
            Log.d("debugging", "todos actually shown by nudger: $todos")
            val todoNames: List<String> = todos.map { todo -> todo.taskName!! }
            var notifString: String = ""
            for (todo in todoNames) {
                notifString += "• $todo\n"
            }

            if (todoNames.isNotEmpty()) {
                val startMain = Intent(Intent.ACTION_MAIN)
                startMain.addCategory(Intent.CATEGORY_HOME)
                startMain.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(startMain)

                val notificationManager: NotificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(
                    69,
                    buildNotification(context, notifString, todoNames.size).build()
                )
            }
        }
    }
}