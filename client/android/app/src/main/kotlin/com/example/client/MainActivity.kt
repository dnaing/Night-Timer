package com.example.client

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.media.AudioManager
import android.media.AudioFocusRequest


class MainActivity: FlutterActivity() {
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

  private fun stopAudio(): Boolean {
    try {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .build()

        // Abandon audio focus to stop playback
        val audioRequest = audioManager.requestAudioFocus(focusRequest)


        return audioRequest == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    } catch (e: Exception) {
        e.printStackTrace()
    } 
    return false
  }
}
