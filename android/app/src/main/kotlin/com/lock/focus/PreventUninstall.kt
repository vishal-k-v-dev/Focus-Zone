package com.lock.focus

import android.net.*
import android.os.*
import android.content.*
import android.widget.Toast
import android.app.admin.*
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.android.FlutterActivity

class MyDeviceAdminReceiver : DeviceAdminReceiver() {
    
    override fun onEnabled(context: Context, intent: Intent) {
        
    }

    override fun onDisabled(context: Context, intent: Intent) {
        
    }
}
