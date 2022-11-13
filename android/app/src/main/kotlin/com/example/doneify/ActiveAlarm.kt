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

@Dao
interface ActiveAlarmDao {
    @Query("SELECT * FROM ActiveAlarm")
    fun getAll(): List<ActiveAlarm>

    @Query("SELECT * FROM ActiveAlarm WHERE alarmId LIKE :alarmId")
    fun getById(alarmId: String): List<ActiveAlarm>

    @Insert
    fun insert(activeAlarm: ActiveAlarm)

    @Update
    fun update(activeAlarm: ActiveAlarm)

    @Delete
    fun delete(activeAlarm: ActiveAlarm)
}

@Database(entities = [ActiveAlarm::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun ActiveAlarmDao(): ActiveAlarmDao
}