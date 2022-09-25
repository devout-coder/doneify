package com.example.doneify
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject

//import es.antonborri.home_widget.HomeWidgetBackgroundIntent
//import es.antonborri.home_widget.HomeWidgetLaunchIntent
//import es.antonborri.home_widget.HomeWidgetProvider

const val EXTRA_ITEM = "com.example.android.listview.EXTRA_ITEM"
class WidgetProvider : HomeWidgetProvider() {



    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
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


                setOnClickPendingIntent(R.id.add_button, HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("http://add_todo/$timeType")))


                val todosStr  = widgetData.getString("todos", "null")
                val todos = ArrayList<HashMap<String, Any>>()
                val todosRemoteView = RemoteViews.RemoteCollectionItems.Builder()
                if(todosStr != "null"){
                    val jObj = JSONObject(todosStr)
                    val jsonArry = jObj.getJSONArray("todos")
                    for (i in 0 until jsonArry.length()) {
                        val todo = HashMap<String, Any>()
                        val obj = jsonArry.getJSONObject(i)
                        todo["id"] = obj.getInt("id")
                        todo["taskName"] = obj.getString("taskName")
                        todo["taskDesc"] = obj.getString("taskDesc")
                        todo["finished"] = obj.getBoolean("finished")
                        todo["labelName"] = obj.getString("labelName")
                        todo["timeStamp"] = obj.getInt("timeStamp")
                        todo["time"] = obj.getString("time")
                        todo["timeType"] = obj.getString("timeType")
                        todo["index"] = obj.getInt("index")
                        todos.add(todo)

                        val view = RemoteViews(context.packageName, R.layout.each_todo).apply {
                            setTextViewText(R.id.each_todo_container_text, todo["taskName"].toString())
                            setCompoundButtonChecked(R.id.each_todo_container_checkbox, todo["finished"].toString().toBoolean())

                            val fillInIntent = Intent().apply {
                                Bundle().also { extras ->
                                    extras.putInt(EXTRA_ITEM, todo["id"].toString().toInt())
                                    putExtras(extras)
                                }
                            }
                            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(context,
                                    Uri.parse("myAppWidget://todo_checked/${todo["id"].toString()}"))
                            setOnCheckedChangeResponse(
                                    R.id.each_todo_container_checkbox,
                                    RemoteViews.RemoteResponse.fromFillInIntent(fillInIntent)
                            )
                            Log.d("debugging",  "id received is ${todo["id"].toString()}" )
                            setOnClickFillInIntent(R.id.each_todo_container_text, fillInIntent)
                        }

                        todosRemoteView.addItem(todo["id"].toString().toInt().toLong(), view)
                    }
                    Log.d("debugging", "no of todos " + todos.count().toString())
                    Log.d("debugging", "name of first todo " + todos[0]["taskName"].toString())
                }
                Log.d( "debugging", "update is triggered");

                setRemoteAdapter(
                        R.id.todos_list,
                        todosRemoteView
                    .build()
                )

               val editTodoIntent = HomeWidgetLaunchIntent.getActivity(
                       context,
                       MainActivity::class.java,
                       Uri.parse("http://edit_todo/$timeType"))
                val pendingIntentx: PendingIntent = Intent(
                        context,
                        WidgetProvider::class.java
                ).run {
                    // Set the action for the intent.
                    // When the user touches a particular view, it will have the effect of
                    // broadcasting TOAST_ACTION.
                    PendingIntent.getBroadcast(context, 0, this, PendingIntent.FLAG_IMMUTABLE)
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
