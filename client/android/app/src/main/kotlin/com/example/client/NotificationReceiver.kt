package com.example.client


import androidx.core.app.NotificationManagerCompat

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log



class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "close") {

            Log.d("NotificationReceiver", "HELLLOOOOOOO++++++")
            // val mainActivity = context as MainActivity
            // (context as? MainActivity)?.closeNotification()
            val appContext = context.applicationContext

            val notificationManager = NotificationManagerCompat.from(appContext)
            notificationManager.cancel(1) // Ensure you're using the correct notification ID
        }
    }
}