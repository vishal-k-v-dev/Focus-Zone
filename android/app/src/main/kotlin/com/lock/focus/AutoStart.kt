package com.lock.focus

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class MyAccessibilityService : AccessibilityService() {
    private var milliseconds: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()

        val sharedPreferences = this.getSharedPreferences("prefs", Context.MODE_MULTI_PROCESS)

        if((getString(this, "end_time") != null) && (getString(this, "end_time")!!.toLong() > System.currentTimeMillis()) && (getInt(this, "auto_start") == 1)){    
            
            saveInt(this, "duration", (getString(this, "end_time")!!.toLong() - System.currentTimeMillis()).toInt())
            
            val focusZoneService = Intent(this, FloatingOverlayService::class.java)
            val settingsBlockService = Intent(this, AppForegroundService::class.java)
            
            this.startService(focusZoneService)            
            this.startService(settingsBlockService)
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    }

    override fun onInterrupt() {
    }
}