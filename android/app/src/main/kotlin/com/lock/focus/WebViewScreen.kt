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
import androidx.appcompat.app.AppCompatActivity

class WebViewScreen : AppCompatActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        sendBroadcast(Intent("com.lock.focus.WEBVIEW_ACTIVE"))

        setContentView(R.layout.web_view)

        val webView: WebView = findViewById(R.id.web_view)
        webView.settings.javaScriptEnabled = true    
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(
                view: WebView?,
                request: WebResourceRequest?
            ): Boolean {
                return true
            }
        }
        webView.loadUrl(
            intent.getStringExtra("url") ?: ""
        )
    }

    override fun onResume() {
        super.onResume()
        sendBroadcast(Intent("com.lock.focus.WEBVIEW_ACTIVE"))
    }

    override fun onPause() {
        super.onPause()
        sendBroadcast(Intent("com.lock.focus.WEBVIEW_INACTIVE"))
    }
}