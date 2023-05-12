package com.awesome_forever.doneify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.room.Room
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            Log.d("debugging", "boot received")

            val flutterEngine = FlutterEngine(context);
            flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
//            GeneratedPluginRegistrant.registerWith(flutterEngine);
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "alarm_method_channel"
            )
//            methodChannel.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
//                handleMethodCalls(context, call, result)
//            }
            methodChannel.invokeMethod("reset_accessibility", "")
            Thread {
                val db: AppDB = AppDB.getDatabase(context)
//                    val db = Room.databaseBuilder(
//                        context,
//                        AppDatabase::class.java, "db"
//                    ).build()
                val activeAlarmDao = db.activeAlarmDAO()
                val activeAlarms: List<ActiveAlarm> = activeAlarmDao!!.getAll()
                // Log.d("debugging", "in boot receiver, all active alarms: $activeAlarms")
                for (alarm in activeAlarms) {
                    setAlarm(
                        context,
                        alarm.alarmId,
                        alarm.time!!,
                        alarm.repeatStatus!!,
                        alarm.repeatEnd!!,
                        alarm.taskId!!,
                        alarm.taskName!!,
                        alarm.taskDesc!!,
                        alarm.label!!,
                        alarm.finished!!
                    )
                }
            }.start()
        }
    }
}
