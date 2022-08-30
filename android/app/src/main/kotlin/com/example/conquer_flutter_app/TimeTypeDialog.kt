package com.example.conquer_flutter_app

import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle
import android.util.Log

class TimeTypeDialog : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {

        Log.d("debugging", "alert triggered")
        val alertDialog = AlertDialog.Builder(this)
        // title of the alert dialog
        alertDialog.setTitle("Choose an Item")
        val listItems = arrayOf("Android Development", "Web Development", "Machine Learning")

        alertDialog.setSingleChoiceItems(listItems, -1
        ) { _, which ->
            Log.d("debugging", listItems[which])
            finish()
            // Get the dialog selected item
//                    val color = array[which]
//
//                    // Try to parse user selected color string
//                    try {
//                        // Change the layout background color using user selection
//                        root_layout.setBackgroundColor(Color.parseColor(color))
//                        toast("$color color selected.")
//                    }catch (e:IllegalArgumentException){
//                        // Catch the color string parse exception
//                        toast("$color color not supported.")
//                    }
//
//                    // Dismiss the dialog
        }
        alertDialog.setOnCancelListener { dialogInterface -> finish() }
        alertDialog.create()
        alertDialog.show()
        super.onCreate(savedInstanceState)
    }
}