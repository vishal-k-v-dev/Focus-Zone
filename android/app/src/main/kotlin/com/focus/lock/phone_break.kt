package com.focus.lock


import io.flutter.embedding.android.FlutterActivity

import android.content.Intent
import android.content.IntentFilter
import android.app.Service
import android.os.Handler
import android.os.Looper
import android.util.DisplayMetrics
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import androidx.core.app.NotificationCompat
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.view.WindowManager
import android.view.LayoutInflater
import android.widget.*
import android.view.*
import android.graphics.*
import android.view.Gravity
import android.util.Log
import android.os.IBinder
import android.app.*
import android.os.SystemClock
import android.provider.Settings
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.CountDownTimer
import android.content.SharedPreferences


class FloatingOverlayService : Service() {
    private var apps_exception: List<String> = emptyList()
    private var packages_exception: List<String> = emptyList()
    private var app_usage_duration: MutableList<Int> = mutableListOf()
    private val executor = Executors.newSingleThreadScheduledExecutor()
    private val handler = Handler(Looper.getMainLooper())
    private val usageStatsManager by lazy {
        getSystemService(UsageStatsManager::class.java)
    }
    private lateinit var notificationManager: NotificationManager
    private val NOTIFICATION_ID = 1
    private val CHANNEL_ID = "ForegroundServiceChannel"
    private var foregroundApp: String = ""
    private var isActive: Boolean = false
    private var ms_countdown_main: Long = 10000L
    private var enable_quit: Int = 0

    private val printRunnable = Runnable {
        var usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY, System.currentTimeMillis() - TimeUnit.SECONDS.toMillis(1), System.currentTimeMillis()
        )

        if(ms_countdown_main >= 50L){
            ms_countdown_main = ms_countdown_main - 50
        } else{
            stopForeground(true); stopSelf()
        }
        
        if(ms_countdown_main % 3000L == 0L){
            val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("app_usage_limits", (app_usage_duration.map {it.toString()}).joinToString(separator = "**"))
            editor.apply()

        }else if(ms_countdown_main < 3000){
            val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("countdown", "0")
            editor.putString("isRunning", "false")
            editor.apply()
        }

        if (usageStatsList.isNotEmpty()) {
            val packageName = (usageStatsList.sortedByDescending { it.lastTimeUsed })[0].packageName
            foregroundApp = packageName
            
            if(!(packageName in packages_exception) && !(isActive)){
                isActive = true
                try{
                    handler.post{
                        Handler().postDelayed(
                            {
                               showPopupWithCountdown(this, ms_countdown_main, apps_exception, packages_exception, app_usage_duration)
                            },
                        1)
                    }
                } catch(e: Exception){}                
            }
            else if(packageName in packages_exception && isActive == true){
                isActive = false
            }
        }

        if(foregroundApp in packages_exception && isActive == false){            
            app_usage_duration[packages_exception.indexOf(foregroundApp)] = app_usage_duration[packages_exception.indexOf(foregroundApp)] - 50
            if(app_usage_duration[packages_exception.indexOf(foregroundApp)] <= 50 && app_usage_duration[packages_exception.indexOf(foregroundApp)] != 0){
                app_usage_duration[packages_exception.indexOf(foregroundApp)] = 0
                try{
                    handler.post{
                        Handler().postDelayed(
                            {
                                showPopup(this, "Custom Text", 0xFF000000.toInt(), 0xFFFFFFFF.toInt())
                               
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
        apps_exception =  intent?.getStringArrayListExtra("exception_app_names") as? List<String> ?: emptyList()
        packages_exception =  intent?.getStringArrayListExtra("exception_package_names") as? List<String> ?: emptyList()
        ms_countdown_main = (intent?.getIntExtra("ms_countdown", 9) ?: 9).toLong()
        app_usage_duration = (intent?.getIntegerArrayListExtra("usage_limits") as? List<Int> ?: emptyList()).toMutableList()
        isActive = true
        showPopupWithCountdown(this, ms_countdown_main, apps_exception, packages_exception, app_usage_duration)
        
        val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("countdown", (ms_countdown_main + System.currentTimeMillis()).toString())
        editor.putString("exception_app_names", apps_exception.joinToString(separator = "**"))
        editor.putString("exception_package_names", packages_exception.joinToString(separator = "**"))
        editor.putString("isRunning", "true")
        editor.apply()

        executor.scheduleAtFixedRate(printRunnable, 0, 50, TimeUnit.MILLISECONDS)
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        val sharedPreferences = this.getSharedPreferences("myprefs", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("countdown", "0")
        editor.putString("isRunning", "false")
        editor.apply()
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

fun showPopupWithCountdown(context: Context, time: Long, apps: List<String>, packages: List<String>, usageDuration: List<Int>) {
    val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater    

    // Inflate the custom layout for the popup
    val popupView = inflater.inflate(R.layout.phone_break, null)
    val layout_popup = popupView.findViewById<LinearLayout>(R.id.popup_layout)
    val countdownTextView = popupView.findViewById<TextView>(R.id.countdownTextView)
    val appsList = popupView.findViewById<LinearLayout>(R.id.appList)

    var timee = time

    val params = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,    
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        PixelFormat.TRANSLUCENT
    )

    // Set up countdown timer
    val timer = object : CountDownTimer(time, 1000) {
        override fun onTick(millisUntilFinished: Long) {
            var totalSeconds = (millisUntilFinished / 1000).toInt()
            var hours = (totalSeconds / 3600).toInt()
            var minutes = ((totalSeconds % 3600)/60).toInt()
            var remainingSeconds = ((totalSeconds % 3600) % 60).toInt()
            countdownTextView.text = " ${hours} : ${minutes} : ${remainingSeconds} "
            timee = millisUntilFinished
        }

        override fun onFinish() {
            params.width = 100
            params.height = 100
            try{
                windowManager.removeView(popupView)
            } catch(e: Exception){}
        }
    }.start()

    for(app in apps){
        val linearLayout = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        
        val buttonWidget = Button(context).apply {
            text = "$app" + if(usageDuration[apps.indexOf(app)] > 86400000) "\n( no limits )\n" else ("\n( "+usageDuration[apps.indexOf(app)]/1000/3600).toString()+" H "+((usageDuration[apps.indexOf(app)]/1000%3600)/60).toString()+" M "+((usageDuration[apps.indexOf(app)]/1000%3600)%60).toString()+" S ) \n"
            textSize = 18f
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.TRANSPARENT)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,                
            )
            setOnClickListener {
                val intent = context.packageManager.getLaunchIntentForPackage(packages[apps.indexOf(app)])
                if (intent != null && usageDuration[apps.indexOf(app)] > 0) {
                    context.startActivity(intent)
                    params.height = 1
                    params.width = 1
                    layout_popup.setBackgroundColor(Color.TRANSPARENT)
                    windowManager.removeView(popupView)
                } else {
                    // handle else case if needed
                }
            }
        }
                
        linearLayout.addView(buttonWidget)
        
        appsList.addView(linearLayout)
    }

    params.gravity = Gravity.CENTER

    windowManager.addView(popupView, params)
}