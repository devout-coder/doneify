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
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "alarm_method_channel"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            val sound: Uri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE.toString() + "://" + context.packageName + "/" + R.raw.rooster)
            val attributes: AudioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                val mChannel = NotificationChannel("alarms", "Alarms", NotificationManager.IMPORTANCE_HIGH)
                mChannel.description = "This pertains to all the alarms set by the user"
                mChannel.setSound(sound, attributes)
                val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(mChannel)

            if (call.method == "setAlarm") {
                setAlarm(call.argument<String>("repeat_status")!!, call.argument<String>("time")!!, call.argument<String>("taskName")!!, call.argument<String>("taskDesc")!!, call.argument<String>("label")!!)
                }
        }
    }
    private fun setAlarm(repeat_status:String, time:String, taskName: String, taskDesc: String, label: String) {

        val alarmIntent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("taskName", taskName);
            putExtra("taskDesc", taskDesc);
            putExtra("label", label)
        }
        val pendingAlarmIntent =
                PendingIntent.getBroadcast(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val date:String = time.split(",")[0]
        val realTime:String = time.split(",")[1]
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
        Log.d("debugging", "alarm should be set")
        val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingAlarmIntent)
    }
}
