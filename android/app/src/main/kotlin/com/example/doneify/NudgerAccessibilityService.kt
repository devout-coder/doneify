package com.example.doneify

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityWindowInfo


class NudgerAccessibilityService : AccessibilityService() {


    override fun onAccessibilityEvent(accessibilityEvent: AccessibilityEvent) {
//        val sharedPref: SharedPreferences = this.getSharedPreferences(
//            "ApplicationListener", Context.MODE_PRIVATE
//        )
//        val editor: SharedPreferences.Editor = sharedPref.edit()

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
                Log.d("debugging", "current package is $packageName")
            }
//            Log.d("debugging", "window active $windowActive")
//            Log.d("debugging", "window focussed $windowFocussed")
//            Log.d("debugging", "window full screen $windowFullScreen")
//            Log.d("debugging", "window in pip $windowInPIP")
        }


    }

    override fun onInterrupt() {
        Log.d("obscure_tag", "service is interrupted")
    }

}
