package com.example.client

import com.example.client.Notification
import android.app.Service
import android.os.IBinder
import android.content.Intent


class NotificationService : Service() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Notification.handleIntent(this, intent)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}