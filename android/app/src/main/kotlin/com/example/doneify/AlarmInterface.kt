package com.example.doneify

import android.app.Activity
import android.app.AlertDialog
import android.app.NotificationChannel
import android.app.NotificationManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView

class AlarmInterface: Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.alarm_interface)
        intent.getStringExtra("taskName")
        Log.d("debugging", "alarm fired")
        Log.d("debugging", getIntent().getStringExtra("taskName")!!)
        Log.d("debugging", getIntent().getStringExtra("taskDesc")!!)
        Log.d("debugging", getIntent().getStringExtra("label")!!)
        val taskNameView: TextView = findViewById<View>(R.id.taskName) as TextView
        val taskDescView: TextView = findViewById<View>(R.id.taskDesc) as TextView
        val labelView: TextView = findViewById<View>(R.id.label) as TextView
        taskNameView.setText(intent.getStringExtra("taskName"));
        taskDescView.setText(intent.getStringExtra("taskDesc"));
        labelView.setText(intent.getStringExtra("label"))
    }
}