import Cocoa
import FlutterMacOS
import XCTest

@testable import flutter_bloc_app

class RunnerTests: XCTestCase {

  func testNativeShowcaseTelemetryConfigRejectsFractionalIntegerFields() {
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

  func testNativeShowcaseTelemetryConfigRejectsBlankSessionId() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "  ",
    ]

    XCTAssertNil(NativeShowcaseTelemetryAccumulator.parseConfig(args))
  }

  func testNativeShowcaseTelemetryConfigTrimsSessionId() {
    let args: [String: Any] = [
      "schemaVersion": 1,
      "mode": "render",
      "maxDeliveryHz": 4,
      "aggregation": "mean",
      "sessionId": "  s1  ",
    ]

    XCTAssertEqual(NativeShowcaseTelemetryAccumulator.parseConfig(args)?.sessionId, "s1")
  }

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

}
