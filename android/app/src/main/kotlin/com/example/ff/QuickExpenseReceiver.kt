package com.example.ff

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.app.Activity
import android.util.Log
import androidx.core.app.RemoteInput

class QuickExpenseReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val input = RemoteInput.getResultsFromIntent(intent)?.getCharSequence("input_amount")
        val category = intent.getStringExtra("category") ?: "Diğer"
        val notificationId = 1001

        try {
            if (input != null) {
                // Veriyi kaydet
                val prefs = context.getSharedPreferences("quick_expense", Context.MODE_PRIVATE)
                prefs.edit().putString("pending_expense", "$category|$input").apply()

                // Bildirimi kapat
                val notificationManager = context.getSystemService(NotificationManager::class.java)
                notificationManager.cancel(notificationId)

                // Log başarılı işlem
                Log.d("QuickExpenseReceiver", "Harcama kaydedildi: $category | $input")
            } else {
                Log.d("QuickExpenseReceiver", "Input null geldi")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
