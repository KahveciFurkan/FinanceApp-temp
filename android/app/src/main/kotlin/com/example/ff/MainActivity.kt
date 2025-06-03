package com.example.ff

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.RemoteInput
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        showQuickExpenseNotification(this)
        
            
        
    }

    private fun showQuickExpenseNotification(context: Context) {
        val channelId = "quick_expense_channel"
        val notificationId = 1001

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Hızlı Harcama",
                NotificationManager.IMPORTANCE_HIGH
            )
            val notificationManager =
                context.getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }

        val remoteInput = RemoteInput.Builder("input_amount")
            .setLabel("Tutarı girin")
            .build()

        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val action = NotificationCompat.Action.Builder(
            android.R.drawable.ic_input_add,
            "Harcamayı Ekle",
            pendingIntent
        ).addRemoteInput(remoteInput).build()

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_send)
            .setContentTitle("Hızlı Harcama")
            .setContentText("Kategori: Yiyecek - Tutar girin")
            .addAction(action)
            .setOngoing(true)
            .build()

        val notificationManager = context.getSystemService(NotificationManager::class.java)
        notificationManager.notify(notificationId, notification)
    }
}
