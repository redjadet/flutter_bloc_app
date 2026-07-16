//
//  AppDelegate.swift
//
//  This AppDelegate handles:
//  - Firebase initialization and App Check setup with thread-safe configuration
//  - Google Maps API key provisioning with validation and detailed logging
//  - Flutter engine integration and plugin registration
//  - Native platform method channel for exposing device and API key info to Flutter
//

import Flutter
import GoogleMaps
import UIKit
import Firebase
import FirebaseAppCheck

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "com.example.flutter_bloc_app/native"
  private let showcaseChannelName = "com.example.flutter_bloc_app/native_showcase"
  private let telemetryChannelName =
    "com.example.flutter_bloc_app/native_showcase/telemetry"
  private let securityShowcaseChannelName =
    "com.example.flutter_bloc_app/native_security_showcase"
  private let securityShowcaseHandler = NativeSecurityShowcaseHandler()
  private var hasConfiguredFirebase = false
  private let firebaseConfigQueue = DispatchQueue(label: "com.example.flutter_bloc_app.firebaseConfigQueue")

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
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if trimmedKey.isEmpty {
        NSLog(
          "⚠️ No Google Maps API key configured in Info.plist under GMSApiKey. " +
          "This will cause the Google Maps features to remain disabled."
        )
      } else if trimmedKey == "YOUR_IOS_GOOGLE_MAPS_API_KEY" {
        NSLog(
          "⚠️ Google Maps API key placeholder detected in Info.plist. " +
          "Replace the GMSApiKey value with your actual API key to enable map features."
        )
      } else {
        GMSServices.provideAPIKey(trimmedKey)
      }
    } else {
      NSLog(
        "⚠️ Missing GMSApiKey entry in Info.plist. " +
        "Google Maps features will remain disabled."
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

    let showcaseChannel = FlutterMethodChannel(
      name: showcaseChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    showcaseChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.method {
      case "invokeSwift":
        result(NativeShowcaseBridge.greeting())
      case "triggerHaptic":
        DispatchQueue.main.async {
          let generator = UIImpactFeedbackGenerator(style: .medium)
          generator.prepare()
          generator.impactOccurred()
          result("Haptic impact triggered")
        }
      case "shareText":
        DispatchQueue.main.async {
          self.presentShareSheet(call: call, result: result)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let bannerFactory = NativeShowcaseBannerPlatformViewFactory(
      messenger: engineBridge.applicationRegistrar.messenger()
    )
    engineBridge.applicationRegistrar.register(
      bannerFactory,
      withId: "com.example.flutter_bloc_app/native_showcase_banner"
    )

    let telemetryChannel = FlutterEventChannel(
      name: telemetryChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    telemetryChannel.setStreamHandler(NativeShowcaseTelemetryStreamHandler())

    let securityShowcaseChannel = FlutterMethodChannel(
      name: securityShowcaseChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    securityShowcaseChannel.setMethodCallHandler { [weak self] call, result in
      self?.securityShowcaseHandler.handle(call, result: result)
    }

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
        NSLog("⚠️ FlutterMethodChannel: Unknown method '\(call.method)' called on '\(self?.channelName ?? "")'")
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func presentShareSheet(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard
      let args = call.arguments as? [String: Any],
      let text = args["text"] as? String,
      !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "invalid_args",
          message: "shareText requires a non-empty text argument.",
          details: nil
        )
      )
      return
    }

    guard let root = window?.rootViewController ?? UIApplication.shared
      .connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?
      .rootViewController
    else {
      result(
        FlutterError(
          code: "no_presenter",
          message: "No root view controller available for share sheet.",
          details: nil
        )
      )
      return
    }

    var presenter = root
    while let presented = presenter.presentedViewController {
      presenter = presented
    }
    if presenter.isBeingPresented || presenter.isBeingDismissed {
      result(
        FlutterError(
          code: "already_presenting",
          message: "A view controller is already presenting.",
          details: nil
        )
      )
      return
    }
    let activity = UIActivityViewController(
      activityItems: [text],
      applicationActivities: nil
    )
    if let popover = activity.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(
        x: presenter.view.bounds.midX,
        y: presenter.view.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }
    presenter.present(activity, animated: true) {
      result("Share sheet presented")
    }
  }

  private func hasValidGoogleServiceInfoPlist() -> Bool {
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
          let apiKey = plist["API_KEY"] as? String
    else {
      return false
    }
    let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    return !trimmedKey.isEmpty && trimmedKey != "YOUR_IOS_API_KEY"
  }

  private func configureFirebaseIfNeeded() {
    firebaseConfigQueue.sync {
      if hasConfiguredFirebase {
        return
      }
      guard hasValidGoogleServiceInfoPlist() else {
        NSLog(
          "Skipping FirebaseApp.configure(): GoogleService-Info.plist is missing or uses placeholder API_KEY. " +
          "Dart bootstrap or integration mocks will handle Firebase when needed."
        )
        hasConfiguredFirebase = true
        return
      }
      if FirebaseApp.app() == nil {
#if DEBUG
        // iOS Simulator doesn't support DeviceCheck/AppAttest. Use the App Check
        // Debug provider so Firebase requests (e.g. Cloud Functions) can succeed
        // when App Check is enforced.
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
#endif
        FirebaseApp.configure()
      } else {
        NSLog("⚠️ Firebase already configured before AppDelegate initialization")
      }
      hasConfiguredFirebase = true
    }
  }

  // AppLinksPlugin registers via addApplicationDelegate and SceneDelegate handles scene-based deep links.
}
