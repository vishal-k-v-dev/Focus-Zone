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

    private var blockedPackages: List<String> = emptyList() 

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter("com.example.BLOCK_NOTIFICATIONS")
        registerReceiver(blockReceiver, filter, RECEIVER_EXPORTED)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(blockReceiver)
    }

    private val blockReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            //val packages = intent.getStringArrayListExtra("packages") as? List<String> ?: emptyList()
            blockedPackages = getStringList(context, "whitelist_notifications")
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let {
            if(isForegroundServiceRunning(this)){
                if ((!blockedPackages!!.contains(it.packageName))) {
                    cancelNotification(it.key)
                }
            }
        }
    }
}
