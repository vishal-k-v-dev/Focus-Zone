package com.lock.focus

// import android.os.*
// import android.app.*
// import android.util.Log
// import android.content.*
// import android.view.Gravity
// import android.view.WindowManager
// import android.view.LayoutInflater
// import android.graphics.PixelFormat
// import android.app.usage.UsageEvents
// import java.util.concurrent.TimeUnit
// import java.util.concurrent.Executors
// import android.app.usage.UsageStatsManager

// class AppForegroundService : Service() {
//     private val executor = Executors.newSingleThreadScheduledExecutor()
//     private val handler = Handler(Looper.getMainLooper())
//     private val usageStatsManager by lazy { getSystemService(UsageStatsManager::class.java) }
//     private lateinit var notificationManager: NotificationManager
//     private var duration: Int = 0
//     private var packageName: String = ""
    
//     private val printRunnable = Runnable {
//         duration -= 50
//         if (duration <= 100) {
//             stopForeground(true)
//             stopSelf()
//         }

//         blockSettingsAccess()
//     }

//     private fun blockSettingsAccess() {
//         var usageStatsList = usageStatsManager.queryUsageStats(
//             UsageStatsManager.INTERVAL_DAILY, 
//             System.currentTimeMillis() - 10000, // from time in milliseconds
//             System.currentTimeMillis() // to time in milliseconds
//         )

//         if (usageStatsList.isNotEmpty()) {
//             val currentPackageName = (usageStatsList.sortedByDescending { it.lastTimeUsed })[0].packageName
//             if(currentPackageName != packageName){
//                 packageName = currentPackageName
//                 if(packageName == "com.android.settings"){
//                     try{
//                         handler.post{
//                             startHomeActivity()
//                             packageName = ""
//                         }
//                     } catch(e: Exception){}
//                 }
//             }
//         }
//     }

//     private fun startHomeActivity() {
//         val intent = Intent(Intent.ACTION_MAIN).apply {
//             addCategory(Intent.CATEGORY_HOME)
//             flags = Intent.FLAG_ACTIVITY_NEW_TASK
//         }
//         startActivity(intent)
//     }

//     override fun onCreate() {
//         super.onCreate()
//         notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//         createNotificationChannel()
//         showNotification("Starting...")
//     }

//     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//         showInvisiblePopup(this)
//         duration = getInt(this, "duration")
//         executor.scheduleAtFixedRate(printRunnable, 0, 50, TimeUnit.MILLISECONDS)
//         return START_STICKY
//     }

//     override fun onBind(intent: Intent?): IBinder? = null

//     override fun onDestroy() {
//         executor.shutdown()
//         super.onDestroy()
//     }

//     private fun createNotificationChannel() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val serviceChannel = NotificationChannel(
//                 "Focus Zone",
//                 "Focus Zone",
//                 NotificationManager.IMPORTANCE_DEFAULT
//             )
//             notificationManager.createNotificationChannel(serviceChannel)
//         }
//     }

//     private fun showNotification(packageName: String) {
//         val notification = Notification.Builder(this, "Focus Zone")
//             .setContentTitle("Focus Zone")
//             .setContentText("Focus Zone is running")
//             .setSmallIcon(R.drawable.icon_img)
//             .setContentIntent(PendingIntent.getActivity(this, 0, Intent(), PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
//             .build()

//         startForeground(1, notification)
//     }
// }


// fun showPopup(context: Context) {
//     val handler = Handler()
//     val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
//     val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

//     val popupView = inflater.inflate(R.layout.popup_layout, null)

//     val params = WindowManager.LayoutParams(
//         1,1,
//         WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
//         WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
//         PixelFormat.TRANSLUCENT
//     )

//     params.gravity = Gravity.CENTER

//     try{
//         handler.post{
//             Handler().postDelayed(
//                 {
//                     val intent = Intent(Intent.ACTION_MAIN)
//                     intent.addCategory(Intent.CATEGORY_HOME)
//                     intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK               
//                     if(intent != null){
//                         context.startActivity(intent)
//                         windowManager.removeView(popupView)
//                     }
//                 },
//             1)
//         }
//     } catch(e: Exception){}

//     windowManager.addView(popupView, params)
// }

// fun showInvisiblePopup(context: Context) {
//     val handler = Handler()
//     val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
//     val inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

//     val popupView = inflater.inflate(R.layout.popup_layout, null)

//     val params = WindowManager.LayoutParams(
//         1,1,
//         WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
//         WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
//         PixelFormat.TRANSLUCENT
//     )

//     params.gravity = Gravity.CENTER

//     windowManager.addView(popupView, params)
//  }

