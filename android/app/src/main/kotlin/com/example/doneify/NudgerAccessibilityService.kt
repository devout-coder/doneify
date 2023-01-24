package com.example.doneify

import android.accessibilityservice.AccessibilityService
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityWindowInfo


class NudgerAccessibilityService : AccessibilityService() {


    override fun onAccessibilityEvent(accessibilityEvent: AccessibilityEvent) {
        val sharedPref: SharedPreferences = this.getSharedPreferences(
            "nudger", Context.MODE_PRIVATE
        )
        val editor: SharedPreferences.Editor = sharedPref.edit()
        val nudgerSwitch = sharedPref.getBoolean("nudgerSwitch", false)
        if (nudgerSwitch) {
            val parentNodeInfo = accessibilityEvent.source
            var windowInfo: AccessibilityWindowInfo? = null
            var windowActive: Boolean?
            var windowFocussed: Boolean?
            var windowFullScreen: Boolean?
            var windowInPIP: Boolean?

            if (parentNodeInfo == null) {
                return
            }

            val packageName = parentNodeInfo.packageName.toString()

            windowInfo = parentNodeInfo.window

            if (windowInfo != null) {
                // Gets if this window is active.
                windowActive = windowInfo.isActive
                windowFocussed = windowInfo.isFocused
                windowInPIP = windowInfo.isInPictureInPictureMode
                windowFullScreen = accessibilityEvent.isFullScreen
                if (windowActive && windowFocussed) {
                    val storedBlacklisted = sharedPref.getString("blacklisted", "")
                    val blacklistedApps =
                        sharedPref.getStringSet("blacklistedApps", mutableSetOf<String>())
                    //timeType

                    if (storedBlacklisted != packageName && storedBlacklisted != "") {
                        //if some app other than the one which is stored is opened, delete alarm
                        Log.d("debugging", "gotta cancel alarm")
                        editor.putString("blacklisted", "")
                        editor.commit()
                        //cancel alarm

                        val alarmIntent = Intent(this, NudgerAlarmReceiver::class.java)
                        val pendingAlarmIntent =
                            PendingIntent.getBroadcast(
                                this,
                                0,
                                alarmIntent,
                                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                            )
                        val alarmManager =
                            this.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                        alarmManager!!.cancel(pendingAlarmIntent)
                    }
                    if (storedBlacklisted != packageName && blacklistedApps!!.contains(packageName)) {
//                    if (storedBlacklisted != packageName && mutableSetOf<String>(
//                            "com.instagram.android",
//                            "com.yodo1.crossyroad"
//                        ).contains(packageName)
//                    ) {
                        //if a different app other than the stored one is opened and its blacklisted
                        Log.d("debugging", "gotta set alarm")
                        editor.putString("blacklisted", packageName)
                        editor.apply()
                        //set alarm

                        val interval =
                            sharedPref.getInt("interval", 1)
                        Log.d("debugging", "fetched interval is $interval")
                        val alarmIntent = Intent(this, NudgerAlarmReceiver::class.java)
                        val pendingAlarmIntent =
                            PendingIntent.getBroadcast(
                                this,
                                0,
                                alarmIntent,
                                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                            )
                        val alarmManager =
                            this.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                        alarmManager!!.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            System.currentTimeMillis() + interval * 60 * 1000,
                            pendingAlarmIntent
                        )
                    }
                }
//            Log.d("debugging", "window active $windowActive")
//            Log.d("debugging", "window focussed $windowFocussed")
//            Log.d("debugging", "window full screen $windowFullScreen")
//            Log.d("debugging", "window in pip $windowInPIP")
            }
        }
    }

    override fun onInterrupt() {
        Log.d("obscure_tag", "service is interrupted")
    }

}
