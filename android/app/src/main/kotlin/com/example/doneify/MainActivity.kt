package com.example.doneify

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.AsyncTask
import android.util.Log
import androidx.annotation.NonNull
import androidx.room.Room
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap


var methodChannel: MethodChannel? = null

class MainActivity : FlutterActivity() {
    private val CHANNEL = "alarm_method_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val receiver = ComponentName(context, BootReceiver::class.java)
        context.packageManager.setComponentEnabledSetting(
                receiver,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
        )


        val sound: Uri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE.toString() + "://" + context.packageName + "/" + R.raw.rooster)
        val attributes: AudioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()
        val mChannel = NotificationChannel("alarms", "Alarms", NotificationManager.IMPORTANCE_HIGH)
        mChannel.description = "This pertains to all the alarms set by the user"
        mChannel.setSound(sound, attributes)
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(mChannel)


        methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL)
        methodChannel!!.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->

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
                    val db = Room.databaseBuilder(
                            context,
                            AppDatabase::class.java, "active_alarms"
                    ).build()
                    val activeAlarmDao = db.ActiveAlarmDao()
                    activeAlarmDao.insert(ActiveAlarm(alarmId = alarmId, time = time, repeatStatus = repeatStatus, repeatEnd = repeatEnd, taskId = taskId, taskName = taskName, taskDesc = taskDesc, label = label, finished = finished))

                    val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                    Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
                }.start()

                setAlarm(this, alarmId, time, repeatStatus, repeatEnd, taskId, taskName, taskDesc, label, finished)
            } else if (call.method == "deleteAlarm") {
                val alarmId: String = call.argument<String>("alarmId")!!
                deleteAlarm(this, alarmId)
            } else if (call.method == "getActiveIds") {
                Thread {
                    val db = Room.databaseBuilder(
                            context,
                            AppDatabase::class.java, "active_alarms"
                    ).build()
                    val activeAlarmDao = db.ActiveAlarmDao()
                    val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                    val activeAlarmsIds: List<String> = activeAlarms.map { activeAlarm -> activeAlarm.alarmId }
                    result!!.success(activeAlarmsIds)
                    Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
                }.start()
            } else if (call.method == "getAllAlarms") {
                Thread {
                    val db = Room.databaseBuilder(
                            context,
                            AppDatabase::class.java, "active_alarms"
                    ).build()
                    val activeAlarmDao = db.ActiveAlarmDao()
                    val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
//                    val activeAlarmsMap: List<String> = activeAlarms.map { activeAlarm -> Gson().toJson(activeAlarm) }
                    result!!.success(Gson().toJson(activeAlarms))
                    Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
                }.start()
            }
        }
    }
}

fun padDate(date: String): String {
    val components: MutableList<String> = date.split('/').toMutableList()
    components[0] = components[0].padStart(2, '0')
    components[1] = components[1].padStart(2, '0')
    return components.joinToString("/")

}

fun setAlarm(context: Context, alarmId: String, time: String, repeatStatus: String, repeatEnd: String, taskId: String, taskName: String, taskDesc: String, label: String, finished: Boolean) {
    Log.d("debugging", "alarm set from dart: $alarmId, $time, $repeatStatus, $repeatEnd, $taskId, $taskName, $taskDesc, $label, $finished")

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
            PendingIntent.getBroadcast(context, alarmId.toInt(), alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
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
        alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingAlarmIntent)
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
        val db = Room.databaseBuilder(
                context,
                AppDatabase::class.java, "active_alarms"
        ).build()
        val activeAlarmDao = db.ActiveAlarmDao()
        val fetchedAlarms: List<ActiveAlarm> = activeAlarmDao.getById(alarmId)
        if (fetchedAlarms.isNotEmpty()) {
            reqAlarm = fetchedAlarms[0]
            activeAlarmDao.delete(reqAlarm)

            val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
            Log.d("debugging", "in deleteAlarm method kotlin, all active alarms: $activeAlarms")

            Log.d("debugging", "alarm deleted: $alarmId, ${reqAlarm.time}, ${reqAlarm.repeatStatus}, ${reqAlarm.repeatEnd}, ${reqAlarm.taskId}, ${reqAlarm.taskName}, ${reqAlarm.taskDesc}, ${reqAlarm.label}, ${reqAlarm.finished}")
            val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("alarmId", alarmId)
//                putExtra("time", reqAlarm.time)
//                putExtra("repeatStatus", reqAlarm.repeatStatus)
//                putExtra("repeatEnd", reqAlarm.repeatEnd)
//                putExtra("taskId", reqAlarm.taskId)
//                putExtra("taskName", reqAlarm.taskName)
//                putExtra("taskDesc", reqAlarm.taskDesc)
//                putExtra("label", reqAlarm.label)
//                putExtra("finished", reqAlarm.finished)
            }
            val pendingAlarmIntent =
                    PendingIntent.getBroadcast(context, alarmId.toInt(), alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            val alarmManager =
                    context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager!!.cancel(pendingAlarmIntent)
        }
    }.start()
}

