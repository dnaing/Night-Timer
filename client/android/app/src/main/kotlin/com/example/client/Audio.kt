package com.example.client

import android.content.Context
import android.media.AudioFocusRequest
import android.media.AudioManager

object Audio {
    /**
     * Stops audio if possible and returns true if audio was successfully stopped.
     */
    fun stopAudio(context: Context): Boolean {
        try {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            
            // Create an AudioFocusRequest
            val focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .build()

            // Request audio focus
            val audioRequest = audioManager.requestAudioFocus(focusRequest)

            // Check if the focus was granted
            return audioRequest == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }
}