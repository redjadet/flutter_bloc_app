import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.flutter_bloc_app/native"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let registrar = registrar(forPlugin: "AppDelegateMethodChannel") {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: registrar.messenger()
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard self != nil else {
          result(FlutterMethodNotImplemented)
          return
        }
        switch call.method {
        case "getPlatformInfo":
          let device = UIDevice.current
          let previousMonitoring = device.isBatteryMonitoringEnabled
          device.isBatteryMonitoringEnabled = true
          let rawBattery = device.batteryLevel
          let batteryPercent = rawBattery >= 0 ? Int(rawBattery * 100) : nil
          device.isBatteryMonitoringEnabled = previousMonitoring
          let info: [String: Any?] = [
            "platform": "ios",
            "version": device.systemVersion,
            "manufacturer": "Apple",
            "model": device.model,
            "batteryLevel": batteryPercent
          ]
          result(info)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
