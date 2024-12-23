package com.lock.focus

import android.os.*
import android.app.*
import android.view.*
import android.widget.*
import android.content.*
import android.graphics.*
import android.provider.Settings
import android.graphics.PixelFormat
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import androidx.core.app.NotificationCompat

class FloatingOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private lateinit var buttonView: ImageView

    private lateinit var handler: Handler

    private lateinit var usageStatsManager: UsageStatsManager
    
    private lateinit var notificationManager: NotificationManager
    private val NOTIFICATION_ID = 1
    private val CHANNEL_ID = "ForegroundServiceChannel"

    private lateinit var app_usage_limits_temp: MutableList<Int>
    private var breakStatus: Int = 0
    
    private var lastForegroundApp: String = ""
    
    private val runnable = object : Runnable {
        override fun run() {
            checkForegroundApp()
            handler.postDelayed(this, 200)
        }
    }

    override fun onCreate() {
        super.onCreate()
    }

    private fun checkForegroundApp() {

        // check if exit is triggered and exit
        if(getInt(this, "exit_status") == 1){
            saveInt(this, "exit_status", 0)
            saveString(this, "end_time", "0")
            stopService(Intent(this, AppForegroundService::class.java))
            stopService(Intent(this, FloatingOverlayService::class.java))
        }


        // check if break session is active
        val isBreakActive = getInt(this, "break_status") != 0

        if(isBreakActive && breakStatus == 0){
            breakStatus = getInt(this, "break_status")
        }
        

        // decrease usage limit until 0 while using
        if(!(isBreakActive) && (lastForegroundApp in getStringList(this, "whitelisted_packages"))){
            var whitelisted_names_temp = getStringList(this, "whitelisted_names").toMutableList()
            var whitelisted_packages_temp = getStringList(this, "whitelisted_packages").toMutableList()

            val index = whitelisted_packages_temp.indexOf(lastForegroundApp)

            app_usage_limits_temp[index] = app_usage_limits_temp[index] - 200

            if(app_usage_limits_temp[index] % 5000 == 0){
                saveIntList(this, "app_usage_limits", app_usage_limits_temp)            
            }

            if(app_usage_limits_temp[index] <= 0){
               app_usage_limits_temp.removeAt(index)
               whitelisted_names_temp.removeAt(index)
               whitelisted_packages_temp.removeAt(index)
               
               saveIntList(this, "app_usage_limits", app_usage_limits_temp)
               saveStringList(this, "whitelisted_names", whitelisted_names_temp)
               saveStringList(this, "whitelisted_packages", whitelisted_packages_temp)

               val intent = Intent(Intent.ACTION_MAIN).apply {
                   addCategory(Intent.CATEGORY_HOME)
                   flags = Intent.FLAG_ACTIVITY_NEW_TASK
               }
               startActivity(intent)
            }
        }

        // check foreground app if break is not active
        if(!(isBreakActive)){

            val currentApp = getForegroundAppPackageName()
            
            if(lastForegroundApp != currentApp){
                lastForegroundApp = currentApp
                if (getStringList(this, "whitelisted_packages").contains(lastForegroundApp)) {
                    // Hide the overlay if app is whitelisted
                    overlayView.visibility = View.INVISIBLE
                } 
                else {
                    // Show the overlay if app is not whitelisted
                    if(lastForegroundApp != "com.lock.focus"){
                        val intent = this.packageManager.getLaunchIntentForPackage("com.lock.focus")
                        this.startActivity(intent)
                    }
                    overlayView.visibility = View.VISIBLE
                }
            }
        }
        // when break is  active
        else{
            lastForegroundApp = getForegroundAppPackageName()

            if (getStringList(this, "blacklisted_packages").contains(lastForegroundApp)) {
                overlayView.visibility = View.VISIBLE
                buttonView.visibility = View.INVISIBLE 
            }
            else{
                overlayView.visibility = View.INVISIBLE
            }

            // Reduce break staus (duration of break when active) until 0
            breakStatus = breakStatus - 200

            if(breakStatus % 5000 == 0){
                saveInt(this, "break_status", breakStatus)
            }

            // If break ended add view
            if(breakStatus == 0){
                overlayView.visibility = View.VISIBLE
                buttonView.visibility = View.VISIBLE
                saveInt(this, "break_session", getInt(this, "break_session") - 1)
                val intent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            }
        }
    }























    private fun getForegroundAppPackageName(): String {
        val time = System.currentTimeMillis()
        val usageEvents = usageStatsManager.queryEvents(time - 1000 * 10, time)
        var event: UsageEvents.Event
        var packageName: String = lastForegroundApp

        while (usageEvents.hasNextEvent()) {
            event = UsageEvents.Event()
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                packageName = event.packageName
            }
        }

        return packageName
    }

    private fun startCountdown() {
        val countdownText: TextView = overlayView.findViewById(R.id.countdown_timer)

        object : CountDownTimer(getInt(this, "duration").toLong(), 1000) {
            override fun onTick(millisUntilFinished: Long) {
               var totalSeconds = (millisUntilFinished / 1000).toInt()
               var hours = (totalSeconds / 3600).toInt()
               var minutes = ((totalSeconds % 3600)/60).toInt()
               var remainingSeconds = ((totalSeconds % 3600) % 60).toInt()
               countdownText.text = "${hours} : ${minutes} : ${remainingSeconds}"
            }

            override fun onFinish() {
                try{
                    windowManager.removeView(overlayView)
                } catch(e: Exception){}
                stopForeground(true)
                stopSelf()
            }
        }.start()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        saveString(this, "end_time", (getInt(this, "duration").toLong() + System.currentTimeMillis()).toString())
        saveInt(this, "exit_status", 0)

        app_usage_limits_temp = getIntList(this, "app_usage_limits").toMutableList()

        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        showNotification("Starting...")

        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        handler = Handler()

        // Inflate the overlay view
        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_view, null)
        buttonView = overlayView.findViewById(R.id.icon)

        buttonView.setOnClickListener{
            showPopupWithCountdown(this)
        }

        // Set up the overlay window parameters
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,    
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )        
        layoutParams.gravity = Gravity.CENTER

        // Supports settings blocking during breaks
        showInvisiblePopup(this)

        // Display the overlay window with countdown timer
        startCountdown()

        // Add the overlay view to the window
        windowManager.addView(overlayView, layoutParams)

        // Start checking the foreground app
        handler.post(runnable)
        
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(runnable)
        try {
            windowManager.removeView(overlayView)
        } catch(e: Exception){}
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Focus Zone",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(serviceChannel)
        }
    }

    private fun showNotification(packageName: String) {
        val notificationIntent = Intent()
        val pendingIntent = PendingIntent.getActivity(
            this,
            0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    
        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus Zone")
            .setContentText("Focus Zone is active")
            .setSmallIcon(R.drawable.icon_img)
            .setContentIntent(pendingIntent) // Providing empty intent
            .build()
    
        startForeground(NOTIFICATION_ID, notification)
    }

    
    fun showPopupWithCountdown(context: Context) {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater    

        val popupView = inflater.inflate(R.layout.phone_break, null)
        val layout_popup = popupView.findViewById<LinearLayout>(R.id.popup_layout)
        val topBar = popupView.findViewById<LinearLayout>(R.id.top_bar)
        val appsList = popupView.findViewById<LinearLayout>(R.id.appList)
        val stopAlertButton = popupView.findViewById<Button>(R.id.stopAlertButton)
        val breakButton = popupView.findViewById<Button>(R.id.breakAlertButton)
        val closeButton = popupView.findViewById<ImageView>(R.id.closeButton)

        var timerEnabled = false
        var breakTimerEnabled = false


        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,    
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        //Close button
        closeButton.setOnClickListener{
            windowManager.removeView(popupView)
            timerEnabled = false
            breakTimerEnabled = false
        }

        //Exit button
        stopAlertButton.setOnClickListener{
            if(!timerEnabled){
                timerEnabled = true
                val countDownTimer = object : CountDownTimer(15000, 1000) {
                    override fun onTick(millisUntilFinished: Long) {
                        if(!timerEnabled){
                            cancel()
                        }
                        else{
                            stopAlertButton.text = "${millisUntilFinished / 1000} | Cancel"
                        }
                    }
                
                    override fun onFinish() {
                        if(timerEnabled){
                            context.stopService(Intent(context, FloatingOverlayService::class.java))
                            context.stopService(Intent(context, AppForegroundService::class.java))
                            try{
                                windowManager.removeView(popupView)
                            } catch(e: Exception){}
                        }
                    }
                }.start()
            }
            else{
                stopAlertButton.text = "Exit"
                timerEnabled = false
                breakTimerEnabled = false
            }
        }

        //Break Button
        breakButton.setOnClickListener{
            if(!breakTimerEnabled){
                breakTimerEnabled = true
                val delayTimer = object : CountDownTimer(5000, 1000) {
                    override fun onTick(millisUntilFinished: Long) {
                        if(!breakTimerEnabled){
                            cancel()
                        }
                        else{
                            breakButton.text = "${millisUntilFinished / 1000} | Cancel"
                        }
                    }
                
                    override fun onFinish() {
                        if(breakTimerEnabled){
                            saveInt(context, "break_status", getInt(context, "break_duration"))
                            try{
                                windowManager.removeView(popupView)
                            } catch(e: Exception){}
                        }
                    }
                }.start()
            }
            else{
                breakButton.text = "Break"
                breakTimerEnabled = false
            }
        }

        for(app in getStringList(context, "whitelisted_names")){

            val linearLayout = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }
            linearLayout.gravity = Gravity.START

            val buttonWidget = Button(context).apply {
                text = "$app" + " " + getIntList(context, "app_usage_limits")[getStringList(context, "whitelisted_names").indexOf(app)]/1000 + "s"
                textSize = 20f
                gravity = Gravity.START
                setTextColor(Color.WHITE)
                setBackgroundColor(Color.TRANSPARENT)
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,                
                )
                setOnClickListener {
                    val intent = context.packageManager.getLaunchIntentForPackage(getStringList(context, "whitelisted_packages")[getStringList(context, "whitelisted_names").indexOf(app)])
                    context.startActivity(intent)
                    windowManager.removeView(popupView)
                    timerEnabled = false
                }
            }

            linearLayout.addView(buttonWidget)            
            appsList.addView(linearLayout)
        }

        if(getInt(context, "exit") == 0){
            stopAlertButton.visibility = View.GONE
        }
        if(getInt(context, "break_session") <= 0){
            breakButton.visibility = View.GONE
        }

        params.gravity = Gravity.CENTER

        windowManager.addView(popupView, params)
    }
}

