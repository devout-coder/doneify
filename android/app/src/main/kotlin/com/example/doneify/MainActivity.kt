package com.example.doneify

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.*
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import androidx.room.Room
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.*
import io.flutter.plugins.GeneratedPluginRegistrant


val CHANNEL = "alarm_method_channel"

fun handleMethodCalls(context: Context, call: MethodCall?, result: MethodChannel.Result?) {

    val db: AppDB = AppDB.getDatabase(context)
    val activeAlarmDao = db.activeAlarmDAO()
    val todoDAO = db.todoDAO()

    if (call!!.method == "setAlarm") {
        val alarmId: String = call.argument<String>("alarmId")!!
        val time: String = call.argument<String>("time")!!
        val repeatStatus: String = call.argument<String>("repeatStatus")!!
        val repeatEnd: String = padDate(call.argument<String>("repeatEnd")!!)
        val taskId: String = call.argument<String>("taskId")!!
        val taskName: String = call.argument<String>("taskName")!!
        val taskDesc: String = call.argument<String>("taskDesc")!!
        val label: String = call.argument<String>("label")!!
        val finished: Boolean = call.argument<Boolean>("finished")!!
        Thread {
            activeAlarmDao!!.insert(
                ActiveAlarm(
                    alarmId = alarmId,
                    time = time,
                    repeatStatus = repeatStatus,
                    repeatEnd = repeatEnd,
                    taskId = taskId,
                    taskName = taskName,
                    taskDesc = taskDesc,
                    label = label,
                    finished = finished
                )
            )

            val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
            // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
        }.start()

        setAlarm(
            context,
            alarmId,
            time,
            repeatStatus,
            repeatEnd,
            taskId,
            taskName,
            taskDesc,
            label,
            finished
        )
    } else if (call.method == "deleteAlarm") {
        val alarmId: String = call.argument<String>("alarmId")!!
        deleteAlarm(context, alarmId)
    } else if (call.method == "getActiveIds") {
        Thread {
            val activeAlarms: List<ActiveAlarm> = activeAlarmDao!!.getAll()
            val activeAlarmsIds: List<String> =
                activeAlarms.map { activeAlarm -> activeAlarm.alarmId }
            result!!.success(activeAlarmsIds)
            // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
        }.start()
    } else if (call.method == "getAllAlarms") {
        Thread {
            val activeAlarms: List<ActiveAlarm> = activeAlarmDao!!.getAll()
//                    val activeAlarmsMap: List<String> = activeAlarms.map { activeAlarm -> Gson().toJson(activeAlarm) }
            result!!.success(Gson().toJson(activeAlarms))
            // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
        }.start()
    } else if (call.method == "createTodo" || call.method == "updateTodo") {
//        methodChannel!!.invokeMethod("callBack", "data1")
        val id: String = call.argument<String>("id")!!
        Log.d("debugging", "kotlin side: tryna ${call.method}, $id")
        // Log.d("debugging", "in method call receiver: id = $id")
        val taskName: String = call.argument<String>("taskName")!!
        val taskDesc: String = call.argument<String>("taskDesc")!!
        val finished: Boolean = call.argument<Boolean>("finished")!!
        val labelName: String = call.argument<String>("labelName")!!
        val timeStamp: Int = call.argument<Int>("timeStamp")!!
        val time: String = call.argument<String>("time")!!
        val timeType: String = call.argument<String>("timeType")!!
        val index: Int = call.argument<Int>("index")!!
        val todo: Todo = Todo(
            id = id,
            taskName = taskName,
            taskDesc = taskDesc,
            finished = finished,
            labelName = labelName,
            timeStamp = timeStamp,
            time = time,
            timeType = timeType,
            index = index
        )
        Thread {
            if (call.method == "createTodo") {
                Log.d("debugging", "the id used is $id")
                todoDAO!!.insert(todo)
            } else {
                todoDAO!!.update(todo)
            }
        }.start()
    } else if (call.method == "deleteTodo") {
        val id: String = call.argument<String>("id")!!
        Log.d("debugging", "kotlin side: tryna ${call.method}, $id")
        var reqTodo: Todo?
        Thread {
            val fetchedTodos: List<Todo> = todoDAO!!.getById(id)
            if (fetchedTodos.isNotEmpty()) {
                reqTodo = fetchedTodos[0]
                todoDAO.delete(reqTodo!!)
            }
        }.start()
    }
}

var methodChannel: MethodChannel? = null

class MainActivity : FlutterActivity() {

//    lateinit var newFlutterEngine: FlutterEngine

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        val receiver = ComponentName(context, BootReceiver::class.java)
        context.packageManager.setComponentEnabledSetting(
            receiver,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )


        val sound: Uri =
            Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE.toString() + "://" + context.packageName + "/" + R.raw.rooster)
        val attributes: AudioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .build()
        val mChannel = NotificationChannel("alarms", "Alarms", NotificationManager.IMPORTANCE_HIGH)
        mChannel.description = "This pertains to all the alarms set by the user"
        mChannel.setSound(sound, attributes)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(mChannel)


//        newFlutterEngine = FlutterEngine(this);
////        newFlutterEngine.navigationChannel.setInitialRoute("inputModal");
//        // Start executing Dart code to pre-warm the FlutterEngine.
//        newFlutterEngine.getDartExecutor().executeDartEntrypoint(
//            DartExecutor.DartEntrypoint.createDefault()
//        );
//        // Cache the FlutterEngine to be used by FlutterActivity.
//        FlutterEngineCache
//            .getInstance()
//            .put("doneify", newFlutterEngine);
//        Log.d("debugging", "inside default flutter engine")

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        methodChannel!!.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
            handleMethodCalls(context, call, result)
        }
    }
}

fun padDate(date: String): String {
    val components: MutableList<String> = date.split('/').toMutableList()
    components[0] = components[0].padStart(2, '0')
    components[1] = components[1].padStart(2, '0')
    return components.joinToString("/")

}

fun setAlarm(
    context: Context,
    alarmId: String,
    time: String,
    repeatStatus: String,
    repeatEnd: String,
    taskId: String,
    taskName: String,
    taskDesc: String,
    label: String,
    finished: Boolean
) {
    Log.d(
        "debugging",
        "alarm set from dart: $alarmId, $time, $repeatStatus, $repeatEnd, $taskId, $taskName, $taskDesc, $label, $finished"
    )

    val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
        putExtra("alarmId", alarmId)
//        putExtra("time", time)
//        putExtra("repeatStatus", repeatStatus)
//        putExtra("repeatEnd", padDate(repeatEnd))
//        putExtra("taskId", taskId)
//        putExtra("taskName", taskName);
//        putExtra("taskDesc", taskDesc);
//        putExtra("label", label)
//        putExtra("finished", finished)
    }
    val pendingAlarmIntent =
        PendingIntent.getBroadcast(
            context,
            alarmId.toInt(),
            alarmIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    var interval: Long = 0;
    when (repeatStatus) {
        "everyDay" -> {
            interval = AlarmManager.INTERVAL_DAY
        }
        "everyWeek" -> {
            interval = AlarmManager.INTERVAL_DAY * 7
        }
        "everyMonth" -> {
            interval = AlarmManager.INTERVAL_DAY * 30
        }
        "everyYear" -> {
            interval = AlarmManager.INTERVAL_DAY * 365
        }
    }

    val date: String = time.split(", ")[0]
    val realTime: String = time.split(", ")[1]
    val day: Int = date.split("/")[0].toInt()
    val month: Int = date.split("/")[1].toInt() - 1
    val year: Int = date.split("/")[2].toInt()
    val hour: Int = realTime.split(":")[0].toInt()
    val minute: Int = realTime.split(":")[1].toInt()
    val calendar: Calendar = Calendar.getInstance().apply {
        timeInMillis = System.currentTimeMillis()
        clear()
        set(Calendar.YEAR, year)
        set(Calendar.MONTH, month)
        set(Calendar.DAY_OF_MONTH, day)
        set(Calendar.HOUR_OF_DAY, hour)
        set(Calendar.MINUTE, minute)
    }
    val alarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
    if (repeatStatus == "once") {
        alarmManager!!.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            pendingAlarmIntent
        )
    } else {
        alarmManager!!.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            interval,
            pendingAlarmIntent
        )
    }
    Log.d("debugging", "alarm set successfully")
}

fun deleteAlarm(context: Context, alarmId: String) {
    Thread {
        var reqAlarm: ActiveAlarm?
        val db: AppDB = AppDB.getDatabase(context)
        val activeAlarmDao = db.activeAlarmDAO()
        val fetchedAlarms: List<ActiveAlarm> = activeAlarmDao!!.getById(alarmId)
        if (fetchedAlarms.isNotEmpty()) {
            reqAlarm = fetchedAlarms[0]
            activeAlarmDao.delete(reqAlarm)

            val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
            // Log.d("debugging", "in deleteAlarm method kotlin, all active alarms: $activeAlarms")

            Log.d(
                "debugging",
                "alarm deleted: $alarmId, ${reqAlarm.time}, ${reqAlarm.repeatStatus}, ${reqAlarm.repeatEnd}, ${reqAlarm.taskId}, ${reqAlarm.taskName}, ${reqAlarm.taskDesc}, ${reqAlarm.label}, ${reqAlarm.finished}"
            )
            val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("alarmId", alarmId)
            }
            val pendingAlarmIntent =
                PendingIntent.getBroadcast(
                    context,
                    alarmId.toInt(),
                    alarmIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager!!.cancel(pendingAlarmIntent)
        }
    }.start()
}

