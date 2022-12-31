package com.example.doneify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews
import androidx.room.Room
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlinx.coroutines.*

//import es.antonborri.home_widget.HomeWidgetBackgroundIntent
//import es.antonborri.home_widget.HomeWidgetLaunchIntent
//import es.antonborri.home_widget.HomeWidgetProvider

const val EXTRA_ITEM = "com.example.android.listview.EXTRA_ITEM"


class WidgetProvider : HomeWidgetProvider() {

    private var job: Job = Job()
    private val scope = CoroutineScope(job + Dispatchers.Main)

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        var timeTypeHash: HashMap<String, String> = HashMap<String, String>()
        timeTypeHash.put("Day", "day")
        timeTypeHash.put("Week", "week")
        timeTypeHash.put("Month", "month")
        timeTypeHash.put("Year", "year")
        timeTypeHash.put("Long Term", "longTerm")

        Log.d("debugging", "widget loaded")

        val sharedPref: SharedPreferences = context.getSharedPreferences(
            "ApplicationListener", Context.MODE_PRIVATE
        )
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                var timeType: String? = sharedPref.getString("timeType", "none")
                if (timeType == "none") {
                    timeType = "Day"
                    setTextViewText(R.id.timeType, "Day")
                    val editor: SharedPreferences.Editor = sharedPref.edit()
                    editor.putString("timeType", "Day")
                    editor.apply()
                } else {
                    setTextViewText(R.id.timeType, timeType)
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, TimeTypeDialog::class.java),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.timeType, pendingIntent)

                setOnClickPendingIntent(
                    R.id.add_button, HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("http://add_todo/$timeType")
                    )
                )

                val todosRemoteView = RemoteViews.RemoteCollectionItems.Builder()

                scope.launch {
                    val db = Room.databaseBuilder(
                        context,
                        AppDatabase::class.java, "db"
                    ).build()
                    val todosDAO = db.TodoDAO()
                    val todosAsync = async {
                        todosDAO.getByTimeType(timeTypeHash[timeType]!!)
                    }
                    val todos = todosAsync.await()

                    Log.d("debugging", "all the todos for ${timeTypeHash[timeType]} are $todos")
                    for (todo in todos) {
                        val view = RemoteViews(context.packageName, R.layout.each_todo).apply {
                            setTextViewText(R.id.each_todo_container_text, todo.taskName)
                            setCompoundButtonChecked(
                                R.id.each_todo_container_checkbox,
                                todo.finished!!
                            )
                            Log.d("debugging", "task name is ${todo.taskName}")
                            val fillInIntent = Intent().apply {
                                Bundle().also { extras ->
                                    extras.putInt(EXTRA_ITEM, todo.id)
                                    putExtras(extras)
                                }
                            }
                            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                                context,
                                Uri.parse("myAppWidget://todo_checked/${todo.id}")
                            )
                            setOnCheckedChangeResponse(
                                R.id.each_todo_container_checkbox,
                                RemoteViews.RemoteResponse.fromFillInIntent(fillInIntent)
                            )
                            Log.d("debugging", "id received is ${todo.id}")
                            setOnClickFillInIntent(R.id.each_todo_container_text, fillInIntent)
                        }
                        todosRemoteView.addItem(todo.id.toString().toInt().toLong(), view)
                    }
                    Log.d("debugging", "update is triggered");
                }

                setRemoteAdapter(
                    R.id.todos_list,
                    todosRemoteView
                        .build()
                )

                val editTodoIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("http://edit_todo/$timeType")
                )
                val pendingIntentx: PendingIntent = Intent(
                    context,
                    WidgetProvider::class.java
                ).run {
                    // Set the action for the intent.
                    // When the user touches a particular view, it will have the effect of
                    // broadcasting TOAST_ACTION.
                    PendingIntent.getBroadcast(
                        context,
                        widgetId,
                        this,
                       PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE 
                    )
                }
                setPendingIntentTemplate(R.id.todos_list, pendingIntentx)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val viewIndex: Int = intent!!.getIntExtra(EXTRA_ITEM, 0)
        Log.d("debugging", "an item is clicked $viewIndex")
//        if(context!=null){
//            Log.d("debugging", "pending intent must be executed")
//            HomeWidgetLaunchIntent.getActivity(
//                    context,
//                    MainActivity::class.java,
//                    Uri.parse("http://edit_todo/some_timeType")).send()
//        }else{
//            Log.d("debugging", "context is null")
//        }
        super.onReceive(context, intent)
    }


}
