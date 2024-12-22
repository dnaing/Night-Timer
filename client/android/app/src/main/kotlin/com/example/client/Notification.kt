package com.example.client

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CountDownTimer
import android.app.PendingIntent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.Manifest
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import android.widget.Toast
import android.util.Log

object Notification {

    private var countdownTimer: CountDownTimer? = null
    private const val CHANNEL_ID = "default_channel_id"
    private const val NOTIFICATION_ID = 1

    


    fun createNotificationChannel(context: Context) {

        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is not in the Support Library.

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // val name = getString(R.string.channel_name)
            // val descriptionText = getString(R.string.channel_description)
            val name = "Default Channel"
            val descriptionText = "This channel is used for notifications."
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, name, importance)
            channel.description = descriptionText
            // Register the channel with the system.
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    
    fun isNotificationPermissionsGranted(context: Context): Boolean {
        // Check if permission is granted
        return ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED    
    }

    fun requestNotificationPermissions(activity: MainActivity) {
        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            1   // request code
        )
    }

    fun createNotification(context: Context, duration: String) {
        
        countdownTimer = object : CountDownTimer(duration.toLong() * 1000L, 1000L) { // Convert seconds to milliseconds
            var timeLeft = duration.toLong()

            override fun onTick(millisUntilFinished: Long) {
                // Decrement timeLeft
                buildNotification(context, timeLeft.toString())
                timeLeft--
            }

            override fun onFinish() {
                // Notify completion 
                closeNotification(context)
            }
        }

        // Start the countdown timer
        countdownTimer?.start()
    }

    private fun buildNotification(context: Context, duration: String) {

        val ACTION_CLOSE = "close"

        val closeIntent = Intent(context, NotificationService::class.java).apply {
          action = ACTION_CLOSE
        }
        val flag =
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
              PendingIntent.FLAG_IMMUTABLE
          else
              0
        val closePendingIntent = PendingIntent.getService(
            context,
            0,
            closeIntent,
            flag
        )

        // Build and update the notification
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
        .setSmallIcon(R.drawable.duration) // Replace with your app's icon
        // .setContentTitle(notificationTitle)
        .setContentText("$duration seconds remaining")
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setOngoing(true) // Keeps the notification persistent
        .addAction(R.drawable.duration, "Close", closePendingIntent)
        
        with(NotificationManagerCompat.from(context)) {
            notify(NOTIFICATION_ID, builder.build())
        }
    }

    fun closeNotification(context: Context) {

        with(NotificationManagerCompat.from(context)) {
            // notificationId is a unique int for each notification that you must define.
            cancel(NOTIFICATION_ID)
        }

        countdownTimer?.cancel()
        countdownTimer = null
    }

  
    fun handleIntent(context: Context, intent: Intent?) {
        when (intent?.action) {
            "close" -> closeNotification(context)
        }
    }

}