package com.example.doneify

import android.app.Activity
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import android.widget.RemoteViews
import androidx.room.OnConflictStrategy
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.time.LocalDateTime

fun isAccessibilitySettingsOn(mContext: Context): Boolean {
    var accessibilityEnabled = 0
    val service = mContext.packageName + "/" + NudgerAccessibilityService::class.java.canonicalName
    try {
        accessibilityEnabled = Settings.Secure.getInt(
            mContext.applicationContext.contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED
        )
    } catch (e: Settings.SettingNotFoundException) {
    }
    val mStringColonSplitter = TextUtils.SimpleStringSplitter(':')
    if (accessibilityEnabled == 1) {
        val settingValue = Settings.Secure.getString(
            mContext.applicationContext.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        if (settingValue != null) {
            mStringColonSplitter.setString(settingValue)
            while (mStringColonSplitter.hasNext()) {
                val accessibilityService = mStringColonSplitter.next()
                if (accessibilityService.equals(service, ignoreCase = true)) {
                    return true
                }
            }
        }
    } else {
    }
    return false
}


fun handleNudgerCall(
    activity: Activity,
    context: Context,
    call: MethodCall?,
    result: MethodChannel.Result?
) {
    if (call!!.method == "requestAccessibilityPermission") {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        activity.startActivityForResult(intent, REQUEST_CODE_FOR_ACCESSIBILITY)
        pendingResult = result
    }
}

fun handleMethodCalls(context: Context, call: MethodCall?, result: MethodChannel.Result?) =
    runBlocking {

        val db: AppDB = AppDB.getDatabase(context)
        val activeAlarmDao = db.activeAlarmDAO()
        val todoDAO = db.todoDAO()

        if (call!!.method == "getAccessibilityStatus") {
            result!!.success(isAccessibilitySettingsOn(context))
        } else if (call.method == "setNudgerSwitch") {
            val nudgerSwitch: Boolean = call.argument<Boolean>("nudgerSwitch")!!
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putBoolean("nudgerSwitch", nudgerSwitch)
            editor.apply()
        } else if (call.method == "getNudgerSwitch") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            result!!.success(sharedPref.getBoolean("nudgerSwitch", false))
        } else if (call.method == "getBlacklistedApps") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val blacklistedApps =
                sharedPref.getStringSet("blacklistedApps", mutableSetOf<String>())
            result!!.success(blacklistedApps?.toList())
        } else if (call.method == "setBlacklistedApps") {
            val blacklistedApps: List<String> = call.argument<List<String>>("blacklistedApps")!!
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putStringSet("blacklistedApps", blacklistedApps.toSet())
            editor.apply()
        } else if (call.method == "setNudgerTimeType") {
            val timeType: String = call.argument<String>("timeType")!!
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putString("timeType", timeType)
            editor.apply()
        } else if (call.method == "getNudgerTimeType") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val timeType =
                sharedPref.getString("timeType", "Day")
            result!!.success(timeType)
        } else if (call.method == "setInterval") {
            val interval: String = call.argument<String>("interval")!!
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putInt("interval", Integer.parseInt(interval))
            editor.apply()
        } else if (call.method == "getInterval") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val interval =
                sharedPref.getInt("interval", 1)
            result!!.success(interval.toString())
        } else if (call.method == "setOnlyPresent") {
            val onlyPresent: Boolean = call.argument<Boolean>("onlyPresent")!!
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putBoolean("onlyPresent", onlyPresent)
            editor.apply()
        } else if (call.method == "getOnlyPresent") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val onlyPresent =
                sharedPref.getBoolean("onlyPresent", false)
            result!!.success(onlyPresent)
        } else if (call.method == "setWidgetChanged") {
            val widgetChanged: Boolean = call.argument<Boolean>("widgetChanged")!!
            Log.d("debugging", "setting the value kotlin $widgetChanged")
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val editor: SharedPreferences.Editor = sharedPref.edit()
            editor.putBoolean("widgetChanged", widgetChanged)
            editor.commit()
            result!!.success(widgetChanged)
        } else if (call.method == "getWidgetChanged") {
            val sharedPref: SharedPreferences = context.getSharedPreferences(
                "nudger", Context.MODE_PRIVATE
            )
            val widgetChanged =
                sharedPref.getBoolean("widgetChanged", false)
            Log.d("debugging", "getting the value kotlin $widgetChanged")
            result!!.success(widgetChanged)
        } else if (call.method == "setAlarm") {
            val alarmId: String = call.argument<String>("alarmId")!!
            val time: String = call.argument<String>("time")!!
            val repeatStatus: String = call.argument<String>("repeatStatus")!!
            val repeatEnd: String = padDate(call.argument<String>("repeatEnd")!!)
            val taskId: String = call.argument<String>("taskId")!!
            val taskName: String = call.argument<String>("taskName")!!
            val taskDesc: String = call.argument<String>("taskDesc")!!
            val label: String = call.argument<String>("label")!!
            val finished: Boolean = call.argument<Boolean>("finished")!!
            Thread {
                activeAlarmDao!!.insert(
                    ActiveAlarm(
                        alarmId = alarmId,
                        time = time,
                        repeatStatus = repeatStatus,
                        repeatEnd = repeatEnd,
                        taskId = taskId,
                        taskName = taskName,
                        taskDesc = taskDesc,
                        label = label,
                        finished = finished
                    )
                )

                val activeAlarms: List<ActiveAlarm> = activeAlarmDao.getAll()
                // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
            }.start()

            setAlarm(
                context,
                alarmId,
                time,
                repeatStatus,
                repeatEnd,
                taskId,
                taskName,
                taskDesc,
                label,
                finished
            )
        } else if (call.method == "deleteAlarm") {
            val alarmId: String = call.argument<String>("alarmId")!!
            deleteAlarm(context, alarmId)
        } else if (call.method == "getActiveIds") {
            Thread {
                val activeAlarms: List<ActiveAlarm> = activeAlarmDao!!.getAll()
                val activeAlarmsIds: List<String> =
                    activeAlarms.map { activeAlarm -> activeAlarm.alarmId }
                result!!.success(activeAlarmsIds)
                // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
            }.start()
        } else if (call.method == "getAllAlarms") {
            Thread {
                val activeAlarms: List<ActiveAlarm> = activeAlarmDao!!.getAll()
//                    val activeAlarmsMap: List<String> = activeAlarms.map { activeAlarm -> Gson().toJson(activeAlarm) }
                result!!.success(Gson().toJson(activeAlarms))
                // Log.d("debugging", "in set alarm kotlin func, all active alarms: $activeAlarms")
            }.start()
        } else if (call.method == "createTodo" || call.method == "updateTodo") {
//        methodChannel!!.invokeMethod("callBack", "data1")
            val id: String = call.argument<String>("id")!!
            // Log.d("debugging", "kotlin side: tryna ${call.method}, $id")
            // Log.d("debugging", "in method call receiver: id = $id")
            val taskName: String = call.argument<String>("taskName")!!
            val taskDesc: String = call.argument<String>("taskDesc")!!
            val finished: Boolean = call.argument<Boolean>("finished")!!
            val labelName: String = call.argument<String>("labelName")!!
            val timeStamp: Int = call.argument<Int>("timeStamp")!!
            val time: String = call.argument<String>("time")!!
            val timeType: String = call.argument<String>("timeType")!!
            val index: Int = call.argument<Int>("index")!!
            val todo: Todo = Todo(
                id = id,
                taskName = taskName,
                taskDesc = taskDesc,
                finished = finished,
                labelName = labelName,
                timeStamp = timeStamp,
                time = time,
                timeType = timeType,
                index = index
            )
//        Thread {
//            if (call.method == "createTodo") {
//                Log.d("debugging", "the id used is $id")
//                try {
//                    todoDAO!!.insert(todo)
//                } catch (e: Exception) {
//                    Log.d("debugging", "the caught exception is ${e.toString()}")
//                }
//            } else {
//                todoDAO!!.update(todo)
//            }
//        }.start()
            val todoRepo = TodoRepository(todoDAO!!);
            if (call.method == "createTodo") {
                Log.d("debugging", "the id used is $id")
                try {
                    val insertDeferred = async { todoRepo.insertTodo(todo) }
                    insertDeferred.await() // Waits for insertion to complete
                    result?.success(1);
                } catch (e: Exception) {
                    Log.d("debugging", "the caught exception is ${e.toString()}")
                }
            } else {
                val updateDeferred = async { todoRepo.updateTodo(todo) }
                updateDeferred.await() // Waits for insertion to complete
                result?.success(1);
            }

        } else if (call.method == "deleteTodo") {
            val id: String = call.argument<String>("id")!!
            val todoRepo = TodoRepository(todoDAO!!)
            Log.d("debugging", "the id used is $id")
            try {
                val getDeferred = async { todoRepo.getTodosById(id) }
                val fetchedTodos: List<Todo> =
                    getDeferred.await() // Waits for insertion to complete
                if (fetchedTodos.isNotEmpty()) {
                    val deleteDeferred = async { todoRepo.deleteTodo(fetchedTodos[0]) }
                    deleteDeferred.await()
                    result?.success(1);
                }
                result?.success(1);
            } catch (e: Exception) {
                Log.d("debugging", "the caught exception is ${e.toString()}")
            }
        } else if (call.method == "updateWidget") {
            val appWidgetIds = AppWidgetManager.getInstance(context)
                .getAppWidgetIds(ComponentName(context, WidgetProvider::class.java))
            createWidget(appWidgetIds, context);
        } else {

        }
    }