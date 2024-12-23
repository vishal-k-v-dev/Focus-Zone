package com.lock.focus

import android.widget.Toast
import android.content.Intent
import android.content.Context
import android.app.admin.DeviceAdminReceiver

class MyDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
    }

    override fun onDisabled(context: Context, intent: Intent) {
    }
}
