package com.example.client

import com.example.client.NotificationController
import android.app.Service
import android.os.IBinder
import android.content.Intent
import com.example.client.Audio
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.CountDownTimer
import android.app.PendingIntent
import android.app.Notification
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.Manifest
import androidx.core.app.ActivityCompat
import android.content.pm.PackageManager
import android.widget.Toast
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.dart.DartExecutor


class NotificationService : Service() {

    private val CHANNEL_ID = "DEFAULT_CHANNEL_ID"
    private val NOTIFICATION_ID = 1
    private var timeLeft = 0L
    private var timeAugmentAmount = 5L
    private var countdownTimer: CountDownTimer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        when(intent?.action) {

            "START_TIMER" -> {
                Log.d("STARTTIMER", "WE ARE IN THE START TIMER METHOD CALL")
                val duration = intent.getLongExtra("duration", 0L)
                updateTimer(duration)
            }

            "STOP_TIMER" -> {
                Log.d("STOPTIMER", "WE ARE IN THE STOP TIMER METHOD CALL")
                cancelTimer()
                closeNotification()
            }

            "INCREMENT_TIMER" -> {
                incrementTimer()
            }

            "DECREMENT_TIMER" -> {
                decrementTimer()
            }

            "MODIFY_TIME_STEPS" -> {
                val timeStepAmount = intent.getLongExtra("timeStepAmount", 5L)
                // Log.d("MODIFY_TIME_STEPS", "WE MADE IT IN AND ALSO THE TIME STEP AMOUNT IS " + timeStepAmount.toString())
                modifyTimeSteps(timeStepAmount)
            }

        }

        // NotificationController.handleIntent(this, intent)
        // return START_NOT_STICKY
        return START_NOT_STICKY
    }

    fun updateTimer(duration: Long) {

        // Cancel current CountDownTimer if it exists
        countdownTimer?.cancel()

        // Create a new CountDownTimer with the updated timeLeft
        timeLeft = duration

        // Log.d("CountDownTimer", "HELLO FROM INSIDE UPDATETIMER")
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
                buildNotification(timeLeft.toString())

                // Send timeLeft to Flutter
                args["timeLeft"] = timeLeft
                GlobalChannel.methodChannel.invokeMethod("updateTimeLeft", args)

                
            }

            override fun onFinish() {

                // Cancel timer and then close the notification
                cancelTimer()
                closeNotification()

                // Stop all audio on android side if the flutter application is currently closed
                Audio.stopAudio(applicationContext)
            }
        }

        // Start the countdown timer
        countdownTimer?.start()
    }

    private fun buildNotification(duration: String) {

        val ACTION_CLOSE = "STOP_TIMER"
        val ACTION_INCREMENT = "INCREMENT_TIMER"
        val ACTION_DECREMENT = "DECREMENT_TIMER"


        val flag =
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
              PendingIntent.FLAG_IMMUTABLE
          else
              0

        // // Close Intent
        val closeIntent = Intent(this, NotificationService::class.java).apply {
          action = ACTION_CLOSE
        }
        val closePendingIntent = PendingIntent.getService(this, 0, closeIntent, flag)

        // // Increment Intent
        val incrementIntent = Intent(this, NotificationService::class.java).apply {
            action = ACTION_INCREMENT
        }
        val incrementPendingIntent = PendingIntent.getService(this, 0, incrementIntent, flag)

        // // Decrement Intent
        val decrementIntent = Intent(this, NotificationService::class.java).apply {
            action = ACTION_DECREMENT
        }
        val decrementPendingIntent = PendingIntent.getService(this, 0, decrementIntent, flag)

        // // Create an explicit intent for an Activity in your app.
        val openAppIntent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val openAppPendingIntent = PendingIntent.getActivity(applicationContext, 0, openAppIntent, PendingIntent.FLAG_MUTABLE)

        // Build and update the notification
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
        .setSmallIcon(R.drawable.duration) // Replace with your app's icon
        // .setContentTitle(notificationTitle)
        .setContentText("$duration seconds remaining")
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setOngoing(true) // Keeps the notification persistent
        .addAction(R.drawable.duration, "Close", closePendingIntent)
        .addAction(R.drawable.duration, "Increment", incrementPendingIntent)
        .addAction(R.drawable.duration, "Decrement", decrementPendingIntent)
        .setContentIntent(openAppPendingIntent)
        
        startForeground(NOTIFICATION_ID, builder.build())
    }

    fun cancelTimer() {

        Log.d("CANCELTIMER", "WE ARE IN THE CANCEL TIMER METHOD CALL")

        val args = HashMap<String, Any>()
        args["timeLeft"] = 0
        GlobalChannel.methodChannel.invokeMethod("updateTimeLeft", args)
        countdownTimer?.cancel()
    }

    fun updateEndEstimation() {
        val args = HashMap<String, Any>()
        GlobalChannel.methodChannel.invokeMethod("updateEndEstimation", args)
    }

    fun modifyTimeSteps(value: Long) {
        timeAugmentAmount = value
    }

    fun incrementTimer() {
        // communicate to the flutter side, the new time with intents
        timeLeft += timeAugmentAmount
        updateTimer(timeLeft)

        // Now that the timer minutes have been altered, we want to also adjust the end estimation time
        updateEndEstimation()

    }

    fun decrementTimer() {
        // communicate to the flutter side, the new time with intents

        timeLeft -= timeAugmentAmount
        if (timeLeft <= 0) {
            timeLeft = 0
        }
        updateTimer(timeLeft)

        // Now that the timer minutes have been altered, we want to also adjust the end estimation time
        updateEndEstimation()
    }


    fun closeNotification() {
        
        stopForeground(true)
        stopSelf()
    }

    // override fun onBind(intent: Intent?): IBinder? = null
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}