import Foundation

/// Host-owned pre-bridge telemetry policy shared by iOS/macOS handlers.
final class NativeShowcaseTelemetryAccumulator {
  enum Aggregation {
    case mean
    case latest
  }

  struct ParsedConfig {
    let sessionId: String
    let aggregation: Aggregation
    let deliveredRateHz: Int

    var deliveryWindowMs: Int {
      max(1, Int((1000.0 / Double(deliveredRateHz)).rounded(.down)))
    }
  }

  static let schemaVersion = 1
  static let sourceRateHz = 60
  static let sampleEpsilon = 0.01
  static let minDeliveryHz = 4
  static let maxDeliveryHz = 15

  private let sessionId: String
  private let aggregation: Aggregation
  private let deliveredRateHz: Int
  private let nowMillis: () -> Int64

  private var bridgeEventSequence = 0
  private var sourceTick = 0
  private var windowStartedAtMillis: Int64
  private var sourceReceivedCount = 0
  private var acceptedCount = 0
  private var droppedBeforeBridgeCount = 0
  private var windowSampleSum = 0.0
  private var lastAcceptedValue = Double.nan
  private var latestAcceptedValue = Double.nan

  init(
    sessionId: String,
    aggregation: Aggregation,
    deliveredRateHz: Int,
    nowMillis: @escaping () -> Int64 = {
      Int64(Date().timeIntervalSince1970 * 1000)
    }
  ) {
    self.sessionId = sessionId
    self.aggregation = aggregation
    self.deliveredRateHz = deliveredRateHz
    self.nowMillis = nowMillis
    self.windowStartedAtMillis = nowMillis()
  }

  static func parseConfig(_ arguments: Any?) -> ParsedConfig? {
    guard let map = arguments as? [AnyHashable: Any] else { return nil }
    guard let schema = intValue(map["schemaVersion"]),
          schema == schemaVersion else { return nil }
    guard let mode = map["mode"] as? String, mode == "render" else { return nil }
    guard let rawHz = intValue(map["maxDeliveryHz"]) else { return nil }
    let deliveryHz = min(max(rawHz, minDeliveryHz), maxDeliveryHz)
    guard let aggregationRaw = map["aggregation"] as? String else { return nil }
    let aggregation: Aggregation
    switch aggregationRaw {
    case "mean":
      aggregation = .mean
    case "latest":
      aggregation = .latest
    default:
      return nil
    }
    guard let sessionId = map["sessionId"] as? String, !sessionId.isEmpty else {
      return nil
    }
    return ParsedConfig(
      sessionId: sessionId,
      aggregation: aggregation,
      deliveredRateHz: deliveryHz
    )
  }

  func ingest(sampleValue: Double) {
    sourceReceivedCount += 1
    sourceTick += 1

    if !lastAcceptedValue.isNaN,
       abs(sampleValue - lastAcceptedValue) < Self.sampleEpsilon {
      droppedBeforeBridgeCount += 1
      return
    }

    switch aggregation {
    case .mean:
      acceptedCount += 1
      windowSampleSum += sampleValue
      lastAcceptedValue = sampleValue
      latestAcceptedValue = sampleValue
    case .latest:
      if acceptedCount > 0 {
        droppedBeforeBridgeCount += 1
      }
      acceptedCount = 1
      windowSampleSum = sampleValue
      lastAcceptedValue = sampleValue
      latestAcceptedValue = sampleValue
    }
  }

  func emitIfReady() -> [String: Any]? {
    let emittedAt = nowMillis()
    if acceptedCount <= 0 {
      let carriedDrops = droppedBeforeBridgeCount
      let carriedSource = sourceReceivedCount
      openNewWindow(startedAtMillis: emittedAt)
      sourceReceivedCount = carriedSource
      droppedBeforeBridgeCount = carriedDrops
      return nil
    }

    bridgeEventSequence += 1
    let averageValue: Double
    switch aggregation {
    case .mean:
      averageValue = windowSampleSum / Double(acceptedCount)
    case .latest:
      averageValue = latestAcceptedValue
    }

    let payload: [String: Any] = [
      "schemaVersion": Self.schemaVersion,
      "sessionId": sessionId,
      "bridgeEventSequence": bridgeEventSequence,
      "acceptedCount": acceptedCount,
      "sourceReceivedCount": sourceReceivedCount,
      "averageValue": averageValue,
      "sourceRateHz": Self.sourceRateHz,
      "deliveredRateHz": deliveredRateHz,
      "droppedBeforeBridgeCount": droppedBeforeBridgeCount,
      "nativeWindowStartedAtMillis": windowStartedAtMillis,
      "nativeEmittedAtMillis": emittedAt,
    ]

    openNewWindow(startedAtMillis: emittedAt)
    return payload
  }

  func resetSession() {
    bridgeEventSequence = 0
    sourceTick = 0
    openNewWindow(startedAtMillis: nowMillis())
    lastAcceptedValue = .nan
    latestAcceptedValue = .nan
  }

  func demoSampleValue() -> Double {
    let wave = sin(Double(sourceTick) * 0.15) * 50.0
    let counter = Double(sourceTick % 10)
    return wave + counter
  }

  private func openNewWindow(startedAtMillis: Int64) {
    windowStartedAtMillis = startedAtMillis
    sourceReceivedCount = 0
    acceptedCount = 0
    droppedBeforeBridgeCount = 0
    windowSampleSum = 0
  }

  private static func intValue(_ any: Any?) -> Int? {
    if let value = any as? Int {
      return value
    }
    if let value = any as? NSNumber {
      return value.intValue
    }
    return nil
  }
}
