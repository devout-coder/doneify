package com.example.doneify

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase


@Database(entities = [Todo::class], version = 1, exportSchema = false)
abstract class TodosRoomDB : RoomDatabase() {
    abstract fun todoDao(): TodoDAO?

    companion object {
        @Volatile
        private var INSTANCE: TodosRoomDB? = null
        fun getDatabase(context: Context): TodosRoomDB {

            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    TodosRoomDB::class.java,
                    "todos_db"
                ).build()
                INSTANCE = instance
                // return instance
                instance
            }
        }
    }
}
