package com.lock.focus

import android.os.*
import android.app.*
import android.view.*
import android.util.*
import android.widget.*
import android.content.*
import android.graphics.*
import android.provider.Settings
import android.graphics.PixelFormat
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import androidx.core.app.NotificationCompat
import android.net.Uri
import android.webkit.*
import com.bumptech.glide.Glide

fun openAppAsBackground(context: Context){
    val intent = Intent(context, BackgroundScreen::class.java)
    intent.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    context.startActivity(intent)
}

fun openMainActivity(context: Context){
    val intent = Intent(context, MainActivity::class.java)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    context.startActivity(intent)
}

fun openWebView(context: Context, url: String){
    val intent = Intent(context, WebViewScreen::class.java)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.putExtra("url", url)
    context.startActivity(intent)
}

fun getForegroundApp(context: Context): String {
    val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

    val usageEvents = usageStatsManager.queryEvents(
        System.currentTimeMillis() - 1000 * 10, 
        System.currentTimeMillis()
    )

    var packageName: String = "not-found"

    while (usageEvents.hasNextEvent()) {
        val event = UsageEvents.Event()
        usageEvents.getNextEvent(event)
        if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
            packageName = event.packageName
        }
    }

    return packageName
}

fun openApp(context: Context, packageName: String){
    val intent = context.packageManager.getLaunchIntentForPackage(packageName)
    context.startActivity(intent)
}

fun getMaximumBreakDuration(context: Context): Int{
    return getInt(context, "break_duration")
}

fun getBreaksCount(context: Context): Int{
    return getInt(context, "break_session")
}

fun getAllPackageNames(context: Context): List<String> {
    val packageManager = context.packageManager
    val intent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
        addCategory(android.content.Intent.CATEGORY_LAUNCHER)
    }

    val resolvedActivities = packageManager.queryIntentActivities(intent, 0)
    return resolvedActivities.map { it.activityInfo.packageName }
}

fun getHomeScreenPackage(context: Context): String {
    val intent = Intent(Intent.ACTION_MAIN)
    intent.addCategory(Intent.CATEGORY_HOME)
    val resolveInfo = context?.packageManager?.resolveActivity(intent, 0)
    return (resolveInfo?.activityInfo?.packageName) ?: ""  
}

fun getDurationText(milliSeconds: Int): String {
    val totalSeconds = (milliSeconds / 1000).toInt()
    val hours = (totalSeconds / 3600).toInt()
    val minutes = ((totalSeconds % 3600)/60).toInt()
    val seconds = ((totalSeconds % 3600) % 60).toInt()

    var hourString: String = "${hours}"
    var minuteString: String = "${minutes}"
    var secondsString: String = "${seconds}"

    if(hours < 10){
        hourString = "0${hours}"
    }
    if(minutes < 10){
        minuteString = "0${minutes}"
    }
    if(seconds < 10){
        secondsString = "0${seconds}"
    }

    if(hours != 0){
        return "${hourString} : ${minuteString} : ${secondsString}"
    }
    else{
        if(minutes != 0){
            return "${minuteString} : ${secondsString}"
        }
        else{
            return "${secondsString}"
        }
    }
}
