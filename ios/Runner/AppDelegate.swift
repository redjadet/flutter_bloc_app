import Flutter
import GoogleMaps
import UIKit
import Firebase
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.flutter_bloc_app/native"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
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
    GeneratedPluginRegistrant.register(with: self)

    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    } else {
      #if DEBUG
        NSLog("ℹ️ FirebaseApp already configured; skipping duplicate configure call.")
      #endif
    }

    if let initialUrl = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: initialUrl)
    }

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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Handle deep links when app is in background or foreground
    AppLinks.shared.handleLink(url: url)
    return super.application(application, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let url = userActivity.webpageURL {
      AppLinks.shared.handleLink(url: url)
    }
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }

  // AppLinksPlugin registers via addApplicationDelegate; no manual forwarding needed.
}
