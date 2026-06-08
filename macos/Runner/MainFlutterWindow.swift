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

    super.awakeFromNib()
  }
}
