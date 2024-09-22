package com.example.doneify

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import android.content.Context
import androidx.room.*

@Entity
data class ActiveAlarm(
    @ColumnInfo(name = "alarmId") val alarmId: String,
    @ColumnInfo(name = "time") val time: String?,
    @ColumnInfo(name = "repeatStatus") val repeatStatus: String?,
    @ColumnInfo(name = "repeatEnd") val repeatEnd: String?,
    @ColumnInfo(name = "taskId") val taskId: String?,
    @ColumnInfo(name = "taskName") val taskName: String?,
    @ColumnInfo(name = "taskDesc") val taskDesc: String?,
    @ColumnInfo(name = "label") val label: String?,
    @ColumnInfo(name = "finished") val finished: Boolean?,
    @PrimaryKey(autoGenerate = true) val id: Int? = null,
)

@Entity
data class Todo(
    @PrimaryKey val id: String,
//    @ColumnInfo(name = "id") val taskId: String?,
    @ColumnInfo(name = "taskName") val taskName: String?,
    @ColumnInfo(name = "taskDesc") val taskDesc: String?,
    @ColumnInfo(name = "finished") val finished: Boolean?,
    @ColumnInfo(name = "labelName") val labelName: String?,
    @ColumnInfo(name = "timeStamp") val timeStamp: Int?,
    @ColumnInfo(name = "time") val time: String?,
    @ColumnInfo(name = "timeType") val timeType: String?,
    @ColumnInfo(name = "index") val index: Int?,

    )

@Dao
interface ActiveAlarmDAO {
    @Query("SELECT * FROM ActiveAlarm")
    fun getAll(): List<ActiveAlarm>

    @Query("SELECT * FROM ActiveAlarm WHERE alarmId LIKE :alarmId")
    fun getById(alarmId: String): List<ActiveAlarm>

    @Insert
    fun insert(activeAlarm: ActiveAlarm)

//    @Update
//    fun update(activeAlarm: ActiveAlarm)

    @Delete
    fun delete(activeAlarm: ActiveAlarm)
}

@Dao
interface TodoDAO {
    @Query("SELECT * FROM Todo WHERE timeType like :timeType  and time like :time order by `index` ASC")
    fun getByTimeAndTimeType(timeType: String, time: String): List<Todo>

    @Query("SELECT * FROM Todo WHERE timeType like :timeType")
    fun getByTimeType(timeType: String): List<Todo>

    @Query("SELECT * FROM Todo WHERE id LIKE :id")
    fun getById(id: String): List<Todo>

    @Insert
    fun insert(todo: Todo)

    @Update
    fun update(todo: Todo)

    @Delete
    fun delete(todo: Todo)
}

class TodoRepository(private val todoDAO: TodoDAO) {

    // Function to get todos by timeType and time using suspend and coroutine
    suspend fun getTodosByTimeAndTimeType(timeType: String, time: String): List<Todo> {
        return withContext(Dispatchers.IO) {
            todoDAO.getByTimeAndTimeType(timeType, time)
        }
    }

    // Function to get todos by timeType using suspend and coroutine
    suspend fun getTodosByTimeType(timeType: String): List<Todo> {
        return withContext(Dispatchers.IO) {
            todoDAO.getByTimeType(timeType)
        }
    }

    // Function to get todos by id (without suspend since it's not using suspend in DAO)
    suspend fun getTodosById(id: String): List<Todo> {
        return withContext(Dispatchers.IO) {
            todoDAO.getById(id)
        }
    }

    // Function to insert a new todo
    suspend fun insertTodo(todo: Todo) {
        withContext(Dispatchers.IO) {
            todoDAO.insert(todo)
        }
    }

    // Function to update a todo
    suspend fun updateTodo(todo: Todo) {
        withContext(Dispatchers.IO) {
            todoDAO.update(todo)
        }
    }

    // Function to delete a todo
    suspend fun deleteTodo(todo: Todo) {
        withContext(Dispatchers.IO) {
            todoDAO.delete(todo)
        }
    }
}

//@Database(entities = [ActiveAlarm::class, Todo::class], version = 1)
//abstract class AppDatabase : RoomDatabase() {
//    abstract fun ActiveAlarmDao(): ActiveAlarmDao
//    abstract fun TodoDAO(): TodoDAO
//}

@Database(entities = [Todo::class, ActiveAlarm::class], version = 1, exportSchema = false)
abstract class AppDB : RoomDatabase() {
    abstract fun todoDAO(): TodoDAO?
    abstract fun activeAlarmDAO(): ActiveAlarmDAO?


    companion object {
        @Volatile
        private var INSTANCE: AppDB? = null
        fun getDatabase(context: Context): AppDB {

            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDB::class.java,
                    "db"
                ).build()
                INSTANCE = instance
                // return instance
                instance
            }
        }
    }
}
