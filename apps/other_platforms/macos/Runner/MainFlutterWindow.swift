import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let showcaseChannel = FlutterMethodChannel(
      name: "com.example.flutter_bloc_app/native_showcase",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    showcaseChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "invokeSwift":
        result(NativeShowcaseBridge.greeting())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // macOS FlutterMacOS does not implement makeBackgroundTaskQueue on the
    // engine messenger. FlutterBinaryMessengerRelay still exposes the selector
    // and forwards to parent, so `if let messenger.makeBackgroundTaskQueue`
    // then calling it aborts with doesNotRecognizeSelector (SIGABRT before
    // Dart VM connects). Use the main-queue EventChannel path instead.
    let telemetryChannel = FlutterEventChannel(
      name: "com.example.flutter_bloc_app/native_showcase/telemetry",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    telemetryChannel.setStreamHandler(NativeShowcaseTelemetryStreamHandler())

    super.awakeFromNib()
  }
}
