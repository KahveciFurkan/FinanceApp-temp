package com.example.ff

import android.app.Activity
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.RemoteInput

class QuickExpenseReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
    val input = RemoteInput.getResultsFromIntent(intent)?.getCharSequence("input_amount")
    val category = intent.getStringExtra("category") ?: "Diğer"
    val notificationId = 1001

    // Sonuç için PendingIntent al
    val resultPendingIntent = intent.getParcelableExtra<PendingIntent>(
        Notification.EXTRA_REMOTE_INPUT_PENDING_INTENT
    )

    try {
        if (input != null) {
            // Veriyi kaydet
            val prefs = context.getSharedPreferences("quick_expense", Context.MODE_PRIVATE)
            prefs.edit().putString("pending_expense", "$category|$input").apply()

            // Bildirimi kapat
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager.cancel(notificationId)

            // Başarılı sonucu ilet
            resultPendingIntent?.send(Activity.RESULT_OK)
        } else {
            // Hata durumunu ilet
            resultPendingIntent?.send(Activity.RESULT_CANCELED)
        }
    } catch (e: PendingIntent.CanceledException) {
        e.printStackTrace()
        setResultCode(Activity.RESULT_CANCELED)
    }
}
}
