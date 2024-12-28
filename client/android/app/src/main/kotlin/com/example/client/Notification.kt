package com.example.client

import com.example.client.Audio

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

import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.dart.DartExecutor

object Notification {

    private var countdownTimer: CountDownTimer? = null
    private const val CHANNEL_ID = "default_channel_id"
    private const val NOTIFICATION_ID = 1
    private var timeLeft = 0L
    private var timeAugmentAmount = 5L
    // MethodChannel channel = new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.client/platform_methods");

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

    fun updateTimer(context: Context, duration: String) {

        // Cancel current CountDownTimer if it exists
        countdownTimer?.cancel()

        // Create a new CountDownTimer with the updated timeLeft
        timeLeft = duration.toLong()

        // Trigger the first notification immediately
        // buildNotification(context, timeLeft.toString())

        Log.d("CountDownTimer", "HELLO FROM INSIDE UPDATETIMER")
        val args = HashMap<String, Any>()

        countdownTimer = object : CountDownTimer(timeLeft * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                // Calculate the remaining seconds accurately
                val secondsLeft = kotlin.math.ceil(millisUntilFinished / 1000.0).toLong()
                timeLeft = secondsLeft

                // Log raw millis and calculated seconds
                // Log.d("CountDownTimer", "millisUntilFinished: $millisUntilFinished")
                Log.d("CountDownTimer", "Time left: $timeLeft seconds")

                // Update the notification
                buildNotification(context, timeLeft.toString())

                // Send timeLeft to Flutter
                args["timeLeft"] = timeLeft
                GlobalChannel.methodChannel.invokeMethod("updateTimeLeft", args)

                
            }

            override fun onFinish() {

                // Send timeleft to flutter
                args["timeLeft"] = 0
                GlobalChannel.methodChannel.invokeMethod("updateTimeLeft", args)
                // Notify completion and clear the notification
                closeNotification(context)
                // Stop all audio on android side if the flutter application is currently closed
                Audio.stopAudio(context)
            }
        }

        // Start the countdown timer
        countdownTimer?.start()
    }

    private fun buildNotification(context: Context, duration: String) {

        val ACTION_CLOSE = "close"
        val ACTION_INCREMENT = "increment"
        val ACTION_DECREMENT = "decrement"
        val ACTION_OPEN_APP = "openApp"

        val flag =
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
              PendingIntent.FLAG_IMMUTABLE
          else
              0

        // Close Intent
        val closeIntent = Intent(context, NotificationService::class.java).apply {
          action = ACTION_CLOSE
        }
        val closePendingIntent = PendingIntent.getService(context, 0, closeIntent, flag)

        // Increment Intent
        val incrementIntent = Intent(context, NotificationService::class.java).apply {
            action = ACTION_INCREMENT
        }
        val incrementPendingIntent = PendingIntent.getService(context, 0, incrementIntent, flag)

        // Decrement Intent
        val decrementIntent = Intent(context, NotificationService::class.java).apply {
            action = ACTION_DECREMENT
        }
        val decrementPendingIntent = PendingIntent.getService(context, 0, decrementIntent, flag)

        // Create an explicit intent for an Activity in your app.
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val openAppPendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, PendingIntent.FLAG_MUTABLE)



        // Build and update the notification
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
        .setSmallIcon(R.drawable.duration) // Replace with your app's icon
        // .setContentTitle(notificationTitle)
        .setContentText("$duration seconds remaining")
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setOngoing(true) // Keeps the notification persistent
        .addAction(R.drawable.duration, "Close", closePendingIntent)
        .addAction(R.drawable.duration, "Increment", incrementPendingIntent)
        .addAction(R.drawable.duration, "Decrement", decrementPendingIntent)
        .setContentIntent(openAppPendingIntent)
        
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

        
        

    }

    fun incrementTimer(context: Context) {
        // communicate to the flutter side, the new time with intents
        timeLeft += timeAugmentAmount
        updateTimer(context, timeLeft.toString())
    }

    fun decrementTimer(context: Context) {
        // communicate to the flutter side, the new time with intents

        timeLeft -= timeAugmentAmount
        if (timeLeft <= 0) {
            timeLeft = 0
        }
        updateTimer(context, timeLeft.toString())

        
    }

    fun handleIntent(context: Context, intent: Intent?) {
        when (intent?.action) {
            "close" -> closeNotification(context)
            "increment" -> incrementTimer(context)
            "decrement" -> decrementTimer(context)
        }
    }

}