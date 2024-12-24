package com.example.client

import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

// Singleton to hold our methodchannel
object GlobalChannel {
    lateinit var methodChannel: MethodChannel

    // Set up the MethodChannel when FlutterEngine is available
    fun setMethodChannel(flutterEngine: FlutterEngine, channel: String) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
    }
}