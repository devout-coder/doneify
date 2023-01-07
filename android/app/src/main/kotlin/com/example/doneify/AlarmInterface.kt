package com.example.doneify

import android.app.*
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class AlarmInterface : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.alarm_interface)
        val alarmId: String? = intent.getStringExtra("alarmId")
        val taskId: String? = intent.getStringExtra("taskId")
        val taskName: String? = intent.getStringExtra("taskName")
        val taskDesc: String? = intent.getStringExtra("taskDesc")
        val label: String? = intent.getStringExtra("label")
        Log.d("debugging", "alarm fired")
        Log.d("debugging", "in alarm interface, $taskId")

        val taskNameView: TextView = findViewById<View>(R.id.taskName) as TextView
        val taskDescView: TextView = findViewById<View>(R.id.taskDesc) as TextView
        val labelView: TextView = findViewById<View>(R.id.label) as TextView
        val snoozeButton: Button = findViewById(R.id.snooze_button)
        val dismissButton: Button = findViewById(R.id.dismiss_button)
        val checkOffButton: Button = findViewById(R.id.check_off_button)

        taskNameView.text = taskName
        taskDescView.text = taskDesc
        labelView.text = label

        val notificationManager: NotificationManager =
            this.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        snoozeButton.setOnClickListener {
            notificationManager.cancel(0)
            val alarmManager =
                this.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            val alarmIntent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("alarmId", alarmId);
            }
            val pendingAlarmIntent =
                PendingIntent.getBroadcast(
                    this,
                    0,
                    alarmIntent,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
            alarmManager!!.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                System.currentTimeMillis() + 10 * 1000,
                pendingAlarmIntent
            )
            notificationManager.cancel(0)
            finish()
        }
        dismissButton.setOnClickListener {
            notificationManager.cancel(0)
            finish()
        }
        checkOffButton.setOnClickListener {
            val flutterEngine = FlutterEngine(this);
            flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
            GeneratedPluginRegistrant.registerWith(flutterEngine);
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            )
            methodChannel.invokeMethod("task_done", "$taskId")
            notificationManager.cancel(0)
            finish()
        }

    }
}