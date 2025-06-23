package com.example.ff
import android.os.Bundle
import android.os.SystemClock
import android.view.KeyEvent
import io.flutter.plugin.common.MethodChannel

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.RemoteInput
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.ff/quick_expense"
    private var methodChannel: MethodChannel? = null

    private var lastVolumeUpPressTime = 0L
    private val doublePressTimeout = 500L // ms

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            val now = System.currentTimeMillis()
            if (now - lastVolumeUpPressTime <= doublePressTimeout) {
                // Çift basma algılandı
                methodChannel?.invokeMethod("openAddExpenseScreen", null)
                lastVolumeUpPressTime = 0L
                return true
            }
            lastVolumeUpPressTime = now
        }
        return super.onKeyUp(keyCode, event)
    }
}
