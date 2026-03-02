/// Permission state for FCM / notification access (e.g. from requestPermission).
enum FcmPermissionState {
  /// Not yet requested or unknown.
  notDetermined,

  /// User granted permission.
  authorized,

  /// User denied permission.
  denied,

  /// Provisional (e.g. iOS) — user can refine later.
  provisional,
}
