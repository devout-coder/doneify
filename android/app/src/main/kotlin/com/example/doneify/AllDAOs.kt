package com.example.doneify

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
    @PrimaryKey val id: Int,
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
interface ActiveAlarmDao {
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
    @Query("SELECT * FROM Todo WHERE timeType like :timeType")
    suspend fun getByTimeType(timeType: String): List<Todo>

    @Query("SELECT * FROM Todo WHERE id LIKE :id")
    fun getById(id: Int): List<Todo>

    @Insert
    fun insert(todo: Todo)

    @Update
    fun update(todo: Todo)

    @Delete
    fun delete(todo: Todo)
}

@Database(entities = [ActiveAlarm::class, Todo::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun ActiveAlarmDao(): ActiveAlarmDao
    abstract fun TodoDAO(): TodoDAO
}