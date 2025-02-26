package com.lock.focus

import android.net.*
import android.os.*
import android.content.*
import android.provider.Settings
import android.telecom.TelecomManager
import android.app.admin.DevicePolicyManager
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lock.focus"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            
            if (call.method == "start") {
                
                val duration = ((call.arguments as Map<String, Any>)["duration"]) as Int
                val whitelistedNames = ((call.arguments as Map<String, Any>)["whitelisted_names"]) as List<String>
                val whitelistedPackages = ((call.arguments as Map<String, Any>)["whitelisted_packages"]) as List<String>
                val app_usage_limits = ((call.arguments as Map<String, Any>)["usage_limits"]) as List<Int>
                val blacklistedPackages = ((call.arguments as Map<String, Any>)["blacklisted_packages"]) as List<String>
                val youtubeVideosID = ((call.arguments as Map<String, Any>)["youtube_videos_id"]) as List<String>
                val youtubeVideosTitle = ((call.arguments as Map<String, Any>)["youtube_videos_title"]) as List<String>
                val youtubeVideosThumbnailLink = ((call.arguments as Map<String, Any>)["youtube_videos_thumbnail_link"]) as List<String>
                val breakSessions = ((call.arguments as Map<String, Any>)["break_sessions"]) as Int
                val maximumBreakDuration = ((call.arguments as Map<String, Any>)["maximum_break_duration"]) as Int
                val exitOption = ((call.arguments as Map<String, Any>)["exit_button"]) as Int
                val shouldBlockNotifications = ((call.arguments as Map<String, Any>)["should_block_notifications"]) as Boolean
                val whitelistedNotifications = ((call.arguments as Map<String, Any>)["whitelisted_notifications"]) as List<String>

                saveInt(this, "duration", duration)
                saveStringList(this, "whitelisted_names", whitelistedNames)
                saveStringList(this, "whitelisted_packages", whitelistedPackages)
                saveStringList(this, "blacklisted_packages", blacklistedPackages)
                saveStringList(this, "youtube_videos_id", youtubeVideosID)
                saveStringList(this, "youtube_videos_title", youtubeVideosTitle)
                saveStringList(this, "youtube_videos_thumbnail_link", youtubeVideosThumbnailLink)
                saveIntList(this, "app_usage_limits", app_usage_limits)
                saveInt(this, "break_session", breakSessions)
                saveInt(this, "break_duration", maximumBreakDuration)
                saveInt(this, "exit", exitOption)
                saveInt(this, "break_status", 0)
                saveString(this, "end_time", (duration.toLong() + System.currentTimeMillis()).toString())
                saveBoolean(this, "should_block_notifications", shouldBlockNotifications)
                saveStringList(this, "whitelisted_notifications", whitelistedNotifications)
                
                sendBroadcast(Intent("com.lock.focus.START_SESSION"))

                result.success(null)
            }

            else if(call.method == "isActive"){
                result.success(isForegroundServiceRunning(this))
            }

            // LAUNCHER AND DIALER(PHONE APP) PACKAGE GETTER
            
            else if(call.method == "getHomePackage") {          
                result.success(getHomeScreenPackage(context))   
            }

            else if(call.method == "dialer") {
                val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                result.success(telecomManager.defaultDialerPackage)                
            }

            // ACCESSIBILITY PERMISSION MANAGEMENT

            else if(call.method == "get_permission"){
                startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
            }
            
            else if(call.method == "AccessibilityEnabled") {
                val accessibilityEnabled = Settings.Secure.getInt(
                    contentResolver,
                    Settings.Secure.ACCESSIBILITY_ENABLED, 0
                ) == 1
                result.success(accessibilityEnabled)
            }

            //DEVICE ADMINISTARTOR PERMISSION MANAGEMENT

            else if(call.method == "DeiceAdminEnabled"){
                val devicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                result.success(devicePolicyManager.isAdminActive(ComponentName(this, MyDeviceAdminReceiver::class.java)))
            }
            
            else if(call.method == "GetDeviceAdminPermission"){
                val componentName = ComponentName(this, MyDeviceAdminReceiver::class.java)
                val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                    putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                    putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Please enable device admin to prevent uninstalling focus zone")
                }
                startActivityForResult(intent, 1)
            }

            else if(call.method == "RemovePermission"){
                val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val compName = ComponentName(this, MyDeviceAdminReceiver::class.java)
                devicePolicyManager.removeActiveAdmin(compName)
            }

            else{
                result.notImplemented()
            }
        }
    }
}


