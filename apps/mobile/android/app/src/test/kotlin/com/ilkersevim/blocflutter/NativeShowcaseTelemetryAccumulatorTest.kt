package com.ilkersevim.blocflutter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class NativeShowcaseTelemetryAccumulatorTest {
  @Test
  fun parseConfig_rejectsLatencyCritical() {
    val args =
      mapOf(
        "schemaVersion" to 1,
        "mode" to "latencyCritical",
        "maxDeliveryHz" to 4,
        "aggregation" to "mean",
        "sessionId" to "s1",
      )
    assertNull(NativeShowcaseTelemetryAccumulator.parseConfig(args))
  }

  @Test
  fun parseConfig_clampsDeliveryHz() {
    val args =
      mapOf(
        "schemaVersion" to 1,
        "mode" to "render",
        "maxDeliveryHz" to 99,
        "aggregation" to "latest",
        "sessionId" to "s1",
      )
    val parsed = NativeShowcaseTelemetryAccumulator.parseConfig(args)!!
    assertEquals(15, parsed.deliveredRateHz)
    assertEquals(NativeShowcaseTelemetryAccumulator.Aggregation.LATEST, parsed.aggregation)
  }

  @Test
  fun parseConfig_rejectsFractionalIntegerFields() {
    val baseArgs =
      mapOf(
        "schemaVersion" to 1,
        "mode" to "render",
        "maxDeliveryHz" to 4,
        "aggregation" to "mean",
        "sessionId" to "s1",
      )

    assertNull(
      NativeShowcaseTelemetryAccumulator.parseConfig(baseArgs + ("schemaVersion" to 1.5)),
    )
    assertNull(
      NativeShowcaseTelemetryAccumulator.parseConfig(baseArgs + ("maxDeliveryHz" to 4.5)),
    )
  }

  @Test
  fun parseConfig_rejectsBlankSessionId() {
    val args =
      mapOf(
        "schemaVersion" to 1,
        "mode" to "render",
        "maxDeliveryHz" to 4,
        "aggregation" to "mean",
        "sessionId" to "  ",
      )

    assertNull(NativeShowcaseTelemetryAccumulator.parseConfig(args))
  }

  @Test
  fun parseConfig_trimsSessionId() {
    val args =
      mapOf(
        "schemaVersion" to 1,
        "mode" to "render",
        "maxDeliveryHz" to 4,
        "aggregation" to "mean",
        "sessionId" to "  s1  ",
      )

    assertEquals("s1", NativeShowcaseTelemetryAccumulator.parseConfig(args)?.sessionId)
  }

  @Test
  fun meanAggregation_payloadAndDropAccounting() {
    var clock = 1_000L
    val accumulator =
      NativeShowcaseTelemetryAccumulator(
        sessionId = "session-a",
        aggregation = NativeShowcaseTelemetryAccumulator.Aggregation.MEAN,
        deliveredRateHz = 4,
        nowMillis = { clock },
      )

    accumulator.ingest(10.0)
    accumulator.ingest(10.001)
    accumulator.ingest(20.0)
    clock = 1_250L

    val payload = accumulator.emitIfReady()!!
    assertEquals(1, payload["schemaVersion"])
    assertEquals("session-a", payload["sessionId"])
    assertEquals(1, payload["bridgeEventSequence"])
    assertEquals(2, payload["acceptedCount"])
    assertEquals(3, payload["sourceReceivedCount"])
    assertEquals(1, payload["droppedBeforeBridgeCount"])
    assertEquals(15.0, payload["averageValue"] as Double, 0.0001)
    assertEquals(1_000L, payload["nativeWindowStartedAtMillis"])
    assertEquals(1_250L, payload["nativeEmittedAtMillis"])
  }

  @Test
  fun latestAggregation_replacesPriorAccepted() {
    val accumulator =
      NativeShowcaseTelemetryAccumulator(
        sessionId = "session-b",
        aggregation = NativeShowcaseTelemetryAccumulator.Aggregation.LATEST,
        deliveredRateHz = 4,
      )
    accumulator.ingest(1.0)
    accumulator.ingest(5.0)
    val payload = accumulator.emitIfReady()!!
    assertEquals(1, payload["acceptedCount"])
    assertEquals(5.0, payload["averageValue"] as Double, 0.0001)
    assertEquals(1, payload["droppedBeforeBridgeCount"])
  }

  @Test
  fun allDuplicateWindow_carriesDropsIntoNextEmit() {
    var clock = 0L
    val accumulator =
      NativeShowcaseTelemetryAccumulator(
        sessionId = "session-c",
        aggregation = NativeShowcaseTelemetryAccumulator.Aggregation.MEAN,
        deliveredRateHz = 4,
        nowMillis = { clock },
      )
    accumulator.ingest(1.0)
    accumulator.emitIfReady()

    accumulator.ingest(1.0001)
    accumulator.ingest(1.0002)
    clock = 500L
    assertNull(accumulator.emitIfReady())

    accumulator.ingest(9.0)
    clock = 750L
    val payload = accumulator.emitIfReady()!!
    assertEquals(2, payload["droppedBeforeBridgeCount"])
    assertEquals(1, payload["acceptedCount"])
    assertEquals(3, payload["sourceReceivedCount"])
  }
}
