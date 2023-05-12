package com.awesome_forever.doneify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import androidx.room.Room
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

//import es.antonborri.home_widget.HomeWidgetBackgroundIntent
//import es.antonborri.home_widget.HomeWidgetLaunchIntent
//import es.antonborri.home_widget.HomeWidgetProvider

class WidgetFlutterActivity : FlutterActivity() {

    companion object {
        var methodChannelInvoker: (MethodCall, MethodChannel.Result) -> Unit = { _, _ -> }

//        fun withCachedEngine(cachedEngineId: String): CachedEngineIntentBuilder {
//            return CachedEngineIntentBuilder(WidgetFlutterActivity::class.java, cachedEngineId)
//        }

        fun withNewEngine(): NewEngineIntentBuilder {
            return NewEngineIntentBuilder(WidgetFlutterActivity::class.java)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                methodChannelInvoker(call, result)
            }
    }
}

class WidgetProvider : HomeWidgetProvider() {

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

//        Log.d("debugging", "widget loaded")

        val sharedPref: SharedPreferences = context.getSharedPreferences(
            "ApplicationListener", Context.MODE_PRIVATE
        )
        appWidgetIds.forEach { widgetId ->
            CoroutineScope(Dispatchers.Main.immediate).launch {

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

//                    setOnClickPendingIntent(
//                        R.id.add_button, HomeWidgetLaunchIntent.getActivity(
//                            context,
//                            MainActivity::class.java,
//                            Uri.parse("http://add_todo/$timeType")
//                        )
//                    )

                    val extras = Bundle().apply {
                        putString("timeType", timeTypeHash[timeType])
                    }
                    val addIntent = Intent(context, WidgetProvider::class.java).apply {
                        putExtras(extras)
                        action = "createTodo"
                    }
                    val addPendingIntent = PendingIntent.getBroadcast(
                        context,
                        widgetId,
                        addIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                    )

                    setOnClickPendingIntent(R.id.add_button, addPendingIntent)

                    val todosRemoteView = RemoteViews.RemoteCollectionItems.Builder()
                    val db: AppDB = AppDB.getDatabase(context)
//                    val db = Room.databaseBuilder(
//                        context,
//                        AppDatabase::class.java, "db"
//                    ).build()
                    val todosDAO = db.todoDAO()
                    val todos = todosDAO?.getByTimeType(timeTypeHash[timeType]!!)

//                    Log.d("debugging", "all the todos for ${timeTypeHash[timeType]} are $todos")
                    for (todo in todos!!) {
                        if (!todo.finished!!) {
                            val view = RemoteViews(context.packageName, R.layout.each_todo).apply {
                                setTextViewText(R.id.each_todo_container_text, todo.taskName)
                                setCompoundButtonChecked(
                                    R.id.each_todo_container_checkbox,
                                    todo.finished
                                )
                                // Log.d("debugging", "task name is ${todo.taskName}")

                                val extras = Bundle().apply {
                                    putString("todoId", todo.id)
                                }
                                val editIntent = Intent().apply {
                                    putExtras(extras);
                                    action = "editTodo"
                                }
                                val checkIntent = Intent().apply {
                                    putExtras(extras);
                                    action = "checkTodo"
                                }
//                            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
//                                context,
//                                Uri.parse("myAppWidget://todo_checked/${todo.id}")//use method channel here please
//                            )
                                setOnCheckedChangeResponse(
                                    R.id.each_todo_container_checkbox,
                                    RemoteViews.RemoteResponse.fromFillInIntent(checkIntent)
                                )
                                setOnClickFillInIntent(R.id.each_todo_container_text, editIntent)
                            }
                            todosRemoteView.addItem(todo.id.toLong(), view)
                        }
                    }
//                    Log.d("debugging", "update is triggered");

                    setRemoteAdapter(
                        R.id.todos_list,
                        todosRemoteView
                            .build()
                    )

//                    val editTodoIntent = HomeWidgetLaunchIntent.getActivity(
//                        context,
//                        MainActivity::class.java,
//                        Uri.parse("http://edit_todo/$timeType")
//                    )
                    val pendingIntentTemplate: PendingIntent = Intent(
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
                    setPendingIntentTemplate(R.id.todos_list, pendingIntentTemplate)
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent!!.action == "editTodo") {
            val todoId: String? = intent.getStringExtra("todoId")
            Log.d("debugging", "an item is clicked $todoId")
            WidgetFlutterActivity.methodChannelInvoker = { call, result ->
                handleMethodCalls(context!!, call, result)
            }
            PendingIntent.getActivity(
                context,
                0,
                WidgetFlutterActivity
                    .withNewEngine()
                    .initialRoute("/editInputModal?$todoId")
                    .build(context!!),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ).send()
        } else if (intent.action == "createTodo") {
            val timeType: String? = intent.getStringExtra("timeType")
            Log.d("debugging", "tryna create todo with timetype: $timeType")
            WidgetFlutterActivity.methodChannelInvoker = { call, result ->
                handleMethodCalls(context!!, call, result)
            }
            PendingIntent.getActivity(
                context,
                0,
                WidgetFlutterActivity
                    .withNewEngine()
                    .initialRoute("/createInputModal?$timeType")
                    .build(context!!),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ).send()
        } else if (intent.action == "checkTodo") {
            val todoId: String? = intent.getStringExtra("todoId")
            Log.d("debugging", "checked todo: $todoId")
            val flutterEngine = FlutterEngine(context!!);
            flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
            GeneratedPluginRegistrant.registerWith(flutterEngine);
            val methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            )

            methodChannel.setMethodCallHandler { call: MethodCall?, result: MethodChannel.Result? ->
                handleMethodCalls(context, call, result)
            }
            methodChannel.invokeMethod("task_done", todoId)
        }
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
