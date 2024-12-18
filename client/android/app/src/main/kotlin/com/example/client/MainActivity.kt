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

import android.os.CountDownTimer


class MainActivity: FlutterActivity() {


  // val notificationTitle = call.argument<String>("durationInSeconds")
  // val notificationDescription = "Default description"
  private var notificationTitle: String = ""
  private var notificationDescription: String = ""
  private var countdownTimer: CountDownTimer? = null // Store the timer reference

  override fun onCreate(savedInstanceState: android.os.Bundle?) {
    super.onCreate(savedInstanceState)

    // Notification channel is created when the app is started
    createNotificationChannel()
  }

  // This function sets up the method channels that the Flutter application will be calling

  private val CHANNEL = "com.example.client/platform_methods"
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
        
      } else if (call.method == "startBackgroundTimer") {

        // Start a timer in the background using the Android API
        // This timer would keep our notification constantly updated

        notificationTitle = "Night Timer"
        notificationDescription = call.argument<String>("durationInSeconds") ?: ""

        if (isNotificationPermissionsGranted()) {
          createNotification(notificationTitle, notificationDescription)
          result.success("Notification successfully posted")
        } else {
          requestNotificationPermissions()
        }
      } else if (call.method == "stopBackgroundTimer") {
        closeNotification()
      }
      else {
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

  private fun createNotification(notificationTitle: String, notificationDescription: String) {
    // Use the Context properly
    val context = this

    countdownTimer = object : CountDownTimer(notificationDescription.toLong() * 1000L, 1000L) { // Convert seconds to milliseconds
      var timeLeft = notificationDescription.toLong()

      override fun onTick(millisUntilFinished: Long) {
        // Decrement timeLeft
        buildNotification(notificationTitle, timeLeft.toString())
        timeLeft--
      }

      override fun onFinish() {
        // Notify completion 
        closeNotification()
      }
    }

    // Start the countdown timer
    countdownTimer?.start()
  }

  private fun buildNotification(notificationTitle: String, notificationDescription: String) {
    // Build and update the notification
    val builder = NotificationCompat.Builder(context, CHANNEL_ID)
      .setSmallIcon(R.drawable.duration) // Replace with your app's icon
      .setContentTitle(notificationTitle)
      .setContentText("Time Remaining: $notificationDescription seconds")
      .setPriority(NotificationCompat.PRIORITY_DEFAULT)
      .setOngoing(true) // Keeps the notification persistent

    with(NotificationManagerCompat.from(context)) {
      notify(NOTIFICATION_ID, builder.build())
    }
  }

  private fun closeNotification() {

    with(NotificationManagerCompat.from(this)) {
      // notificationId is a unique int for each notification that you must define.
      cancel(NOTIFICATION_ID)
    }

    countdownTimer?.cancel()
    countdownTimer = null
  }

  private fun isNotificationPermissionsGranted(): Boolean {
    // Check if permission is granted
    if (ActivityCompat.checkSelfPermission(
            this@MainActivity,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
    ) {
        return true
    // but otherwise, if permission isn't granted
    } else {
        return false
    }    
  }

  private fun requestNotificationPermissions() {
    ActivityCompat.requestPermissions(
      this@MainActivity,
      arrayOf(Manifest.permission.POST_NOTIFICATIONS),
      1   // request code
    )
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    // Check if the requestCode matches the one you used in requestPermissions()
    if (requestCode == 1) {
        // If the permission is granted, grantResults[0] will be PackageManager.PERMISSION_GRANTED
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // Permission was granted, you can proceed with creating the notification
            createNotification(notificationTitle, notificationDescription)
            // result.success("Notification successfully posted after permissions granted")
        } else {
            // Permission was denied, handle accordingly (e.g., show a message to the user)
            Toast.makeText(this, "Notification permission denied", Toast.LENGTH_SHORT).show()
            // result.error("PERMISSION_DENIED", "Notification permissions denied", null)
        }

        notificationTitle = ""
        notificationDescription = ""
    }
  }

}
