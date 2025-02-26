package com.lock.focus

// import android.os.*
// import android.app.*
// import android.view.*
// import android.util.*
// import android.widget.*
// import android.content.*
// import android.graphics.*
// import android.provider.Settings
// import android.graphics.PixelFormat
// import android.app.usage.UsageEvents
// import android.app.usage.UsageStatsManager
// import androidx.core.app.NotificationCompat
// import android.net.Uri
// import android.webkit.*
// import com.bumptech.glide.Glide


// class FloatingOverlayService : Service() {

//     private lateinit var blockView: BlockView

//     private lateinit var handler: Handler

//     private lateinit var usageStatsManager: UsageStatsManager
    
//     private lateinit var appUsageLimits: MutableList<Int>

//     private var breakStatus: Int = 0
    
//     private var lastForegroundApp: String = "com.lock.focus"

//     private val backPressReceiver = object : BroadcastReceiver() {
//         override fun onReceive(context: Context, intent: Intent) {
//             if(intent.action == "com.lock.focus.pop"){
//                 //blockView.pop()
//             }
//             else if(intent.action == "com.lock.focus.show_overlay"){
//                 blockView.showOverlay()
//             }
//             else if(intent.action == "com.lock.focus.hide_overlay"){
//                 blockView.hideOverlay()
//             }
//         }
//     }
    
//     private val blocker = object : Runnable {
//         override fun run() {
//             block()
//             handler.postDelayed(this, 200)
//         }
//     }

//     private val preferenceUpdater = object : Runnable {
//         override fun run() {
//             updatePreference()
//             handler.postDelayed(this, 3000)
//         }
//     }

//     private fun block(){
//         if(isExitTriggered()) {
//             exit() 
//         }

//         if(isBreakActive()) {
//             breakStatus = breakStatus - 200

//             blockView.hideOverlay()

//             if(breakStatus == 0) { 
//                 endBreak()
//                 blockView.showOverlay()
//                 openApp(this, "com.lock.focus")
//             }
//         }
//         else{
//             //Reduce Usage Limits
//             if(lastForegroundApp in getStringList(this, "whitelisted_packages")){
//                 val index = getStringList(this, "whitelisted_packages").indexOf(lastForegroundApp)
//                 appUsageLimits[index] = appUsageLimits[index] - 200
//                 if(appUsageLimits[index] <= 0){
//                     removeWhitelistedApp(index)
//                     openAppAsBackground(this)
//                 }
//             }
            
//             val currentApp = getForegroundAppPackageName()

//             if(lastForegroundApp != currentApp) { //App in foreground is changed
//                 lastForegroundApp = currentApp

//                 if(lastForegroundApp in getAllPackageNames(this)){
//                     if((lastForegroundApp in getStringList(this, "whitelisted_packages")) || (lastForegroundApp == getHomeScreenPackage(this))){
//                         blockView.hideOverlay()
//                     }
//                     else{
//                         blockView.showOverlay()
//                         openAppAsBackground(this)
//                     }
//                 }
//                 else{
//                     blockView.hideOverlay() //most likely recents screen or in-call ui
//                 }
//             }
//         }
//     }

//     private fun updatePreference() {
//         saveIntList(this, "app_usage_limits", appUsageLimits)
//         saveInt(this, "break_status", breakStatus)
//     }

//     private fun getForegroundAppPackageName(): String {
//         val usageEvents = usageStatsManager.queryEvents(
//             System.currentTimeMillis() - 1000 * 10, 
//             System.currentTimeMillis()
//         )

//         var packageName: String = lastForegroundApp

//         while (usageEvents.hasNextEvent()) {
//             val event = UsageEvents.Event()
//             usageEvents.getNextEvent(event)
//             if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
//                 packageName = event.packageName
//             }
//         }

//         return packageName
//     }

//     private fun removeWhitelistedApp(index: Int) {
//         var whitelistedNamesTemp = getStringList(this, "whitelisted_names").toMutableList()
//         var whitelistedPackagesTemp = getStringList(this, "whitelisted_packages").toMutableList()
        
//         appUsageLimits.removeAt(index)
//         whitelistedNamesTemp.removeAt(index)
//         whitelistedPackagesTemp.removeAt(index)

//         saveIntList(this, "app_usage_limits", appUsageLimits)
//         saveStringList(this, "whitelisted_names", whitelistedNamesTemp)
//         saveStringList(this, "whitelisted_packages", whitelistedPackagesTemp)
//     }

//     private fun isBreakActive(): Boolean {
//         if(breakStatus > 0){
//             return true
//         }
//         else{
//             breakStatus = getInt(this, "break_status")

//             if(breakStatus > 0){
//                 return true
//             }
//         }
//         return false
//     }

//     private fun endBreak() {
//         val breakSessions = getInt(this, "break_session")
//         saveInt(this, "break_status", 0)
//         saveInt(this, "break_session", breakSessions - 1)
//     }

//     private fun isExitTriggered(): Boolean {
//         return getInt(this, "exit_status") == 1
//     }

//     private fun exit() {
//         saveInt(this, "exit_status", 0)
//         saveString(this, "end_time", "0")
//         stopService(Intent(this, AppForegroundService::class.java))
//         stopService(Intent(this, FloatingOverlayService::class.java))
//     }

//     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//         setupNotification()

//         appUsageLimits = getIntList(this, "app_usage_limits").toMutableList()

//         usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

//         handler = Handler()

//         // Register Receiver
//         val intentFilter = IntentFilter()
//         intentFilter.addAction("com.lock.focus.pop")
//         intentFilter.addAction("com.lock.focus.show_overlay")
//         intentFilter.addAction("com.lock.focus.hide_overlay")
//         registerReceiver(backPressReceiver, intentFilter, RECEIVER_EXPORTED)

//         blockView = BlockView(this)

//         blockView.startOverlay()

//         openAppAsBackground(this)

//         handler.post(blocker)
        
//         handler.post(preferenceUpdater)
        
//         return START_STICKY
//     }

//     override fun onDestroy() {
//         handler.removeCallbacks(blocker)
//         handler.removeCallbacks(preferenceUpdater)
//         blockView.exitOverlay()
//         stopForeground(true)
//         stopSelf()
//         unregisterReceiver(backPressReceiver)
//         super.onDestroy()
//     }
    
//     override fun onCreate() {
//         super.onCreate()
//     }

//     override fun onBind(intent: Intent?): IBinder? {
//         return null
//     }

//     private fun setupNotification() {
//         val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//         val NOTIFICATION_ID = 1
//         val CHANNEL_ID = "ForegroundServiceChannel"

//         //CreateChannel
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val serviceChannel = NotificationChannel(
//                 CHANNEL_ID,
//                 "Focus Zone",
//                 NotificationManager.IMPORTANCE_DEFAULT
//             )
//             notificationManager.createNotificationChannel(serviceChannel)
//         }

//         //ShowNotification
//         val notificationIntent = Intent()

//         val pendingIntent = PendingIntent.getActivity(
//             this,
//             0, 
//             notificationIntent, 
//             PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//         )
    
//         val notification = Notification.Builder(this, CHANNEL_ID)
//             .setContentTitle("Focus Zone")
//             .setContentText("Focus Zone is active")
//             .setSmallIcon(R.drawable.icon_img)
//             .setContentIntent(pendingIntent) // Providing empty intent
//             .build()
    
//         startForeground(NOTIFICATION_ID, notification)
//     }
// }