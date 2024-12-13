package com.example.client

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




class MainActivity: FlutterActivity() {


  override fun onCreate(savedInstanceState: android.os.Bundle?) {
    super.onCreate(savedInstanceState)
    createNotificationChannel()
    requestNotificationPermission()
  }

  



  // This below code is called when the com.example.client/audio channel is called by the application
  // It stops all audio on all other audio sources

  private val CHANNEL = "com.example.client/audio"
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      // This method is invoked on the main thread.
      call, result ->
      if (call.method == "stopAudio") {
        val success = stopAudio()
        if (success) {
            result.success("All audio has been stopped")
        } else {
            result.error("ERROR_AUDIO_STOP", "Audio was not able to be stopped", null)
        }
        
      } else {
        result.notImplemented()
      }
    }
  }

  // This function is the one that actually stops the audio
  private fun stopAudio(): Boolean {
    try {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .build()


        val audioRequest = audioManager.requestAudioFocus(focusRequest)


        return audioRequest == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    } catch (e: Exception) {
        e.printStackTrace()
    } 
    return false
  }

  private fun createNotificationChannel() {
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
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }
  }

  companion object {
    const val CHANNEL_ID = "default_channel_id"
    const val NOTIFICATION_ID = 1
  }

  private fun requestNotificationPermission() {
    // Check if permission is granted
    if (ActivityCompat.checkSelfPermission(
            this@MainActivity,
            Manifest.permission.POST_NOTIFICATIONS
        ) != PackageManager.PERMISSION_GRANTED
    ) {
        // If not granted, request the permission
        ActivityCompat.requestPermissions(
            this@MainActivity,
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            1   // request code
        )
    } else {
        // If permission is already granted, create the notification
        createNotification()
    }
  }

  private fun createNotification() {
    var builder = NotificationCompat.Builder(this, CHANNEL_ID)
        .setSmallIcon(R.drawable.duration)
        .setContentTitle("test title")
        .setContentText("test content")
        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        .setOngoing(true) // This keeps the notification in the status bar
      
    with(NotificationManagerCompat.from(this)) {
      // notificationId is a unique int for each notification that you must define.
      notify(NOTIFICATION_ID, builder.build())
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    // Check if the requestCode matches the one you used in requestPermissions()
    if (requestCode == 1) {
        // If the permission is granted, grantResults[0] will be PackageManager.PERMISSION_GRANTED
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // Permission was granted, you can proceed with creating the notification
            createNotification()
        } else {
            // Permission was denied, handle accordingly (e.g., show a message to the user)
            Toast.makeText(this, "Notification permission denied", Toast.LENGTH_SHORT).show()
        }
    }
  }

}
