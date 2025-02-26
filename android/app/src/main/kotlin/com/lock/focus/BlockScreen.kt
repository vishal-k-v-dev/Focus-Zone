package com.lock.focus

import android.os.*
import android.app.*
import android.view.*
import android.util.*
import android.widget.*
import android.content.*
import android.graphics.*
import android.provider.Settings
import android.graphics.PixelFormat
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import androidx.core.app.NotificationCompat
import android.net.Uri
import android.webkit.*
import com.bumptech.glide.Glide

class BlockView(val context: Context){
    public var isBreakActive: Boolean = false
    public var exitTaps: Int = 30

    public lateinit var windowManager: WindowManager
    public lateinit var inflater: LayoutInflater

    public lateinit var blockScreen: View //BlockScreen
    
    public lateinit var countdownScreen: View
    public lateinit var appsScreen: View
    public lateinit var videosScreen: View
    public lateinit var videosUnavailableScreen: View
    public lateinit var breakScreen: View
    public lateinit var breakUnavailableScreen: View
    public lateinit var breakActiveScreen: View
    public lateinit var exitScreen: View
    public lateinit var exitDisabledScreen: View
    public lateinit var bottomNavigationBar: View
    public lateinit var topBar: View

    public lateinit var countdownText: TextView
    public lateinit var breakCountdownText: TextView

    //BottomNavigationBar Tabs
    private lateinit var homeTab: com.google.android.material.imageview.ShapeableImageView //HomeTab
    private lateinit var appsTab: com.google.android.material.imageview.ShapeableImageView //AppsTab
    private lateinit var videosTab: com.google.android.material.imageview.ShapeableImageView //VideosTab
    private lateinit var breakTab: com.google.android.material.imageview.ShapeableImageView //BreakTab
    private lateinit var exitTab: com.google.android.material.imageview.ShapeableImageView //ExitTab

    private var currentTab: Tab = Tab.HOME //CurrentTab

    private lateinit var appsList: LinearLayout //AppsList
    private lateinit var videosList: LinearLayout //VideosList
    private lateinit var breaksList: LinearLayout //VideosList

    val breakWidgetsAdded = mutableListOf<View>()
    val appWidgetsAdded = mutableListOf<View>()

    init{
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        inflater = context.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

        blockScreen = LayoutInflater.from(context).inflate(R.layout.overlay_view, null)

        //BottomNavigationBar Tabs
        homeTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.home_tab)
        appsTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.apps_tab)
        videosTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.videos_tab)
        breakTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.break_tab)
        exitTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.exit_tab)

        countdownScreen = blockScreen.findViewById<LinearLayout>(R.id.count_down_screen)
        appsScreen = blockScreen.findViewById<LinearLayout>(R.id.apps_screen)
        videosScreen = blockScreen.findViewById<LinearLayout>(R.id.videos_screen)
        videosUnavailableScreen = blockScreen.findViewById<LinearLayout>(R.id.videos_unavailable_screen)
        breakScreen = blockScreen.findViewById<LinearLayout>(R.id.breaks_screen)
        breakUnavailableScreen = blockScreen.findViewById<LinearLayout>(R.id.breaks_unavailable_screen)
        breakActiveScreen = blockScreen.findViewById<LinearLayout>(R.id.breaks_active_screen)
        bottomNavigationBar = blockScreen.findViewById<LinearLayout>(R.id.bottom_navigation_bar)
        exitScreen = blockScreen.findViewById<LinearLayout>(R.id.exit)
        exitDisabledScreen = blockScreen.findViewById<LinearLayout>(R.id.exit_disabled) 
        topBar = blockScreen.findViewById<LinearLayout>(R.id.top_bar) 

        appsList = blockScreen.findViewById<LinearLayout>(R.id.apps_list) //AppsList
        videosList = blockScreen.findViewById<LinearLayout>(R.id.videos_list) //VideosList
        breaksList = blockScreen.findViewById<LinearLayout>(R.id.breaks_list) //BreaksList

        countdownText = blockScreen.findViewById<TextView>(R.id.countdown_timer)
        breakCountdownText = blockScreen.findViewById<TextView>(R.id.break_active_countdown)
    }

    public fun loadApps() {
        val appNames = getStringList(context, "whitelisted_names")
        val appPackageNames = getStringList(context, "whitelisted_packages")
        val appUsageLimits = getIntList(context, "app_usage_limits")

        if(appWidgetsAdded.size > 0){
            for(buttonView in appWidgetsAdded){
                appsList.removeView(buttonView)
            }
            appWidgetsAdded.clear()
        }

        for(app in getStringList(context, "whitelisted_names")){
            val index = appNames.indexOf(app)
            val limit = appUsageLimits[index]

            val buttonView = generateListTile(
                title = app,
                subtitle = if(limit < 43200000) getDurationText(limit) else null,
                onPressed = {
                    switchTab(Tab.HOME)
                    openApp(context, appPackageNames[index])
                }
            )

            appsList.addView(buttonView)

            appWidgetsAdded.add(buttonView)
        }
    }

    public fun loadVideos(){
        val IDs = getStringList(context, "youtube_videos_id")
        val titles = getStringList(context, "youtube_videos_title")
        val imageLinks = getStringList(context, "youtube_videos_thumbnail_link")

        if(imageLinks.size > 0){
            for (i in imageLinks.indices) {
                val videoItem = LayoutInflater.from(context).inflate(R.layout.video_item, videosList, false)
                val imageView = videoItem.findViewById<ImageView>(R.id.itemImage)
                val titleView = videoItem.findViewById<TextView>(R.id.itemTitle)
        
                // Load image using Glide
                Glide.with(context).load(imageLinks[i]).into(imageView)
        
                // Set title
                titleView.text = titles[i]
        
                videoItem.setOnClickListener {
                    openWebView(context, "https://www.youtube.com/embed/${IDs[i]}")
                }
        
                videosList.addView(videoItem)
            }
        }      
    }

    public fun setupBreakScreen() {
        val breakCount = blockScreen.findViewById<TextView>(R.id.breaks_count)

        if(getBreaksCount(context) == 1){
            breakCount.text = "1 break available"
        }
        else{
            breakCount.text = "${getBreaksCount(context)} breaks available"
        }

        if(breakWidgetsAdded.size > 0){
            for(buttonView in breakWidgetsAdded){
                breaksList.removeView(buttonView)
            }
            breakWidgetsAdded.clear()
        }

        for(duration in 5..60 step 5){
            val buttonView = generateListTile(
                title = "$duration Minutes",
                disabled = duration > getMaximumBreakDuration(context),
                onPressed = {
                    hideAllScreens()
                    breakActiveScreen.visibility = View.VISIBLE
                    saveInt(context, "break_session", getBreaksCount(context) - 1)
                    val breakBroadcastIntent = Intent("com.lock.focus.START_BREAK")
                    breakBroadcastIntent.putExtra("break_duration", duration*60000)
                    context.sendBroadcast(breakBroadcastIntent)
                }
            )
            breaksList.addView(buttonView)
            breakWidgetsAdded.add(buttonView)
        }
    }

    public fun pop() {
        switchTab(Tab.HOME)
    }

    public fun setupBottomNavigationBar(){
        homeTab.setOnClickListener{
            switchTab(Tab.HOME)
        }
        appsTab.setOnClickListener{
            switchTab(Tab.APPS)
        }
        videosTab.setOnClickListener{
            switchTab(Tab.VIDEOS)
        }
        breakTab.setOnClickListener{
            switchTab(Tab.BREAK)
        }
        exitTab.setOnClickListener{
            switchTab(Tab.EXIT)
        }
    }

    public fun hideAllScreens() {
        countdownScreen.visibility = View.GONE
        appsScreen.visibility = View.GONE
        videosScreen.visibility = View.GONE
        videosUnavailableScreen.visibility = View.GONE 
        breakScreen.visibility = View.GONE
        breakUnavailableScreen.visibility = View.GONE
        breakActiveScreen.visibility = View.GONE
        exitScreen.visibility = View.GONE
        exitDisabledScreen.visibility = View.GONE
    }

    public fun switchTab(tab: Tab){
        val whiteColor = Color.parseColor("#FFFFFF")
        val greenAccentColor = Color.parseColor("#69F0AE")

        fun setDefaultColorTabs() {
            homeTab.setColorFilter(whiteColor)
            appsTab.setColorFilter(whiteColor)
            videosTab.setColorFilter(whiteColor)
            breakTab.setColorFilter(whiteColor)
            exitTab.setColorFilter(whiteColor)
        }

        if(tab == Tab.HOME){
            hideAllScreens()
            setDefaultColorTabs()
            homeTab.setColorFilter(greenAccentColor)
            countdownScreen.visibility = View.VISIBLE
        }

        else if(tab == Tab.APPS){
            hideAllScreens()
            setDefaultColorTabs()
            loadApps()
            appsTab.setColorFilter(greenAccentColor)
            appsScreen.visibility = View.VISIBLE
        }

        else if(tab == Tab.VIDEOS){
            hideAllScreens()
            setDefaultColorTabs()

            videosTab.setColorFilter(greenAccentColor)            

            if(getStringList(context, "youtube_videos_id").size > 0){
                videosScreen.visibility = View.VISIBLE
            }
            else{
                videosUnavailableScreen.visibility = View.VISIBLE
            }            
        }

        else if(tab == Tab.BREAK){
            hideAllScreens()
            setDefaultColorTabs()
            setupBreakScreen()

            breakTab.setColorFilter(greenAccentColor)

            if(isBreakActive){
                breakActiveScreen.visibility = View.VISIBLE
            }
            else{
                if(getBreaksCount(context) > 0){
                    breakScreen.visibility = View.VISIBLE
                }
                else{
                    breakUnavailableScreen.visibility = View.VISIBLE
                }
            }
        }

        else if(tab == Tab.EXIT){
            hideAllScreens()
            setDefaultColorTabs()

            exitTab.setColorFilter(greenAccentColor)

            if(getInt(context, "exit") == 0){
                exitDisabledScreen.visibility = View.VISIBLE
            }
            else{
                setupExitScreen()
                exitScreen.visibility = View.VISIBLE
            }
        }
    }

    public fun setupExitScreen() {
        val messageText = exitScreen.findViewById<TextView>(R.id.message_text)
        val tapDownText = exitScreen.findViewById<TextView>(R.id.tap_down_text)

        exitTaps = 30

        tapDownText.text = exitTaps.toString()
        messageText.text = "Tap the box ${exitTaps} times to exit focus session"

        tapDownText.setOnClickListener {
            exitTaps = exitTaps - 1
            if(exitTaps == 0){
                context.sendBroadcast(Intent("com.lock.focus.END_SESSION"))
            }
            tapDownText.text = exitTaps.toString()
            messageText.text = "Tap the box ${exitTaps} times to exit focus session"
        }
    }

    public fun startOverlay() {
        setupBottomNavigationBar()
        loadApps()
        loadVideos()
        setupBreakScreen()

        val closeButton = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.exit_button)
        closeButton.setOnClickListener{
            openApp(context, getHomeScreenPackage(context))
        }

        val endBreakButton = blockScreen.findViewById<TextView>(R.id.end_break_button)
        endBreakButton.setOnClickListener{
            context.sendBroadcast(Intent("com.lock.focus.END_BREAK"))
        }
        
        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        layoutParams.gravity = Gravity.TOP or Gravity.START

        windowManager.addView(blockScreen, layoutParams)

        openAppAsBackground(context)
    }

    public fun exitOverlay(){
        try{
            windowManager.removeView(blockScreen)
        } catch(e: Exception){}
    }

    public fun showOverlay() {
        if(blockScreen.visibility != View.VISIBLE){
            switchTab(Tab.HOME)
            blockScreen.visibility = View.VISIBLE
        }
        val currentApp = getForegroundApp(context)
        if(currentApp != "com.lock.focus" || currentApp != "not-found"){
            openAppAsBackground(context)
        }
    }

    public fun hideOverlay() {
        blockScreen.visibility = View.INVISIBLE
    }

    public fun generateListTile(title: String, subtitle: String? = null, disabled: Boolean = false, onPressed: () -> Unit): View {
        val buttonWidget = inflater.inflate(R.layout.list_tile, null)
        val titleWidget = buttonWidget.findViewById<TextView>(R.id.title)
        val subtitleWidget = buttonWidget.findViewById<TextView>(R.id.subtitle)
        val iconWidget = buttonWidget.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.icon)

        titleWidget.text = title

        if(subtitle != null){
            subtitleWidget.text = subtitle
            subtitleWidget.visibility = View.VISIBLE
        }

        if(disabled){
            titleWidget.setTextColor(Color.parseColor("#9E9E9E"))
            iconWidget.setColorFilter(Color.parseColor("#9E9E9E"))
        }

        buttonWidget.setOnClickListener {
            onPressed()
        }

        return buttonWidget
    }
}

enum class Tab{
    HOME, APPS, VIDEOS, BREAK, EXIT
}