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

object NotificationController {

    // private var countdownTimer: CountDownTimer? = null
    private const val CHANNEL_ID = "DEFAULT_CHANNEL_ID"
    // private const val NOTIFICATION_ID = 1
    // private var timeLeft = 0L
    // private var timeAugmentAmount = 5L
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

    // fun updateEndEstimation() {
    //     val args = HashMap<String, Any>()
    //     GlobalChannel.methodChannel.invokeMethod("updateEndEstimation", args)
    // }

    // fun incrementTimer(context: Context) {
    //     // communicate to the flutter side, the new time with intents
    //     timeLeft += timeAugmentAmount
    //     updateTimer(context, timeLeft.toString())

    //     // Now that the timer minutes have been altered, we want to also adjust the end estimation time
    //     updateEndEstimation()

    // }

    // fun decrementTimer(context: Context) {
    //     // communicate to the flutter side, the new time with intents

    //     timeLeft -= timeAugmentAmount
    //     if (timeLeft <= 0) {
    //         timeLeft = 0
    //     }
    //     updateTimer(context, timeLeft.toString())

    //     // Now that the timer minutes have been altered, we want to also adjust the end estimation time
    //     updateEndEstimation()

        
    // }

}