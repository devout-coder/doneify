package com.example.doneify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Is triggered when alarm goes off, i.e. receiving a system broadcast
//            val fooString = intent.getStringExtra("KEY_FOO_STRING")
        Log.d("debugging", "received alarm")
    }
}
