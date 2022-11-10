package com.example.doneify

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*


var methodChannel: MethodChannel? = null
class MainActivity: FlutterActivity() {
    private val CHANNEL = "alarm_method_channel"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel =  MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL)
        methodChannel!!.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
            val sound: Uri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE.toString() + "://" + context.packageName + "/" + R.raw.rooster)
            val attributes: AudioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
            val mChannel = NotificationChannel("alarms", "Alarms", NotificationManager.IMPORTANCE_HIGH)
            mChannel.description = "This pertains to all the alarms set by the user"
            mChannel.setSound(sound, attributes)
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)

            if (call!!.method == "setAlarm") {
                setAlarm(call.argument<String>("alarmId")!!, call.argument<String>("time")!!, call.argument<String>("repeatStatus")!!, call.argument<String>("repeatEnd")!! ,call.argument<String>("taskId")!! ,call.argument<String>("taskName")!!, call.argument<String>("taskDesc")!!, call.argument<String>("label")!!, call.argument<Boolean>("finished")!!)
            }else if(call.method == "deleteAlarm"){
                deleteAlarm(call.argument<String>("alarmId")!!, call.argument<String>("time")!!, call.argument<String>("repeatStatus")!!, call.argument<String>("repeatEnd")!! ,call.argument<String>("taskId")!! ,call.argument<String>("taskName")!!, call.argument<String>("taskDesc")!!, call.argument<String>("label")!!, call.argument<Boolean>("finished")!!)
            }
        }
    }

    private fun padDate(date:String):String{
        val components:MutableList<String> = date.split('/').toMutableList()
        components[0] = components[0].padStart(2, '0')
        components[1]= components[1].padStart(2,'0')
        return components.joinToString("/")

    }
    private fun setAlarm(alarmId:String,  time:String, repeatStatus:String, repeatEnd:String, taskId:String, taskName: String, taskDesc: String, label: String, finished: Boolean) {
        Log.d("debugging", "alarm set from dart: $alarmId, $time, $repeatStatus, ${padDate(repeatEnd)}, $taskId, $taskName, $taskDesc, $label, $finished")


        val alarmIntent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("time", time)
            putExtra("repeatStatus", repeatStatus)
            putExtra("repeatEnd", padDate(repeatEnd))
            putExtra("taskId", taskId)
            putExtra("taskName", taskName);
            putExtra("taskDesc", taskDesc);
            putExtra("label", label)
            putExtra("finished", finished)
        }
        val pendingAlarmIntent =
                PendingIntent.getBroadcast(context, alarmId.toInt(), alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        var interval:Long = 0;
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

//        D/debugging(16008): alarm set from dart: 610230325, 15/11/2022, 09:00, everyWeek, 30/11/2022, 864435482006330173, xhxj, , General, false
//        D/debugging(16008): alarm set from dart: 2868458, 8/11/2022, 16:00, once, 8/11/2022, 705633780755677486, hsjz, , General, false
        val date:String = time.split(", ")[0]
        val realTime:String = time.split(", ")[1]
        val day:Int = date.split("/")[0].toInt()
        val month:Int = date.split("/")[1].toInt() - 1
        val year:Int = date.split("/")[2].toInt()
        val hour:Int = realTime.split(":")[0].toInt()
        val minute:Int = realTime.split(":")[1].toInt()
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
        if(repeatStatus == "once"){
            alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingAlarmIntent)
        }else{
            alarmManager!!.setRepeating(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    interval,
                    pendingAlarmIntent
            )
        }
        Log.d("debugging", "alarm set successfully")
    }

    private fun deleteAlarm(alarmId:String,  time:String, repeatStatus:String, repeatEnd:String, taskId:String, taskName: String, taskDesc: String, label: String, finished:Boolean) {
        Log.d("debugging", "alarm deleted from dart: $alarmId, $time, $repeatStatus, $repeatEnd, $taskId, $taskName, $taskDesc, $label, $finished")
        val alarmIntent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("time", time)
            putExtra("repeatStatus", repeatStatus)
            putExtra("repeatEnd", padDate(repeatEnd))
            putExtra("taskId", taskId)
            putExtra("taskName", taskName);
            putExtra("taskDesc", taskDesc);
            putExtra("label", label)
            putExtra("finished", finished)
        }
        val pendingAlarmIntent =
                PendingIntent.getBroadcast(context, alarmId.toInt(), alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        alarmManager!!.cancel(pendingAlarmIntent)
    }
}
