package com.example.doneify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.room.Room

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            Log.d("debugging", "boot received")

            Thread{
                val db = Room.databaseBuilder(
                        context,
                        AppDatabase::class.java, "active_alarms"
                ).build()
                val activeAlarmDao = db.ActiveAlarmDao()
                val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                Log.d("debugging", "in boot receiver, all active alarms: $activeAlarms")
                for (alarm in activeAlarms) {
                    setAlarm(context, alarm.alarmId, alarm.time!!, alarm.repeatStatus!!, alarm.repeatEnd!!, alarm.taskId!!, alarm.taskName!!, alarm.taskDesc!!, alarm.label!!, alarm.finished!!)
                }
            }.start()
        }
    }
}
