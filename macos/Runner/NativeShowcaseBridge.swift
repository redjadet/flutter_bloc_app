import Foundation

private let nativeShowcaseGreetingCString = strdup("Hello from Apple native FFI")

@_cdecl("native_showcase_greeting")
func native_showcase_greeting() -> UnsafePointer<CChar>? {
  guard let pointer = nativeShowcaseGreetingCString else {
    return nil
  }
  return UnsafePointer(pointer)
}

@_cdecl("native_showcase_add")
func native_showcase_add(_ left: Int32, _ right: Int32) -> Int32 {
  left + right
}

enum NativeShowcaseBridge {
  static func greeting() -> String {
    let version = ProcessInfo.processInfo.operatingSystemVersionString
    return "Hello from Swift (macOS \(version))"
  }
}
