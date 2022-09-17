package com.example.doneify

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log

class TimeTypeDialog : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {

        Log.d("debugging", "alert triggered")
        val alertDialog = AlertDialog.Builder(this)
        // title of the alert dialog
        alertDialog.setTitle("Choose an Item")
        val listItems = arrayOf("Day", "Week", "Month", "Year", "Long Term")

        val sharedPref: SharedPreferences = applicationContext.getSharedPreferences(
                "ApplicationListener", Context.MODE_PRIVATE)
        val timeType: String? = sharedPref.getString("timeType", "none")
        var checkedItem: Int = -1
        for(item in listItems.indices){
            if(timeType == listItems[item]){
                checkedItem = item
            }
        }


        alertDialog.setSingleChoiceItems(listItems, checkedItem
        ) { _, which ->
            Log.d("debugging", listItems[which])

            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putString("timeType", listItems[which])
            editor.apply()
            val intent = Intent(this, WidgetProvider::class.java)
            intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
            val ids: IntArray = AppWidgetManager.getInstance(applicationContext).getAppWidgetIds(ComponentName(application, WidgetProvider::class.java))
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            sendBroadcast(intent)
            finish()
        }
        alertDialog.setOnCancelListener { dialogInterface -> finish() }
        alertDialog.create()
        alertDialog.show()
        super.onCreate(savedInstanceState)
    }
}