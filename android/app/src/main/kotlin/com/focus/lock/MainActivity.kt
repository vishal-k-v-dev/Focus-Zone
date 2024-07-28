package com.focus.lock

import io.flutter.embedding.android.FlutterActivity

import android.content.Intent
import android.app.Service
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import java.lang.System
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import androidx.core.app.NotificationCompat
import android.app.usage.*
import android.content.*
import android.content.Context
import android.view.accessibility.*
import android.view.*
import android.widget.TextView
import android.widget.Button
import android.graphics.PixelFormat
import android.util.Log
import android.os.IBinder
import android.app.*
import android.os.SystemClock
import android.provider.Settings
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.CountDownTimer
import androidx.core.content.ContextCompat
import android.content.SharedPreferences
import android.content.BroadcastReceiver
import android.accessibilityservice.*
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.your_flutter_app/toast"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            
            val serviceIntent = Intent(context, FloatingOverlayService::class.java)
            
            if (call.method == "start") {
                val exception_names = ((call.arguments as Map<String, Any>)["list"]) as List<String>
                val exception_packages = ((call.arguments as Map<String, Any>)["packagelist"]) as List<String>
                val ms_input = ((call.arguments as Map<String, Any>)["milliseconds"]) as Int
                val app_usage_limits = ((call.arguments as Map<String, Any>)["usage_limits"]) as List<Int>

                val settingsBlockService = Intent(context, AppForegroundService::class.java)
                settingsBlockService.putExtra("ms_countdown", ms_input)
                settingsBlockService.putStringArrayListExtra("exception_package_names", ArrayList(exception_packages))
                
                serviceIntent.putStringArrayListExtra("exception_app_names", ArrayList(exception_names))
                serviceIntent.putStringArrayListExtra("exception_package_names", ArrayList(exception_packages))
                serviceIntent.putIntegerArrayListExtra("usage_limits", ArrayList(app_usage_limits))
                serviceIntent.putExtra("ms_countdown", ms_input)

                context?.startService(settingsBlockService)
                context?.startService(serviceIntent)
                result.success(null)
            } 
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
            else if(call.method == "getHomePackage") {                
                val intent = Intent(Intent.ACTION_MAIN)
                intent.addCategory(Intent.CATEGORY_HOME)
                val resolveInfo = context?.packageManager?.resolveActivity(intent, 0)
                result.success(resolveInfo?.activityInfo?.packageName)                
            }
            
            else if(call.method == "openapp"){
                val intent = context.packageManager.getLaunchIntentForPackage(((call.arguments as Map<String, Any>)["appname"]) as String)
                if(intent != null){
                    context.startActivity(intent)
                }
                else{
                    try{
                        Handler().post{
                            Handler().postDelayed(
                                {
                                    val intent = Intent(Intent.ACTION_MAIN)
                                    intent.addCategory(Intent.CATEGORY_HOME)
                                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                    
                                    if(intent != null){
                                        context.startActivity(intent)
                                    }
                                },
                            1)
                        }
                    } catch(e: Exception){}
                }
            }

            else if(call.method == "getlockinfos"){
                val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
                val a = sharedPreferences.getString("isRunning","") ?: ""
                val b = sharedPreferences.getString("exception_package_names","") ?: ""
                val c = sharedPreferences.getString("app_usage_limits","0") ?: "0"
                val d = a+"////"+b+"////"+c
                result.success(d)
            }

            else{
                result.notImplemented()
            }
        }
    }
}

class AppForegroundService : Service() {
    private val executor = Executors.newSingleThreadScheduledExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private val usageStatsManager by lazy {
        getSystemService(UsageStatsManager::class.java)
    }
    private lateinit var notificationManager: NotificationManager
    private val NOTIFICATION_ID = 1
    private val CHANNEL_ID = "ForegroundServiceChannel"
    private var currentRunningApp: String = ""
    private var blocked_apps: List<String> = emptyList()
    private var countdown: Long = 0
    private var isquit: Boolean = false

    private val printRunnable = Runnable { 

    val usageStatsList = usageStatsManager.queryUsageStats(
        UsageStatsManager.INTERVAL_DAILY, System.currentTimeMillis() - 100, System.currentTimeMillis()
    )

    countdown = countdown - 10

    if(countdown <= 100){
        stopForeground(true); stopSelf()
    }

    checkForegroundApp()
       
    }

    private fun checkForegroundApp() {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val usageEvents = usm.queryEvents(time - 1000 * 10, time)
    
        var event: UsageEvents.Event? = UsageEvents.Event()
        var lastEvent: UsageEvents.Event? = null
    
        while (usageEvents.hasNextEvent()) {
            event = UsageEvents.Event()
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                lastEvent = event
            }
        }
    
        lastEvent?.let {
            val currentApp = it.packageName
            Log.d("MyForegroundService", "Current App: $currentApp")
            if (currentApp == "com.android.settings") {
                try{
                    handler.post{
                        Handler().postDelayed(
                            {
                                val intent = Intent(Intent.ACTION_MAIN)
                                intent.addCategory(Intent.CATEGORY_HOME)
                                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                                
                                if(intent != null){
                                    this.startActivity(intent)
                                }
                            },
                        1)
                    }
                } catch(e: Exception){}
            }
        }
    }
    

    override fun onCreate() {
        super.onCreate()
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        showNotification("Starting...")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        countdown = (intent?.getIntExtra("ms_countdown", 9) ?: 9).toLong()
        executor.scheduleAtFixedRate(printRunnable, 0, 10, TimeUnit.MILLISECONDS)
        blocked_apps =  intent?.getStringArrayListExtra("exception_packages") as? List<String> ?: emptyList()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(serviceChannel)
        }
    }

    private fun showNotification(packageName: String) {
        val notificationIntent = Intent() // Empty intent
        val pendingIntent = PendingIntent.getActivity(
            this,
            0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Foreground Service")
            .setContentText("Foreground App: $packageName")
            .setSmallIcon(R.drawable.icon_img)
            .setContentIntent(pendingIntent) // Providing empty intent
            .build()
    
        startForeground(NOTIFICATION_ID, notification)
    }
}

fun showPopup(context: Context, text: String, textColor: Int, backgroundColor: Int) {
    val handler = Handler()
    val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

    // Inflate the custom layout for the popup
    val popupView = inflater.inflate(R.layout.popup_layout, null)

    // Reminder page
    val textView = popupView.findViewById<TextView>(R.id.popupTextView)

    val params = WindowManager.LayoutParams(
        1,1,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        PixelFormat.TRANSLUCENT
    )

    // popup view

    textView.text = text
    textView.setTextColor(textColor)


    params.gravity = Gravity.CENTER

    try{
        handler.post{
            Handler().postDelayed(
                {
                    val intent = Intent(Intent.ACTION_MAIN)
                    intent.addCategory(Intent.CATEGORY_HOME)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    
                    if(intent != null){
                        context.startActivity(intent)
                        windowManager.removeView(popupView)
                    }
                },
            1)
        }
    } catch(e: Exception){}

    windowManager.addView(popupView, params)

}


class MyAccessibilityService : AccessibilityService() {
    private var milliseconds: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()

        val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
        val a = sharedPreferences.getString("countdown","0")?.toLong()

        // Start your foreground service here
        if(a != null && a > System.currentTimeMillis()){    

        val serviceIntent = Intent(this, AppForegroundService::class.java)
        serviceIntent.putExtra("ms_countdown", (a - System.currentTimeMillis()).toInt())

        var appNames: String = sharedPreferences.getString("exception_app_names","") ?: ""
        
        val popupServiceIntent = Intent(this, FloatingOverlayService::class.java)

        if("**" in appNames){
            popupServiceIntent.putStringArrayListExtra("exception_app_names", ArrayList((appNames.split("**"))))
            popupServiceIntent.putStringArrayListExtra("exception_package_names", ArrayList((sharedPreferences.getString("exception_package_names","") ?: "").split("**")))
            popupServiceIntent.putIntegerArrayListExtra("usage_limits", ArrayList((sharedPreferences.getString("app_usage_limits","0") ?: "0").split("**").map {it.toInt()}))
        }
        else{
            popupServiceIntent.putStringArrayListExtra("exception_app_names", ArrayList(emptyList()))
            popupServiceIntent.putStringArrayListExtra("exception_package_names", ArrayList(emptyList()))
            popupServiceIntent.putStringArrayListExtra("usage_limits", ArrayList(emptyList()))
        }

        popupServiceIntent.putExtra("ms_countdown", (a - System.currentTimeMillis()).toInt())
        popupServiceIntent.putExtra("enable_quit", sharedPreferences.getString("enable_quit","0")?.toInt())

        if(true){
            this.startService(serviceIntent)
            this.startService(popupServiceIntent)
        }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
             
    }

    override fun onInterrupt() {
    }
}