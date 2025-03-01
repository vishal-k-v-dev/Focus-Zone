package com.lock.focus

import android.os.*
import android.app.*
import android.view.*
import android.util.*
import android.widget.*
import android.content.*
import android.graphics.*
import android.provider.*
import android.graphics.*
import android.app.usage.*
import androidx.core.app.*
import android.net.*
import android.webkit.*
import android.view.accessibility.*
import com.bumptech.glide.*
import android.accessibilityservice.AccessibilityService

class MyAccessibilityService : AccessibilityService() {
    private val context = this
    private var foregroundApp: String = ""
    private var blockView: BlockView? = null
    private var appUsageLimits: MutableList<Int>? = null
    private var isWebviewActive: Boolean = false

    /** RECEIVER FOR STARTING AND ENDING FOCUS SESSION AND BREAKS */
    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when(intent.action){
                "com.lock.focus.START_SESSION" -> {
                    startSession()
                }
                "com.lock.focus.END_SESSION" -> {
                    endSession()
                }
                "com.lock.focus.START_BREAK" -> {
                    startBreak(intent.getIntExtra("break_duration", 10000))
                }
                "com.lock.focus.END_BREAK" -> {
                    endBreak()
                }
                "com.lock.focus.WEBVIEW_INACTIVE" -> {
                    isWebviewActive = false
                }
                "com.lock.focus.WEBVIEW_ACTIVE" -> {
                    isWebviewActive = true
                }
            }
        }
    }

    /** LOOP TO BLOCK AND UNBLOCK SCREEN ACCORDING TO FOREGROUND APP */
    private val blockScreenLoop : Loop = object : Loop() {
        override fun onLoop(remainingDuration: Long) {
            /**
             * Update countdown text of blockView
            */
            blockView!!.countdownText.text = getDurationText(remainingDuration.toInt())

            /**
             * Get current app in foreground
             * If foreground app is not found (happens when same app is in foreground for more than 10 seconds) than get previous app [foregroundApp] in current app
             * If [foregroundApp] and current app doesnt match than foreground app is changed 
            */
            var currentApp = getForegroundApp(context)
            if(currentApp == "not-found"){
                currentApp = foregroundApp
            }
            if(foregroundApp != currentApp){
                foregroundApp = currentApp
            }

            /**
             * If whitelisted app opens than reduce usage limits accordingly
             * This is updated in shared preferences every 3 seconds in [updatePreferencesLoop]
             * If usage limit is 0, launch home screen and remove the app from whitelisted apps list
            */
            if(foregroundApp in getStringList(context, "whitelisted_packages")){
                val index = getStringList(context, "whitelisted_packages").indexOf(foregroundApp)
                if(appUsageLimits != null){
                    appUsageLimits!![index] = appUsageLimits!![index] - 500
                    if(appUsageLimits!![index] == 0){
                        launchHomeScreen()
                        removeWhitelistedApp(index)
                    }
                }
            }

            if(currentApp == "com.lock.focus"){
                if(isWebviewActive){
                    unBlockScreen()
                }
                else{
                    if(blockView!!.blockScreen.visibility != View.VISIBLE){
                        blockScreen()
                    }
                }
            }
            else if(breakLoop.isRunning() == false){
                blockView!!.isBreakActive = false
                if(
                    currentApp in getStringList(context, "whitelisted_packages") || 
                    currentApp == getHomeScreenPackage(context) ||
                    currentApp.contains("incallui") ||
                    currentApp !in getAllPackageNames(context)
                ){
                    unBlockScreen()
                }
                else if(foregroundApp == "com.android.settings"){
                    launchHomeScreen()
                }
                else if(foregroundApp !in getStringList(context, "whitelisted_packages")){
                    blockScreen()
                }
            }
            else if(breakLoop.isRunning()){
                unBlockScreen()
            }
        }
        override fun onFinish() {
            if(blockView != null){
                blockView?.exitOverlay()
            }
            sendBroadcast(Intent("com.lock.focus.SESSION_FINISHED"))
            openMainActivity(context)
        }
    }

    /** LOOP FOR BREAK SESSION. BLOCKS SETTINGS AND BLACKLISTED APPS */
    private val breakLoop : Loop = object : Loop() {
        override fun onLoop(remainingDuration: Long) {
            blockView!!.isBreakActive = true

            blockView!!.breakCountdownText.text = "Break ends in ${getDurationText(remainingDuration.toInt())}"

            /**
             * Get current app in foreground
             * If foreground app is not found (happens when same app is in foreground for more than 10 seconds) than get previous app [foregroundApp] in current app
             * If [foregroundApp] and current app doesnt match than foreground app is changed 
            */
            var currentApp = getForegroundApp(context)
            if(currentApp == "not-found"){
                currentApp = foregroundApp
            }
            if(foregroundApp != currentApp){
                foregroundApp = currentApp
            }

            //Launch home screen if settings app or blackListed app is opened
            if(
                currentApp == "com.android.settings" ||
                currentApp in getStringList(context, "blacklisted_packages")
            ){
                launchHomeScreen()
            }
        }
        override fun onFinish() {
            blockView!!.isBreakActive = false
            blockView!!.switchTab(Tab.BREAK)
        }
    }

    /**
    * LOOP TO UPDATE PREFRENCES FOR END TIME AND APP USAGE LIMITS
    * END TIME IS UPDATED IN LOOP SO CHANGE IN SYSTEM TIME WON'T AFFECT LOOP */
    private val updatePreferencesLoop : Loop = object : Loop() {
        override fun onLoop(remainingDuration: Long){
            saveString(context, "end_time", (blockScreenLoop.getRemainingDuration() + System.currentTimeMillis()).toString())
            saveIntList(context, "app_usage_limits", appUsageLimits!!.toList())
        }
        override fun onFinish(){
            saveString(context, "end_time", "0")
            saveIntList(context, "app_usage_limits", mutableListOf())
        }
    }

    /* REGISTER BROADCAST RECEIVER / AUTOSTART SESSION ON START */
    override fun onServiceConnected() {
        super.onServiceConnected()
        registerBroadcastReceiver()
        autoStart()
    }

    /* UNREGISTER AND REGISTER BROADCAST RECEIVER ON INTERRUPT */
    override fun onInterrupt() {
        unregisterBroadcastReceiver()
        registerBroadcastReceiver()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {}

    fun blockScreen() {
        if(blockView != null){
            blockView?.showOverlay()
        }
    }

    fun unBlockScreen() {
        if(blockView != null){
            blockView?.hideOverlay()
        }
    }

    fun startBreak(breakDuration: Int) {
        breakLoop.start(breakDuration.toLong(), 250L)
    }

    fun endBreak() {
        if(breakLoop.isRunning()){
            breakLoop.finish()
        }
    }

    fun startSession(duration: Long? = null) {
        blockView = BlockView(applicationContext)
        blockView!!.startOverlay()

        appUsageLimits = getIntList(this, "app_usage_limits").toMutableList()

        if(duration == null){
            blockScreenLoop.start(getInt(context, "duration").toLong(), 500L)
            updatePreferencesLoop.start(getInt(context, "duration").toLong(), 3000L)
        }
        else{
            blockScreenLoop.start(duration, 500L)
            updatePreferencesLoop.start(duration, 3000L)
        }
    }

    fun endSession() {
        if(blockScreenLoop.isRunning()){
            blockScreenLoop.stop()
        }
        if(breakLoop.isRunning()){
            breakLoop.stop()
        }
        if(blockView != null){ 
            blockView?.exitOverlay()
        }
        blockView = null
        saveString(context, "end_time", "0")
        openMainActivity(context)
    }

    fun launchHomeScreen() {
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    fun registerBroadcastReceiver() {
        val filterBroadcasts = IntentFilter()
        filterBroadcasts.addAction("com.lock.focus.START_SESSION")
        filterBroadcasts.addAction("com.lock.focus.END_SESSION")
        filterBroadcasts.addAction("com.lock.focus.START_BREAK")
        filterBroadcasts.addAction("com.lock.focus.END_BREAK")
        filterBroadcasts.addAction("com.lock.focus.WEBVIEW_ACTIVE")
        filterBroadcasts.addAction("com.lock.focus.WEBVIEW_INACTIVE")

        registerReceiver(broadcastReceiver, filterBroadcasts, RECEIVER_EXPORTED)
    }

    fun unregisterBroadcastReceiver() {
        unregisterReceiver(broadcastReceiver)
    }

    fun autoStart() {
        if(
            getString(context, "end_time") != null && 
            getString(context, "end_time")!!.toLong() > System.currentTimeMillis()
        ){
            val duration = getString(context, "end_time")!!.toLong() - System.currentTimeMillis()
            if(duration > 10000L){
                startSession(duration)
            }
        }
    }

    fun removeWhitelistedApp(index: Int) {
        if(appUsageLimits != null){
            var whitelistedNamesTemp = getStringList(context, "whitelisted_names").toMutableList()
            var whitelistedPackagesTemp = getStringList(context, "whitelisted_packages").toMutableList()
            
            appUsageLimits!!.removeAt(index)
            whitelistedNamesTemp.removeAt(index)
            whitelistedPackagesTemp.removeAt(index)
    
            saveIntList(context, "app_usage_limits", appUsageLimits!!)
            saveStringList(context, "whitelisted_names", whitelistedNamesTemp)
            saveStringList(context, "whitelisted_packages", whitelistedPackagesTemp)
        }
    }
}