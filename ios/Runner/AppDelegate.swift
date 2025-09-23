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

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

      channel.setMethodCallHandler { [weak self] call, result in
        guard self != nil else {
          result(FlutterMethodNotImplemented)
          return
        }
        switch call.method {
        case "getPlatformInfo":
          let device = UIDevice.current
          let info: [String: Any?] = [
            "platform": "ios",
            "version": device.systemVersion,
            "manufacturer": "Apple",
            "model": device.model
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
