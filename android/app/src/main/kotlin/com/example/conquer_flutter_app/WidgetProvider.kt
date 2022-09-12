package com.example.conquer_flutter_app
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews

//import es.antonborri.home_widget.HomeWidgetBackgroundIntent
//import es.antonborri.home_widget.HomeWidgetLaunchIntent
//import es.antonborri.home_widget.HomeWidgetProvider

class WidgetProvider : AppWidgetProvider() {



    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d("debugging", "widget loaded")

        val sharedPref: SharedPreferences = context.getSharedPreferences(
                "ApplicationListener", Context.MODE_PRIVATE)
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val timeType: String? = sharedPref.getString("timeType", "none")
                if(timeType == "none"){
                    setTextViewText(R.id.timeType, "Day")
                    val editor: SharedPreferences.Editor = sharedPref.edit()
                    editor.putString("timeType", "Day")
                    editor.apply()
                }else{
                    setTextViewText(R.id.timeType, timeType)
                }
                val pendingIntent = PendingIntent.getActivity(context, 0, Intent(context, TimeTypeDialog::class.java) , PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                setOnClickPendingIntent(R.id.timeType, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }


}