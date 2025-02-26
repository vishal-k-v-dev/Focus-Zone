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
// import androidx.appcompat.app.AppCompatActivity

// class BackgroundScreen : AppCompatActivity() {
//     public lateinit var blockScreen: View //BlockScreen
//     public lateinit var webviewScreen: View //WebView
    
//     public lateinit var inflater: LayoutInflater

//     public lateinit var appsScreen: View //AppsScreen
//     public lateinit var videosScreen: View //VideosScreen
//     public lateinit var videosUnavailableScreen: View //VideosUnavailableScreen
//     public lateinit var breakScreen: View //BreaksScreen
//     public lateinit var breakUnavailableScreen: View //BreakUnavailableScreen
//     public lateinit var bottomNavigationBar: View //BottomNavigationBar
//     public lateinit var topBar: View //TopBar

//     //BottomNavigationBar Tabs
//     private lateinit var appsTab: com.google.android.material.imageview.ShapeableImageView //AppsTab
//     private lateinit var videosTab: com.google.android.material.imageview.ShapeableImageView //VideosTab
//     private lateinit var breakTab: com.google.android.material.imageview.ShapeableImageView //BreakTab

//     private var currentTab: Tab = Tab.APPS //CurrentTab

//     private lateinit var appsList: LinearLayout //AppsList
//     private lateinit var videosList: LinearLayout //VideosList
//     private lateinit var breaksList: LinearLayout //VideosList

//     val breakWidgetsAdded = mutableListOf<View>()
//     val appWidgetsAdded = mutableListOf<View>()

//     fun initalise() {
//         inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater

//         blockScreen = LayoutInflater.from(this).inflate(R.layout.overlay_view, null)
//         webviewScreen = LayoutInflater.from(this).inflate(R.layout.web_view, null)

//         //BottomNavigationBar Tabs
//         appsTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.apps_tab)
//         videosTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.videos_tab)
//         breakTab = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.break_tab)

//         appsScreen = blockScreen.findViewById<LinearLayout>(R.id.apps_screen) //AppsScreen
//         videosScreen = blockScreen.findViewById<LinearLayout>(R.id.videos_screen) //VideosScreen
//         videosUnavailableScreen = blockScreen.findViewById<LinearLayout>(R.id.videos_unavailable_screen) //VideosUnavailableScreen
//         breakScreen = blockScreen.findViewById<LinearLayout>(R.id.breaks_screen) //VideosScreen
//         breakUnavailableScreen = blockScreen.findViewById<LinearLayout>(R.id.breaks_unavailable_screen) //VideosScreen
//         bottomNavigationBar = blockScreen.findViewById<LinearLayout>(R.id.bottom_navigation_bar) //BottomNavigationBar
//         topBar = blockScreen.findViewById<LinearLayout>(R.id.top_bar) //TopBar

//         appsList = blockScreen.findViewById<LinearLayout>(R.id.apps_list) //AppsList
//         videosList = blockScreen.findViewById<LinearLayout>(R.id.videos_list) //VideosList
//         breaksList = blockScreen.findViewById<LinearLayout>(R.id.breaks_list) //BreaksList
//     }

//     fun loadApps() {
//         val appNames = getStringList(this, "whitelisted_names")
//         val appPackageNames = getStringList(this, "whitelisted_packages")
//         val appUsageLimits = getIntList(this, "app_usage_limits")

//         if(appWidgetsAdded.size > 0){
//             for(buttonView in appWidgetsAdded){
//                 appsList.removeView(buttonView)
//             }
//             appWidgetsAdded.clear()
//         }

//         for(app in getStringList(this, "whitelisted_names")){
//             val index = appNames.indexOf(app)
//             val limit = appUsageLimits[index]

//             val buttonView = generateListTile(
//                 title = app,
//                 subtitle = if(limit < 43200000) getDurationText(limit) else null,
//                 onPressed = {
//                     openApp(this, appPackageNames[index])
//                 }
//             )

//             appsList.addView(buttonView)

//             appWidgetsAdded.add(buttonView)
//         }
//     }

//     fun loadVideos(){
//         val IDs = getStringList(this, "youtube_videos_id")
//         val titles = getStringList(this, "youtube_videos_title")
//         val imageLinks = getStringList(this, "youtube_videos_thumbnail_link")

//         if(imageLinks.size > 0){
//             for (i in imageLinks.indices) {
//                 val videoItem = LayoutInflater.from(this).inflate(R.layout.video_item, videosList, false)
//                 val imageView = videoItem.findViewById<ImageView>(R.id.itemImage)
//                 val titleView = videoItem.findViewById<TextView>(R.id.itemTitle)
        
//                 // Load image using Glide
//                 Glide.with(this).load(imageLinks[i]).into(imageView)
//                 //set title
//                 titleView.text = titles[i]
        
//                 videoItem.setOnClickListener {
//                     openWebViewYoutube("https://www.youtube.com/embed/${IDs[i]}")   
//                 }
//                 videosList.addView(videoItem)
//             }
//         }      
//     }

//     fun openWebViewYoutube(link: String) {
//         val webView: WebView = webviewScreen.findViewById(R.id.web_view)
//         webView.settings.javaScriptEnabled = true    
//         webView.webViewClient = object : WebViewClient() {
//             override fun shouldOverrideUrlLoading(
//                 view: WebView?,
//                 request: WebResourceRequest?
//             ): Boolean {
//                 return true
//             }
//         }
//         webView.loadUrl(link)
//         setContentView(webviewScreen)
//     }

//     fun setupBreakScreen() {
//         val breakCount = blockScreen.findViewById<TextView>(R.id.breaks_count)

//         if(getBreaksCount(this) == 1){
//             breakCount.text = "1 break available"
//         }
//         else{
//             breakCount.text = "${getBreaksCount(this)} breaks available"
//         }

//         if(breakWidgetsAdded.size > 0){
//             for(buttonView in breakWidgetsAdded){
//                 breaksList.removeView(buttonView)
//             }
//             breakWidgetsAdded.clear()
//         }

//         for(duration in 5..60 step 5){
//             val buttonView = generateListTile(
//                 title = "$duration Minutes",
//                 disabled = duration > getMaximumBreakDuration(this),
//                 onPressed = {
//                     this.sendBroadcast(Intent("com.lock.focus.START_BREAK"))
//                 }
//             )

//             breaksList.addView(buttonView)

//             breakWidgetsAdded.add(buttonView)
//         }
//     }

//     fun setupBottomNavigationBar(){
//         appsTab.setOnClickListener{
//             switchTab(Tab.APPS)
//         }
//         videosTab.setOnClickListener{
//             switchTab(Tab.VIDEOS)
//         }
//         breakTab.setOnClickListener{
//             switchTab(Tab.BREAK)
//         }
//     }

//     fun switchTab(tab: Tab){
//         val whiteColor = Color.parseColor("#FFFFFF")
//         val greenAccentColor = Color.parseColor("#69F0AE")

//         fun hideAllScreens() {
//             appsScreen.visibility = View.GONE
//             videosScreen.visibility = View.GONE
//             videosUnavailableScreen.visibility = View.GONE 
//             breakScreen.visibility = View.GONE
//             breakUnavailableScreen.visibility = View.GONE
//             //Make Bottom Navigation Bar & top bar Visible
//             bottomNavigationBar.visibility = View.VISIBLE
//             topBar.visibility = View.VISIBLE
//         }

//         fun setDefaultColorTabs() {
//             appsTab.setColorFilter(whiteColor)
//             videosTab.setColorFilter(whiteColor)
//             breakTab.setColorFilter(whiteColor)
//         }

//         if(tab == Tab.APPS){
//             hideAllScreens()
//             setDefaultColorTabs()
//             loadApps()
//             appsTab.setColorFilter(greenAccentColor)
//             appsScreen.visibility = View.VISIBLE
//         }

//         else if(tab == Tab.VIDEOS){
//             hideAllScreens()
//             setDefaultColorTabs()

//             videosTab.setColorFilter(greenAccentColor)            

//             if(getStringList(this, "youtube_videos_id").size > 0){
//                 videosScreen.visibility = View.VISIBLE
//             }
//             else{
//                 videosUnavailableScreen.visibility = View.VISIBLE
//             }            
//         }

//         else if(tab == Tab.BREAK){
//             hideAllScreens()

//             setDefaultColorTabs()

//             setupBreakScreen()

//             breakTab.setColorFilter(greenAccentColor)

//             if(getBreaksCount(this) > 0){
//                 breakScreen.visibility = View.VISIBLE
//             }
//             else{
//                 breakUnavailableScreen.visibility = View.VISIBLE
//             }
//         }
//     }

//     fun generateListTile(title: String, subtitle: String? = null, disabled: Boolean = false, onPressed: () -> Unit): View {
//         val buttonWidget = inflater.inflate(R.layout.list_tile, null)
//         val titleWidget = buttonWidget.findViewById<TextView>(R.id.title)
//         val subtitleWidget = buttonWidget.findViewById<TextView>(R.id.subtitle)
//         val iconWidget = buttonWidget.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.icon)

//         titleWidget.text = title

//         if(subtitle != null){
//             subtitleWidget.text = subtitle
//             subtitleWidget.visibility = View.VISIBLE
//         }

//         if(disabled){
//             titleWidget.setTextColor(Color.parseColor("#9E9E9E"))
//             iconWidget.setColorFilter(Color.parseColor("#9E9E9E"))
//         }

//         buttonWidget.setOnClickListener {
//             onPressed()
//         }

//         return buttonWidget
//     }

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         initalise()
//         setContentView(blockScreen)
//         setupBottomNavigationBar()
//         loadApps()
//         loadVideos()
//         setupBreakScreen()

//         val closeButton = blockScreen.findViewById<com.google.android.material.imageview.ShapeableImageView>(R.id.close_button)
//         closeButton.setOnClickListener {
//             sendBroadcast(Intent("com.lock.focus.SHOW_OVERLAY"))
//         }
//     }

//     override fun onBackPressed() {
//         setContentView(blockScreen)
//     }
// }

// enum class Tab{
//     APPS, VIDEOS, BREAK
// }

import android.content.*
import android.os.Bundle
import android.view.*
import androidx.appcompat.app.AppCompatActivity

class BackgroundScreen : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sendBroadcast(Intent("com.lock.focus.SHOW_OVERLAY"))
        setContentView(R.layout.background)
    }
    
    override fun onResume() {
        super.onResume()
        sendBroadcast(Intent("com.lock.focus.SHOW_OVERLAY"))
    }
}