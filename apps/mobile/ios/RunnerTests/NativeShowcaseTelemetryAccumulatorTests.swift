import XCTest

@testable import Runner

final class NativeShowcaseTelemetryAccumulatorTests: XCTestCase {
  func testParseConfigRejectsLatencyCritical() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "latencyCritical",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "s1",
    ]
    XCTAssertNil(NativeShowcaseTelemetryAccumulator.parseConfig(args))
  }

  func testParseConfigClampsDeliveryHz() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 99,
      "aggregation": "latest",
      "sessionId": "s1",
    ]
    let parsed = NativeShowcaseTelemetryAccumulator.parseConfig(args)
    XCTAssertEqual(parsed?.deliveredRateHz, 15)
    XCTAssertEqual(parsed?.aggregation, .latest)
  }

  func testParseConfigRejectsFractionalIntegerFields() {
    let baseArgs: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "s1",
    ]

    var fractionalSchema = baseArgs
    fractionalSchema["schemaVersion"] = 1.5
    XCTAssertNil(NativeShowcaseTelemetryAccumulator.parseConfig(fractionalSchema))

    var fractionalDeliveryHz = baseArgs
    fractionalDeliveryHz["maxDeliveryHz"] = 4.5
    XCTAssertNil(NativeShowcaseTelemetryAccumulator.parseConfig(fractionalDeliveryHz))
  }

  func testParseConfigRejectsBlankSessionId() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "  ",
    ]

    XCTAssertNil(NativeShowcaseTelemetryAccumulator.parseConfig(args))
  }

  func testParseConfigTrimsSessionId() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "  s1  ",
    ]

    XCTAssertEqual(NativeShowcaseTelemetryAccumulator.parseConfig(args)?.sessionId, "s1")
  }

  func testMeanAggregationPayloadAndDropAccounting() {
    var clock: Int64 = 1_000
    let accumulator = NativeShowcaseTelemetryAccumulator(
      sessionId: "session-a",
      aggregation: .mean,
      deliveredRateHz: 4,
      nowMillis: { clock }
    )

    accumulator.ingest(sampleValue: 10)
    accumulator.ingest(sampleValue: 10.001) // near-duplicate drop
    accumulator.ingest(sampleValue: 20)
    clock = 1_250

    let payload = accumulator.emitIfReady()
    XCTAssertNotNil(payload)
    XCTAssertEqual(payload?["schemaVersion"] as? Int, 1)
    XCTAssertEqual(payload?["sessionId"] as? String, "session-a")
    XCTAssertEqual(payload?["bridgeEventSequence"] as? Int, 1)
    XCTAssertEqual(payload?["acceptedCount"] as? Int, 2)
    XCTAssertEqual(payload?["sourceReceivedCount"] as? Int, 3)
    XCTAssertEqual(payload?["droppedBeforeBridgeCount"] as? Int, 1)
    XCTAssertEqual(payload?["averageValue"] as? Double, 15)
    XCTAssertEqual(payload?["nativeWindowStartedAtMillis"] as? Int64, 1_000)
    XCTAssertEqual(payload?["nativeEmittedAtMillis"] as? Int64, 1_250)
  }

  func testLatestAggregationReplacesPriorAccepted() {
    let accumulator = NativeShowcaseTelemetryAccumulator(
      sessionId: "session-b",
      aggregation: .latest,
      deliveredRateHz: 4
    )
    accumulator.ingest(sampleValue: 1)
    accumulator.ingest(sampleValue: 5)
    let payload = accumulator.emitIfReady()
    XCTAssertEqual(payload?["acceptedCount"] as? Int, 1)
    XCTAssertEqual(payload?["averageValue"] as? Double, 5)
    XCTAssertEqual(payload?["droppedBeforeBridgeCount"] as? Int, 1)
  }

  func testAllDuplicateWindowCarriesDropsIntoNextEmit() {
    var clock: Int64 = 0
    let accumulator = NativeShowcaseTelemetryAccumulator(
      sessionId: "session-c",
      aggregation: .mean,
      deliveredRateHz: 4,
      nowMillis: { clock }
    )
    accumulator.ingest(sampleValue: 1)
    _ = accumulator.emitIfReady()

    accumulator.ingest(sampleValue: 1.0001)
    accumulator.ingest(sampleValue: 1.0002)
    clock = 500
    XCTAssertNil(accumulator.emitIfReady())

    accumulator.ingest(sampleValue: 9)
    clock = 750
    let payload = accumulator.emitIfReady()
    XCTAssertEqual(payload?["droppedBeforeBridgeCount"] as? Int, 2)
    XCTAssertEqual(payload?["acceptedCount"] as? Int, 1)
    XCTAssertEqual(payload?["sourceReceivedCount"] as? Int, 3)
  }
}
