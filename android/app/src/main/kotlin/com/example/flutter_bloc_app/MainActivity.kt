package com.example.flutter_bloc_app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.example.flutter_bloc_app/native"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getPlatformInfo" -> {
            val info = mapOf(
              "platform" to "android",
              "version" to (Build.VERSION.RELEASE ?: "unknown"),
              "manufacturer" to Build.MANUFACTURER,
              "model" to Build.MODEL,
            )
            result.success(info)
          }
          else -> result.notImplemented()
        }
      }
  }
}
