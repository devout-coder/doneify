package com.example.doneify

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.room.Room
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.*

fun calculateFutureTime(time: String, repeatStatus: String): String {
    //time format: 14/11/2022, 09:00
    val date: LocalDate = LocalDate.parse(padDate(time.split(", ")[0]), DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH))
    var newDate = date
    val justTime: String = time.split(", ")[1]


    when (repeatStatus) {
        "everyDay" -> {
            newDate = date.plusDays(1)
        }
        "everyWeek" -> {
            newDate = date.plusDays(7)
        }
        "everyMonth" -> {
            newDate = date.plusDays(30)
        }
        "everyYear" -> {
            newDate = date.plusDays(365)
        }
    }

    return "${newDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH))}, $justTime"
}

class AlarmReceiver : BroadcastReceiver() {

    private fun buildPendingIntent(context: Context, alarmId: String, taskId: String, taskName: String, taskDesc: String, label: String): PendingIntent? {
        Log.d("debugging", "in receiver: $taskName")
        val alarmIntent = Intent(context, AlarmInterface::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("taskId", taskId)
            putExtra("taskName", taskName)
            putExtra("taskDesc", taskDesc)
            putExtra("label", label)
        }
        return PendingIntent.getActivity(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun buildNotification(context: Context, alarmId: String, taskId: String, taskName: String, taskDesc: String, label: String): NotificationCompat.Builder {

        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            action = "snooze"
        }
        val pendingAlarmIntent =
                PendingIntent.getBroadcast(context, 0, snoozeIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val b: NotificationCompat.Builder = NotificationCompat.Builder(context, "alarms")
        b.setSmallIcon(R.drawable.doneify_notification_icon)
                .setStyle(NotificationCompat.BigTextStyle().bigText(taskName))
                .setContentText(taskName)
                .addAction(android.R.drawable.ic_lock_idle_alarm, "Snooze",
                        pendingAlarmIntent)
                .setFullScreenIntent(buildPendingIntent(context, alarmId, taskId, taskName, taskDesc, label), true)
        return (b)
    }

    override fun onReceive(context: Context, intent: Intent) {

        Log.d("debugging", "in alarm receiver")
        val notificationManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val alarmId: String? = intent.getStringExtra("alarmId")

        Thread {
            val reqAlarm: ActiveAlarm?
            val db = Room.databaseBuilder(
                    context,
                    AppDatabase::class.java, "active_alarms"
            ).build()
            val activeAlarmDao = db.ActiveAlarmDao()
            val fetchedAlarms: List<ActiveAlarm> = activeAlarmDao.getById(alarmId!!)
            reqAlarm = fetchedAlarms[0]
            var time: String? = reqAlarm.time
            val taskId: String? = reqAlarm.taskId
            val taskName: String? = reqAlarm.taskName
            val taskDesc: String? = reqAlarm.taskDesc
            val label: String? = reqAlarm.label
            val finished: Boolean? = reqAlarm.finished
            val repeatStatus: String? = reqAlarm.repeatStatus
            val repeatEnd: String? = reqAlarm.repeatEnd


            Log.d("debugging", "repeat end is $repeatEnd")
            if (LocalDate.now() < LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH))) {
                Log.d("debugging", "due date in future")
            } else {
                Log.d("debugging", "past due date")
            }
            Log.d("debugging", "this can run")
            if (repeatStatus == "once" || (repeatStatus != "once" && LocalDate.now() <= LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH)))) {
                // the current date is not past the alarm end date
                if (intent.action == "snooze") {
                    notificationManager.cancel(0)
                    val alarmManager =
                            context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                    Log.d("debugging", "snooze received alarm")
                    val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
                        putExtra("alarmId", alarmId)
                    }
                    val pendingAlarmIntent =
                            PendingIntent.getBroadcast(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                    alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + 10 * 1000, pendingAlarmIntent)
                } else {
                    Log.d("debugging", "received alarm, alarmId: $alarmId, taskId: $taskId, taskName: $taskName")
                    if (!finished!!) {
                        notificationManager.notify(0, buildNotification(context, alarmId, taskId!!, taskName!!, taskDesc!!, label!!).build());
                        context.startActivity(Intent(context, AlarmInterface::class.java).apply {
                            putExtra("alarmId", alarmId)
                            putExtra("taskId", taskId)
                            putExtra("taskName", taskName);
                            putExtra("taskDesc", taskDesc);
                            putExtra("label", label)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        })
                    }
                    if (repeatStatus == "once") {
                        Thread {
                            activeAlarmDao.delete(ActiveAlarm(alarmId = alarmId, time = time, repeatStatus = repeatStatus, repeatEnd = repeatEnd, taskId = taskId, taskName = taskName, taskDesc = taskDesc, label = label, finished = finished))
                            val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                            Log.d("debugging", "in alarm receiver, all active alarms: $activeAlarms")
                        }.start()
                    } else {
                        //update time in active alarm
                        val newTime:String = calculateFutureTime(time!!, repeatStatus!!)
                        Log.d("debugging", "new time: $newTime")
                        activeAlarmDao.update(ActiveAlarm(alarmId = alarmId, time = newTime, repeatStatus = repeatStatus, repeatEnd = repeatEnd, taskId = taskId, taskName = taskName, taskDesc = taskDesc, label = label, finished = finished))
                        val fetchedAlarm: ActiveAlarm = activeAlarmDao.getById(alarmId)[0]
                        Log.d("debugging", "in alarm receiver, changed the time of repeated alarm after it fired : $fetchedAlarm")
                    }
                }
            } else if ((repeatStatus != "once" && LocalDate.now() > LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH)))) {
                //if this doesn't work try re-constructing the same intent again

                Thread {
                    activeAlarmDao.delete(ActiveAlarm(alarmId = alarmId, time = time, repeatStatus = repeatStatus, repeatEnd = repeatEnd, taskId = taskId, taskName = taskName, taskDesc = taskDesc, label = label, finished = finished))
                    val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                    Log.d("debugging", "in alarm receiver, all active alarms: $activeAlarms")
                }.start()

                val pendingAlarmIntent =
                        PendingIntent.getBroadcast(context, alarmId.toInt(), intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                val alarmManager =
                        context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                alarmManager!!.cancel(pendingAlarmIntent)
            }
        }.start()
    }
}