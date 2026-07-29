package com.ilkersevim.blocflutter

/**
 * Host-owned pre-bridge telemetry policy: sample ingest, epsilon de-dup,
 * mean/latest aggregation, cadence accounting, and schema-v1 payload maps.
 */
class NativeShowcaseTelemetryAccumulator(
  private val sessionId: String,
  private val aggregation: Aggregation,
  private val deliveredRateHz: Int,
  private val sourceRateHz: Int = SOURCE_RATE_HZ,
  private val sampleEpsilon: Double = SAMPLE_EPSILON,
  private val nowMillis: () -> Long = { System.currentTimeMillis() },
) {
  enum class Aggregation {
    MEAN,
    LATEST,
  }

  private var bridgeEventSequence = 0
  private var sourceTick = 0
  private var windowStartedAtMillis = nowMillis()
  private var sourceReceivedCount = 0
  private var acceptedCount = 0
  private var droppedBeforeBridgeCount = 0
  private var windowSampleSum = 0.0
  private var lastAcceptedValue = Double.NaN
  private var latestAcceptedValue = Double.NaN

  fun ingest(sampleValue: Double) {
    sourceReceivedCount += 1
    sourceTick += 1

    if (!lastAcceptedValue.isNaN() &&
      kotlin.math.abs(sampleValue - lastAcceptedValue) < sampleEpsilon
    ) {
      droppedBeforeBridgeCount += 1
      return
    }

    when (aggregation) {
      Aggregation.MEAN -> {
        acceptedCount += 1
        windowSampleSum += sampleValue
        lastAcceptedValue = sampleValue
        latestAcceptedValue = sampleValue
      }
      Aggregation.LATEST -> {
        if (acceptedCount > 0) {
          droppedBeforeBridgeCount += 1
        }
        acceptedCount = 1
        windowSampleSum = sampleValue
        lastAcceptedValue = sampleValue
        latestAcceptedValue = sampleValue
      }
    }
  }

  /**
   * Emits a schema-v1 payload when the window has at least one accepted sample,
   * otherwise returns null while still rolling the window (drops retained in
   * counters only for emitted windows; all-dup windows still reset after
   * accounting into the next open window start).
   *
   * For all-duplicate windows, [droppedBeforeBridgeCount] is preserved across
   * the reset into the next window so accounting is not lost silently.
   */
  fun emitIfReady(): Map<String, Any>? {
    val emittedAt = nowMillis()
    if (acceptedCount <= 0) {
      // Carry duplicate drops into the next window so they are not discarded.
      val carriedDrops = droppedBeforeBridgeCount
      val carriedSource = sourceReceivedCount
      openNewWindow(emittedAt)
      sourceReceivedCount = carriedSource
      droppedBeforeBridgeCount = carriedDrops
      return null
    }

    bridgeEventSequence += 1
    val averageValue =
      when (aggregation) {
        Aggregation.MEAN -> windowSampleSum / acceptedCount.toDouble()
        Aggregation.LATEST -> latestAcceptedValue
      }

    val payload =
      mapOf(
        "schemaVersion" to SCHEMA_VERSION,
        "sessionId" to sessionId,
        "bridgeEventSequence" to bridgeEventSequence,
        "acceptedCount" to acceptedCount,
        "sourceReceivedCount" to sourceReceivedCount,
        "averageValue" to averageValue,
        "sourceRateHz" to sourceRateHz,
        "deliveredRateHz" to deliveredRateHz,
        "droppedBeforeBridgeCount" to droppedBeforeBridgeCount,
        "nativeWindowStartedAtMillis" to windowStartedAtMillis,
        "nativeEmittedAtMillis" to emittedAt,
      )

    openNewWindow(emittedAt)
    return payload
  }

  fun resetSession() {
    bridgeEventSequence = 0
    sourceTick = 0
    openNewWindow(nowMillis())
    lastAcceptedValue = Double.NaN
    latestAcceptedValue = Double.NaN
  }

  fun demoSampleValue(): Double {
    val wave = kotlin.math.sin(sourceTick * 0.15) * 50.0
    val counter = (sourceTick % 10).toDouble()
    return wave + counter
  }

  private fun openNewWindow(startedAtMillis: Long) {
    windowStartedAtMillis = startedAtMillis
    sourceReceivedCount = 0
    acceptedCount = 0
    droppedBeforeBridgeCount = 0
    windowSampleSum = 0.0
  }

  companion object {
    const val SCHEMA_VERSION = 1
    const val SOURCE_RATE_HZ = 60
    const val SAMPLE_EPSILON = 0.01
    const val MIN_DELIVERY_HZ = 4
    const val MAX_DELIVERY_HZ = 15

    fun parseConfig(arguments: Any?): ParsedConfig? {
      val map = arguments as? Map<*, *> ?: return null
      val schemaVersion = (map["schemaVersion"] as? Number)?.toInt() ?: return null
      if (schemaVersion != SCHEMA_VERSION) {
        return null
      }
      val mode = map["mode"] as? String ?: return null
      if (mode != "render") {
        return null
      }
      val rawHz = (map["maxDeliveryHz"] as? Number)?.toInt() ?: return null
      val deliveryHz = rawHz.coerceIn(MIN_DELIVERY_HZ, MAX_DELIVERY_HZ)
      val aggregationRaw = map["aggregation"] as? String ?: return null
      val aggregation =
        when (aggregationRaw) {
          "mean" -> Aggregation.MEAN
          "latest" -> Aggregation.LATEST
          else -> return null
        }
      val sessionId = map["sessionId"] as? String ?: return null
      if (sessionId.isBlank()) {
        return null
      }
      return ParsedConfig(
        sessionId = sessionId,
        aggregation = aggregation,
        deliveredRateHz = deliveryHz,
      )
    }
  }

  data class ParsedConfig(
    val sessionId: String,
    val aggregation: Aggregation,
    val deliveredRateHz: Int,
  ) {
    val deliveryWindowMs: Long
      get() = (1000.0 / deliveredRateHz).toLong().coerceAtLeast(1L)
  }
}
