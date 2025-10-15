package com.example.flutter_bloc_app

import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.content.pm.PackageManager
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
              "batteryLevel" to getBatteryLevel(),
            )
            result.success(info)
          }
          "hasGoogleMapsApiKey" -> {
            val hasKey = try {
              val appInfo = packageManager.getApplicationInfo(
                packageName,
                PackageManager.GET_META_DATA,
              )
              val metaValue = appInfo.metaData?.getString("com.google.android.geo.API_KEY")
              val trimmed = metaValue?.trim().orEmpty()
              trimmed.isNotEmpty() && trimmed != "YOUR_ANDROID_GOOGLE_MAPS_API_KEY"
            } catch (exception: Exception) {
              false
            }
            result.success(hasKey)
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun getBatteryLevel(): Int? {
    val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager?
    val level = batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    if (level != null && level >= 0) {
      return level
    }
    val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    return intent?.let {
      val rawLevel = it.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
      val scale = it.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
      if (rawLevel >= 0 && scale > 0) {
        (rawLevel * 100) / scale
      } else {
        null
      }
    }
  }
}
