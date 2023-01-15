package com.example.doneify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class NudgerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(p0: Context?, p1: Intent?) {
        Log.d("debugging", "received nudger alarm")
        Log.d("debugging", "navigating back home")
        val startMain = Intent(Intent.ACTION_MAIN)
        startMain.addCategory(Intent.CATEGORY_HOME)
        startMain.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        p0!!.startActivity(startMain)
    }
}