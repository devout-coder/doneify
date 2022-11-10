package com.example.doneify

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.util.Log
import androidx.core.app.NotificationCompat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.*

class AlarmReceiver : BroadcastReceiver() {
    private fun buildPendingIntent(context: Context, taskId: String, taskName: String, taskDesc: String, label: String): PendingIntent? {
        Log.d("debugging", "in receiver: $taskName" )
        val alarmIntent = Intent(context, AlarmInterface::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("taskName", taskName);
            putExtra("taskDesc", taskDesc);
            putExtra("label", label)
        }
        return PendingIntent.getActivity(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }
    private fun buildNotification(context: Context, taskId: String, taskName: String, taskDesc: String, label: String): NotificationCompat.Builder {

        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("taskId", taskId)
            putExtra("taskName", taskName);
            putExtra("taskDesc", taskDesc);
            putExtra("label", label)
            action = "snooze"
        }
        val pendingAlarmIntent =
                PendingIntent.getBroadcast(context, 0, snoozeIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val b: NotificationCompat.Builder = NotificationCompat.Builder(context, "alarms")
        b.setSmallIcon(R.drawable.doneify_notification_icon)
                .setStyle(NotificationCompat.BigTextStyle().bigText(taskName))
                .setContentText(taskName)
                .addAction(android.R.drawable.ic_lock_idle_alarm , "Snooze",
                        pendingAlarmIntent)
                .setFullScreenIntent(buildPendingIntent(context,taskId, taskName, taskDesc, label), true)
        return(b)
    }
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("debugging", "in alarm receiver")
        val notificationManager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val alarmId: String? = intent.getStringExtra("alarmId")
        val taskId: String? = intent.getStringExtra("taskId")
        val taskName: String? = intent.getStringExtra("taskName")
        val taskDesc: String? = intent.getStringExtra("taskDesc")
        val label: String? = intent.getStringExtra("label")
        val finished: Boolean = intent.getBooleanExtra("finished", false)
        val repeatStatus: String? = intent.getStringExtra("repeatStatus")
        val repeatEnd: String? = intent.getStringExtra("repeatEnd")
        Log.d("debugging", "repeat end is $repeatEnd")
        if(LocalDate.now() < LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH))){
                    Log.d("debugging", "due date in future")
                }else{
            Log.d("debugging", "past due date")
        }
        Log.d("debugging", "this can run")
        if(repeatStatus == "once" || (repeatStatus != "once" && LocalDate.now() <= LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH)))){
            // the current date is not past the alarm end date
            if(intent.action == "snooze"){
                notificationManager.cancel(0)
                val alarmManager =
                        context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                Log.d("debugging", "snooze received alarm")
                val alarmIntent = Intent(context, AlarmReceiver::class.java).apply {
                    putExtra("taskId", taskId)
                    putExtra("taskName", taskName);
                    putExtra("taskDesc", taskDesc);
                    putExtra("label", label);
                }
                val pendingAlarmIntent =
                        PendingIntent.getBroadcast(context, 0, alarmIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                alarmManager!!.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + 10 * 1000, pendingAlarmIntent)
            }else{
                Log.d("debugging", "received alarm, alarmId: $alarmId, taskId: $taskId, taskName: $taskName")
                if(!finished){
                    notificationManager.notify(0, buildNotification(context, intent.getStringExtra("taskId")!!, intent.getStringExtra("taskName")!!, intent.getStringExtra("taskDesc")!!, intent.getStringExtra("label")!!).build());
                    context.startActivity(Intent(context, AlarmInterface::class.java)
                            .putExtra("taskId", taskId)
                            .putExtra("taskName", taskName)
                            .putExtra("taskDesc", taskDesc)
                            .putExtra("label", label)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                }
                if(repeatStatus == "once"){
                    methodChannel!!.invokeMethod("deleteActiveAlarm", alarmId)
                }
            }
        }else if((repeatStatus != "once" && repeatStatus != "longTerm" && LocalDate.now() > LocalDate.parse(repeatEnd, DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.ENGLISH)))){
            //if this doesn't work try re-constructing the same intent again
            val pendingAlarmIntent =
                    PendingIntent.getBroadcast(context, alarmId!!.toInt(), intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            val alarmManager =
                    context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager!!.cancel(pendingAlarmIntent)
            methodChannel!!.invokeMethod("deleteActiveAlarm", alarmId)
        }
    }
}
