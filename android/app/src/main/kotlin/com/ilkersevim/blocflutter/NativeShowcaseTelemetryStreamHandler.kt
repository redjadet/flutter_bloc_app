package com.ilkersevim.blocflutter

import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import kotlin.math.sin

class NativeShowcaseTelemetryStreamHandler : EventChannel.StreamHandler {
  private var workerThread: HandlerThread? = null
  private var workerHandler: Handler? = null
  private var mainHandler: Handler? = null
  private var eventSink: EventChannel.EventSink? = null
  private var sampleRunnable: Runnable? = null
  private var emitRunnable: Runnable? = null
  private var sessionGeneration = 0L

  private var sequence = 0
  private var sourceTick = 0
  private var windowSampleCount = 0
  private var windowSampleSum = 0.0
  private var windowDroppedCount = 0
  private var lastSampleValue = Double.NaN

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    stopSession()
    sessionGeneration += 1
    val generation = sessionGeneration
    eventSink = events
    mainHandler = Handler(Looper.getMainLooper())
    workerThread = HandlerThread("NativeShowcaseTelemetry").also { it.start() }
    workerHandler = Handler(workerThread!!.looper)

    val sampleIntervalMs = 1000.0 / SOURCE_RATE_HZ
    val emitIntervalMs = DELIVERY_WINDOW_MS.toLong()

    sampleRunnable = object : Runnable {
      override fun run() {
        if (generation != sessionGeneration) {
          return
        }

        val sampleValue = demoSampleValue(sourceTick)
        sourceTick += 1

        if (!lastSampleValue.isNaN() &&
          kotlin.math.abs(sampleValue - lastSampleValue) < SAMPLE_EPSILON
        ) {
          windowDroppedCount += 1
        } else {
          windowSampleCount += 1
          windowSampleSum += sampleValue
          lastSampleValue = sampleValue
        }

        workerHandler?.postDelayed(this, sampleIntervalMs.toLong().coerceAtLeast(1L))
      }
    }

    emitRunnable = object : Runnable {
      override fun run() {
        if (generation != sessionGeneration) {
          return
        }

        if (windowSampleCount > 0) {
          sequence += 1
          val averageValue = windowSampleSum / windowSampleCount
          val payload = mapOf(
            "sequence" to sequence,
            "sampleCount" to windowSampleCount,
            "averageValue" to averageValue,
            "sourceRateHz" to SOURCE_RATE_HZ,
            "deliveredRateHz" to DELIVERED_RATE_HZ,
            "droppedCount" to windowDroppedCount,
            "emittedAtMillis" to System.currentTimeMillis(),
          )
          mainHandler?.post {
            if (generation == sessionGeneration) {
              eventSink?.success(payload)
            }
          }
        }

        windowSampleCount = 0
        windowSampleSum = 0.0
        windowDroppedCount = 0

        workerHandler?.postDelayed(this, emitIntervalMs)
      }
    }

    workerHandler?.post(sampleRunnable!!)
    workerHandler?.postDelayed(emitRunnable!!, emitIntervalMs)
  }

  override fun onCancel(arguments: Any?) {
    stopSession()
  }

  private fun stopSession() {
    sessionGeneration += 1
    sampleRunnable?.let { workerHandler?.removeCallbacks(it) }
    emitRunnable?.let { workerHandler?.removeCallbacks(it) }
    sampleRunnable = null
    emitRunnable = null
    workerHandler = null
    workerThread?.quitSafely()
    workerThread = null
    mainHandler = null
    eventSink = null
    sequence = 0
    sourceTick = 0
    windowSampleCount = 0
    windowSampleSum = 0.0
    windowDroppedCount = 0
    lastSampleValue = Double.NaN
  }

  private fun demoSampleValue(tick: Int): Double {
    val wave = sin(tick * 0.15) * 50.0
    val counter = (tick % 10).toDouble()
    return wave + counter
  }

  companion object {
    private const val SOURCE_RATE_HZ = 60
    private const val DELIVERED_RATE_HZ = 4
    private const val DELIVERY_WINDOW_MS = 250
    private const val SAMPLE_EPSILON = 0.01
  }
}
