import Flutter
import Foundation

final class NativeShowcaseTelemetryStreamHandler: NSObject, FlutterStreamHandler {
  private let workerQueue = DispatchQueue(label: "com.example.flutter_bloc_app.telemetry.worker")
  private var emitTimer: DispatchSourceTimer?
  private var sampleTimer: DispatchSourceTimer?
  private var eventSink: FlutterEventSink?

  private var sequence = 0
  private var sourceTick = 0
  private var windowSampleCount = 0
  private var windowSampleSum = 0.0
  private var windowDroppedCount = 0
  private var lastSampleValue = Double.nan

  private let sourceRateHz = 60
  private let deliveredRateHz = 4
  private let deliveryWindowMs = 250
  private let sampleEpsilon = 0.01

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    startWorkers()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopWorkers()
    eventSink = nil
    resetAggregation()
    return nil
  }

  private func startWorkers() {
    let sampleInterval = DispatchTimeInterval.nanoseconds(Int(1_000_000_000 / sourceRateHz))
    let emitInterval = DispatchTimeInterval.milliseconds(deliveryWindowMs)

    let sampleTimer = DispatchSource.makeTimerSource(queue: workerQueue)
    sampleTimer.schedule(deadline: .now(), repeating: sampleInterval)
    sampleTimer.setEventHandler { [weak self] in
      self?.collectSample()
    }
    sampleTimer.resume()
    self.sampleTimer = sampleTimer

    let emitTimer = DispatchSource.makeTimerSource(queue: workerQueue)
    emitTimer.schedule(deadline: .now() + emitInterval, repeating: emitInterval)
    emitTimer.setEventHandler { [weak self] in
      self?.emitAggregate()
    }
    emitTimer.resume()
    self.emitTimer = emitTimer
  }

  private func stopWorkers() {
    sampleTimer?.cancel()
    sampleTimer = nil
    emitTimer?.cancel()
    emitTimer = nil
  }

  private func collectSample() {
    let sampleValue = demoSampleValue(sourceTick)
    sourceTick += 1

    if !lastSampleValue.isNaN && abs(sampleValue - lastSampleValue) < sampleEpsilon {
      windowDroppedCount += 1
    } else {
      windowSampleCount += 1
      windowSampleSum += sampleValue
      lastSampleValue = sampleValue
    }
  }

  private func emitAggregate() {
    guard windowSampleCount > 0 else {
      windowDroppedCount = 0
      return
    }

    sequence += 1
    let averageValue = windowSampleSum / Double(windowSampleCount)
    let payload: [String: Any] = [
      "sequence": sequence,
      "sampleCount": windowSampleCount,
      "averageValue": averageValue,
      "sourceRateHz": sourceRateHz,
      "deliveredRateHz": deliveredRateHz,
      "droppedCount": windowDroppedCount,
      "emittedAtMillis": Int(Date().timeIntervalSince1970 * 1000),
    ]

    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(payload)
    }

    windowSampleCount = 0
    windowSampleSum = 0
    windowDroppedCount = 0
  }

  private func resetAggregation() {
    sequence = 0
    sourceTick = 0
    windowSampleCount = 0
    windowSampleSum = 0
    windowDroppedCount = 0
    lastSampleValue = .nan
  }

  private func demoSampleValue(_ tick: Int) -> Double {
    let wave = sin(Double(tick) * 0.15) * 50.0
    let counter = Double(tick % 10)
    return wave + counter
  }
}
