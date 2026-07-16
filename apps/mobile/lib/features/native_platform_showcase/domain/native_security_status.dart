enum NativeSecurityStatus { success, unavailable, denied, failed }

enum NativeSecurityKeyResidency {
  secureEnclave,
  androidKeystore,
  keychain,
  software,
  unknown,
}
