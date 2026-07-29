package com.ilkersevim.blocflutter

import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class NativeShowcaseTelemetryStreamHandler : EventChannel.StreamHandler {
  private var workerThread: HandlerThread? = null
  private var workerHandler: Handler? = null
  private var mainHandler: Handler? = null
  private var eventSink: EventChannel.EventSink? = null
  private var sampleRunnable: Runnable? = null
  private var emitRunnable: Runnable? = null
  private var sessionGeneration = 0L
  private var accumulator: NativeShowcaseTelemetryAccumulator? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    stopSession()

    val parsed = NativeShowcaseTelemetryAccumulator.parseConfig(arguments)
    if (parsed == null) {
      mainHandler = Handler(Looper.getMainLooper())
      mainHandler?.post {
        events?.error(
          "invalid_config",
          "Telemetry stream config must be schemaVersion=1 render mode with valid fields.",
          null,
        )
      }
      return
    }

    sessionGeneration += 1
    val generation = sessionGeneration
    val localAccumulator =
      NativeShowcaseTelemetryAccumulator(
        sessionId = parsed.sessionId,
        aggregation = parsed.aggregation,
        deliveredRateHz = parsed.deliveredRateHz,
      )
    accumulator = localAccumulator

    // Sink handoff must stay on the platform main thread even when onListen
    // runs on a background task queue.
    mainHandler = Handler(Looper.getMainLooper())
    mainHandler?.post {
      if (generation == sessionGeneration) {
        eventSink = events
      }
    }

    workerThread = HandlerThread("NativeShowcaseTelemetry").also { it.start() }
    workerHandler = Handler(workerThread!!.looper)

    val sampleIntervalMs =
      (1000.0 / NativeShowcaseTelemetryAccumulator.SOURCE_RATE_HZ)
        .toLong()
        .coerceAtLeast(1L)
    val emitIntervalMs = parsed.deliveryWindowMs

    sampleRunnable =
      object : Runnable {
        override fun run() {
          if (generation != sessionGeneration) {
            return
          }
          localAccumulator.ingest(localAccumulator.demoSampleValue())
          workerHandler?.postDelayed(this, sampleIntervalMs)
        }
      }

    emitRunnable =
      object : Runnable {
        override fun run() {
          if (generation != sessionGeneration) {
            return
          }
          val payload = localAccumulator.emitIfReady()
          if (payload != null) {
            mainHandler?.post {
              if (generation == sessionGeneration) {
                eventSink?.success(payload)
              }
            }
          }
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
    mainHandler?.post {
      eventSink = null
    }
    mainHandler = null
    accumulator?.resetSession()
    accumulator = null
  }
}
