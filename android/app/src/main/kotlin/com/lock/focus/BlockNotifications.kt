package com.lock.focus

import android.app.*
import android.content.Intent
import android.content.Context
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.service.notification.StatusBarNotification
import android.service.notification.NotificationListenerService

fun isForegroundServiceRunning(context: Context): Boolean {
    val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val runningServices = manager.getRunningServices(Int.MAX_VALUE)

    for (service in runningServices) {
        if ("com.lock.focus.FloatingOverlayService" == service.service.className) {
            if (service.foreground) {
                return true
            }
        }
    }
    return false
}

class NotificationBlockerService : NotificationListenerService() {
    private var isFocusSessionActive: Boolean = false
    private var shouldBlockNotifications: Boolean = false
    private var whitelistedApps: List<String> = emptyList() 

    override fun onCreate() {
        super.onCreate()
        val filterBroadcasts = IntentFilter()
        filterBroadcasts.addAction("com.lock.focus.START_SESSION")
        filterBroadcasts.addAction("com.lock.focus.END_SESSION")
        filterBroadcasts.addAction("com.lock.focus.SESSION_FINISHED")
        registerReceiver(broadcastReceiver, filterBroadcasts, RECEIVER_EXPORTED)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(broadcastReceiver)
    }

    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when(intent.action){
                "com.lock.focus.START_SESSION" -> {
                    isFocusSessionActive = true
                    shouldBlockNotifications = getBoolean(context, "should_block_notifications")
                    whitelistedApps = getStringList(context, "whitelisted_notifications")
                }
                "com.lock.focus.END_SESSION" -> {
                    isFocusSessionActive = false
                    shouldBlockNotifications = false
                    whitelistedApps = emptyList()
                }
                "com.lock.focus.SESSION_FINISHED" -> {
                    isFocusSessionActive = false
                    shouldBlockNotifications = false
                    whitelistedApps = emptyList()
                }
            }
            
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let {
            if(isFocusSessionActive){
                if (whitelistedApps.contains(it.packageName) == false) {
                    cancelNotification(it.key)
                }
            }
        }
    }
}
