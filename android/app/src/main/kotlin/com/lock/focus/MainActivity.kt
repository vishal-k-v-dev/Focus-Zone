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
                
                val duration = ((call.arguments as Map<String, Any>)["milliseconds"]) as Int
                val whitelisted_names = ((call.arguments as Map<String, Any>)["list"]) as List<String>
                val whitelisted_packages = ((call.arguments as Map<String, Any>)["packagelist"]) as List<String>
                val blacklisted_packages = ((call.arguments as Map<String, Any>)["blacklist_apps"]) as List<String>
                val app_usage_limits = ((call.arguments as Map<String, Any>)["usage_limits"]) as List<Int>
                val break_session = ((call.arguments as Map<String, Any>)["break_session"]) as Int
                val break_duration = ((call.arguments as Map<String, Any>)["break_duration"]) as Int
                val exit = ((call.arguments as Map<String, Any>)["exitbutton"]) as Int

                saveInt(this, "duration", duration)
                saveStringList(this, "whitelisted_packages", whitelisted_packages)
                saveStringList(this, "blacklisted_packages", blacklisted_packages)
                saveStringList(this, "whitelisted_names", whitelisted_names)
                saveIntList(this, "app_usage_limits", app_usage_limits)
                saveInt(this, "break_session", break_session)
                saveInt(this, "break_duration", break_duration)
                saveInt(this, "exit", exit)
                saveInt(this, "break_status", 0)
                
                val serviceIntent = Intent(context, FloatingOverlayService::class.java)
                val settingsBlockService = Intent(context, AppForegroundService::class.java)
                
                context?.startService(serviceIntent)
                context?.startService(settingsBlockService)

                val block_notifications = ((call.arguments as Map<String, Any>)["block_notifications"]) as List<String>

                if((((call.arguments as Map<String, Any>)["is_block_notification_enabled"]) as Int) == 1){
                    val intent = Intent("com.example.BLOCK_NOTIFICATIONS")
                    saveStringList(this, "whitelist_notifications", block_notifications)
                    sendBroadcast(intent)
                }


                if((((call.arguments as Map<String, Any>)["auto_start"]) as Int) == 1){
                    saveInt(this, "auto_start", 1)
                } else{
                    saveInt(this, "auto_start", 0)
                }
                
                result.success(null)
            }

            else if(call.method == "isActive"){
                result.success(isForegroundServiceRunning(this))
            }

            // BREAK MANAGEMENT

            else if(call.method == "isBreakActive"){
                result.success(getInt(this, "break_status") > 0)
            }

            else if(call.method == "endBreak"){
                saveInt(this, "break_status", 0)
                saveInt(this, "break_session", getInt(this, "break_session") - 1)     
                val intent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)  
                result.success(null)
            }

            // LAUNCHER AND DIALER(PHONE APP) PACKAGE GETTER
            
            else if(call.method == "getHomePackage") {          
                val intent = Intent(Intent.ACTION_MAIN)
                intent.addCategory(Intent.CATEGORY_HOME)
                val resolveInfo = context?.packageManager?.resolveActivity(intent, 0)
                result.success(resolveInfo?.activityInfo?.packageName)                
            }

            else if(call.method == "dialer") {
                val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                result.success(telecomManager.defaultDialerPackage)                
            }

            // ACCESSIBILITY PERMISSION MANAGEMENT

            else if(call.method == "getPermission"){
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


