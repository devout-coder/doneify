package com.example.doneify

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
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
            // This method is invoked on the main thread.
            call, result ->
            if (call.method == "setAlarm") {
                setAlarm(call.argument<String>("repeat_status")!!, call.argument<String>("time")!!, call.argument<String>("taskName")!!, call.argument<String>("taskDesc")!!, call.argument<String>("label")!!)
//                if (batteryLevel != -1) {
//                    result.success(batteryLevel)
//                } else {
//                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
//            } else {
//                result.notImplemented()
//            }
        }
    }
    private fun setAlarm(repeat_status:String, time:String, taskName: String, taskDesc: String, label: String) {

        var alarmIntent = Intent(this, AlarmInterface::class.java)
        alarmIntent.putExtra("taskName", taskName);
        alarmIntent.putExtra("taskDesc", taskDesc);
        alarmIntent.putExtra("label", label)
        val pendingAlarmIntent =
                PendingIntent.getActivity(context, 0, alarmIntent,
                        PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE)

        val date:String = time.split(",")[0]
        val realTime:String = time.split(",")[1]
        val day:Int = date.split("/")[0].toInt()
        val month:Int = date.split("/")[1].toInt()
        val year:Int = date.split("/")[2].toInt()
        val hour:Int = realTime.split(":")[0].toInt()
        val minute:Int = realTime.split(":")[1].toInt()

        val calendar: Calendar = Calendar.getInstance().apply {
            set(Calendar.DATE, day)
            set(Calendar.MONTH, month)
            set(Calendar.YEAR, year)
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
        }
        val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), pendingAlarmIntent)
    }
}
