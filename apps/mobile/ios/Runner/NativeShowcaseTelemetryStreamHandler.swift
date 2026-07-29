import Flutter
import Foundation

final class NativeShowcaseTelemetryStreamHandler: NSObject, FlutterStreamHandler {
  private let workerQueue = DispatchQueue(label: "com.example.flutter_bloc_app.telemetry.worker")
  private var emitTimer: DispatchSourceTimer?
  private var sampleTimer: DispatchSourceTimer?
  private var eventSink: FlutterEventSink?
  private var sessionGeneration: UInt64 = 0
  private var accumulator: NativeShowcaseTelemetryAccumulator?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard let parsed = NativeShowcaseTelemetryAccumulator.parseConfig(arguments) else {
      return FlutterError(
        code: "invalid_config",
        message: "Telemetry stream config must be schemaVersion=1 render mode with valid fields.",
        details: nil
      )
    }

    workerQueue.async { [weak self] in
      guard let self else { return }
      self.tearDownSessionOnWorkerQueue()
      self.sessionGeneration &+= 1
      let generation = self.sessionGeneration
      let localAccumulator = NativeShowcaseTelemetryAccumulator(
        sessionId: parsed.sessionId,
        aggregation: parsed.aggregation,
        deliveredRateHz: parsed.deliveredRateHz
      )
      localAccumulator.resetSession()
      self.accumulator = localAccumulator
      DispatchQueue.main.async { [weak self] in
        guard let self, generation == self.sessionGeneration else { return }
        self.eventSink = events
      }
      self.startWorkers(generation: generation, config: parsed, accumulator: localAccumulator)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    workerQueue.async { [weak self] in
      guard let self else { return }
      self.sessionGeneration &+= 1
      self.tearDownSessionOnWorkerQueue()
      self.accumulator?.resetSession()
      self.accumulator = nil
      DispatchQueue.main.async { [weak self] in
        self?.eventSink = nil
      }
    }
    return nil
  }

  private func startWorkers(
    generation: UInt64,
    config: NativeShowcaseTelemetryAccumulator.ParsedConfig,
    accumulator: NativeShowcaseTelemetryAccumulator
  ) {
    let sampleInterval = DispatchTimeInterval.nanoseconds(
      Int(1_000_000_000 / NativeShowcaseTelemetryAccumulator.sourceRateHz)
    )
    let emitInterval = DispatchTimeInterval.milliseconds(config.deliveryWindowMs)

    let sampleTimer = DispatchSource.makeTimerSource(queue: workerQueue)
    sampleTimer.schedule(deadline: .now(), repeating: sampleInterval)
    sampleTimer.setEventHandler { [weak self] in
      guard let self, generation == self.sessionGeneration else { return }
      accumulator.ingest(sampleValue: accumulator.demoSampleValue())
    }
    sampleTimer.resume()
    self.sampleTimer = sampleTimer

    let emitTimer = DispatchSource.makeTimerSource(queue: workerQueue)
    emitTimer.schedule(deadline: .now() + emitInterval, repeating: emitInterval)
    emitTimer.setEventHandler { [weak self] in
      guard let self, generation == self.sessionGeneration else { return }
      guard let payload = accumulator.emitIfReady() else { return }
      DispatchQueue.main.async { [weak self] in
        guard let self, generation == self.sessionGeneration else { return }
        self.eventSink?(payload)
      }
    }
    emitTimer.resume()
    self.emitTimer = emitTimer
  }

  private func tearDownSessionOnWorkerQueue() {
    sampleTimer?.cancel()
    sampleTimer = nil
    emitTimer?.cancel()
    emitTimer = nil
  }
}
