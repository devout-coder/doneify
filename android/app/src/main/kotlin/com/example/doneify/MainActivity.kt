package com.example.doneify

import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.Nullable
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*


val CHANNEL = "alarm_method_channel"

const val REQUEST_CODE_FOR_ACCESSIBILITY = 167

var pendingResult: MethodChannel.Result? = null

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

        isPresent("24/1/2023", "day")
        isPresent("23/1/2023-29/1/2023", "week")
        isPresent("Jan 2023", "month")
        isPresent("2023", "year")
        isPresent("longTerm", "longTerm")

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
        methodChannel!!.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
            handleMethodCalls(context, call, result)
            handleNudgerCall(this, context, call, result)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, @Nullable data: Intent?) {
        //this func checks whether accessibility has been enabled after returning from settings
        if (requestCode == REQUEST_CODE_FOR_ACCESSIBILITY) {
            if (resultCode == RESULT_OK) {
                pendingResult?.success(true)
            } else if (resultCode == RESULT_CANCELED) {
                pendingResult?.success(isAccessibilitySettingsOn(context))
            } else {
                pendingResult?.success(false)
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

