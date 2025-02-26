package com.lock.focus

import android.content.Context
import android.content.SharedPreferences

// Save functions
fun saveString(context: Context, key: String, value: String) {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    editor.putString(key, value)
    editor.commit()
}

fun saveInt(context: Context, key: String, value: Int) {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    editor.putInt(key, value)
    editor.commit()
}

fun saveBoolean(context: Context, key: String, value: Boolean) {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    editor.putBoolean(key, value)
    editor.commit()
}

fun saveStringList(context: Context, key: String, list: List<String>) {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    editor.putString(key, list.joinToString("**"))
    editor.commit()
}

fun saveIntList(context: Context, key: String, list: List<Int>) {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    val stringList = list.map { it.toString() }
    editor.putString(key, stringList.joinToString("**"))
    editor.commit()
}

// Get functions
fun getString(context: Context, key: String): String? {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    return sharedPreferences.getString(key, null)
}

fun getInt(context: Context, key: String): Int {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    return sharedPreferences.getInt(key, 0)
}

fun getBoolean(context: Context, key: String): Boolean {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    return sharedPreferences.getBoolean(key, false)
}


fun getStringList(context: Context, key: String): List<String> {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    if(sharedPreferences.getString(key, "") == ""){
        return emptyList()
    }
    return sharedPreferences.getString(key, "")?.split("**") ?: emptyList()
}

fun getIntList(context: Context, key: String): List<Int> {
    val sharedPreferences: SharedPreferences = context.getSharedPreferences("MyPrefs", Context.MODE_MULTI_PROCESS)
    val editor: SharedPreferences.Editor = sharedPreferences.edit()
    return sharedPreferences.getString(key, "")?.split("**")?.map { it.toInt() } ?: emptyList()
}