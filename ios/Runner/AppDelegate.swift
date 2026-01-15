import Flutter
import GoogleMaps
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "com.example.flutter_bloc_app/native"
  private var hasConfiguredFirebase = false

  override func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Configure Firebase as early as possible, before didFinishLaunching
    configureFirebaseIfNeeded()
    return super.application(application, willFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ensure Firebase is configured (redundant guard, but safe)
    configureFirebaseIfNeeded()

    // App-level initialization (not engine-specific)
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      GMSServices.provideAPIKey(apiKey)
      #if DEBUG
        if apiKey == "YOUR_IOS_GOOGLE_MAPS_API_KEY" {
          NSLog(
            "⚠️ Google Maps API key placeholder detected. Replace the GMSApiKey value in Info.plist"
          )
        }
      #endif
    } else {
      NSLog(
        "⚠️ No Google Maps API key configured. The Google Maps sample page will remain disabled."
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Firebase should already be configured by this point, but guard ensures safety
    configureFirebaseIfNeeded()

    // Register plugins with the engine bridge
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Create method channels with the engine bridge messenger
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
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
      case "hasGoogleMapsApiKey":
        let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String
        let trimmed = key?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasKey = !trimmed.isEmpty && trimmed != "YOUR_IOS_GOOGLE_MAPS_API_KEY"
        result(hasKey)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func configureFirebaseIfNeeded() {
    if hasConfiguredFirebase {
      return
    }
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    hasConfiguredFirebase = true
  }

  // AppLinksPlugin registers via addApplicationDelegate and SceneDelegate handles scene-based deep links.
}

