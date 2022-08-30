package com.example.conquer_flutter_app
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.util.Log
import android.widget.RemoteViews
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModel

//import es.antonborri.home_widget.HomeWidgetBackgroundIntent
//import es.antonborri.home_widget.HomeWidgetLaunchIntent
//import es.antonborri.home_widget.HomeWidgetProvider

class WidgetProvider : AppWidgetProvider() {



    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {

                val pendingIntent = PendingIntent.getActivity(context, 0, Intent(context, TimeTypeDialog::class.java) , PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                setOnClickPendingIntent(R.id.timeType, pendingIntent)

                // Open App on Widget Click
//                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
//                        context,
//                        MainActivity::class.java)
//                setOnClickPendingIntent(R.id.text, pendingIntent)
//
//                // Swap Title Text by calling Dart Code in the Background
//                setTextViewText(R.id.widget_title, widgetData.getString("title", null)
//                        ?: "No Title Set")
//                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
//                        context,
//                        Uri.parse("homeWidgetExample://titleClicked")
//                )
//                setOnClickPendingIntent(R.id.widget_title, backgroundIntent)
//
//                val message = widgetData.getString("message", null)
//                setTextViewText(R.id.widget_message, message
//                        ?: "No Message Set")
//                // Detect App opened via Click inside Flutter
//                val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
//                        context,
//                        MainActivity::class.java,
//                        Uri.parse("homeWidgetExample://message?message=$message"))
//                setOnClickPendingIntent(R.id.widget_message, pendingIntentWithData)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }


}
