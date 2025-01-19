package com.example.client

import com.example.client.Audio
import com.example.client.NotificationController

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.media.AudioManager
import android.media.AudioFocusRequest

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager
import android.widget.Toast

import android.os.CountDownTimer

import android.app.PendingIntent
import android.content.Intent
import android.app.Service
import android.util.Log



class MainActivity: FlutterActivity() {

  private var duration: Long = 0L


  override fun onCreate(savedInstanceState: android.os.Bundle?) {
    super.onCreate(savedInstanceState)

    // Notification channel is created when the app is started
    NotificationController.createNotificationChannel(this)
  }

  // This function sets up the method channels that the Flutter application will be calling

  private val CHANNEL = "com.example.client/platform_methods"
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GlobalChannel.setMethodChannel(flutterEngine, CHANNEL)
    
    GlobalChannel.methodChannel.setMethodCallHandler { call, result ->
      Log.d("MethodChannel", "Method called: ${call.method}")
      when(call.method) {

        "stopAudio" -> {
          val success = Audio.stopAudio(context)
          if (success) {
              result.success("All audio has been stopped")
          } else {
              result.error("ERROR_AUDIO_STOP", "Audio was not able to be stopped", null)
          }
        }

        "startBackgroundTimer" -> {
          duration = call.argument<String>("duration")?.toLong() ?: 0L // Get amount of minutes from flutter side if it exists but default to 0 if not

          if (NotificationController.isNotificationPermissionsGranted(this)) {

            // Permissions are granted so we send an intent to update the timer
            val intent = Intent(this, NotificationService::class.java).apply{
              action = "START_TIMER"
              putExtra("duration", duration)
            }
            startForegroundService(intent)
            result.success("Timer has been started")

          } else {
            // Permissions not granted
            NotificationController.requestNotificationPermissions(this)
            result.error("PERMISSION_DENIED", "Notification permissions were not granted", null)
          }
        }

        "stopBackgroundTimer" -> {
          // Notification should be closed
          val intent = Intent(this, NotificationService::class.java).apply{
            action = "STOP_TIMER"
          }
          startService(intent)
          result.success("Timer stopped and notification closed")
        }

        "modifyTimeSteps" -> {
          // Modify the time step amount
          val timeStepAmount = call.argument<Double>("timeStepAmount")?.toLong() ?: 5L // Get amount of minutes from flutter side if it exists but default to 0 if not
          val intent = Intent(this, NotificationService::class.java).apply{
            action = "MODIFY_TIME_STEPS"
            putExtra("timeStepAmount", timeStepAmount)
          }
          startService(intent)
          result.success("Time step amount successfully modified")
        }

        else -> {
          result.notImplemented()
        }

      }
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    // Check if the requestCode matches the one you used in requestPermissions()
    if (requestCode == 1) {
        // If the permission is granted, grantResults[0] will be PackageManager.PERMISSION_GRANTED
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

            // Permission was granted, you can proceed with creating the notification
            // but use an intent
            val intent = Intent(this, NotificationService::class.java).apply{
              action = "START_TIMER"
              putExtra("duration", duration)
            }
            startForegroundService(intent)

        } else {
            // Permission was denied, handle accordingly (e.g., show a message to the user)
            Toast.makeText(this, "Notification permission denied", Toast.LENGTH_SHORT).show()

        }

    }
  }

}