package com.ilkersevim.blocflutter

import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "com.example.flutter_bloc_app/native"
  private val showcaseChannelName = "com.example.flutter_bloc_app/native_showcase"
  private val telemetryChannelName =
    "com.example.flutter_bloc_app/native_showcase/telemetry"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory(
        "com.example.flutter_bloc_app/native_showcase_banner",
        NativeShowcaseBannerPlatformViewFactory(),
      )
    EventChannel(flutterEngine.dartExecutor.binaryMessenger, telemetryChannelName)
      .setStreamHandler(NativeShowcaseTelemetryStreamHandler())
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, showcaseChannelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "invokeKotlin" -> {
            result.success(
              "Hello from Kotlin (API ${Build.VERSION.SDK_INT})",
            )
          }
          "triggerHaptic" -> {
            val performed = window.decorView.performHapticFeedback(
              android.view.HapticFeedbackConstants.KEYBOARD_TAP,
            )
            if (performed) {
              result.success("Haptic feedback performed")
            } else {
              result.success("Haptic feedback requested")
            }
          }
          "shareText" -> {
            val args = call.arguments as? Map<*, *>
            val text = args?.get("text") as? String
            if (text.isNullOrBlank()) {
              result.error(
                "invalid_args",
                "shareText requires a non-empty text argument.",
                null,
              )
            } else {
              val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
              }
              startActivity(Intent.createChooser(sendIntent, null))
              result.success("Share chooser launched")
            }
          }
          else -> result.notImplemented()
        }
      }
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
