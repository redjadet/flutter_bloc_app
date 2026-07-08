import 'dart:convert';

/// Canonical key names for FCM `data` payloads that request an immediate sync.
///
/// This contract is intentionally small and stringly-typed to keep cross-platform
/// delivery simple (APNs/FCM/simulator `.apns` files).
///
/// Example `data` payload:
/// ```json
/// {
///   "sync_feature": "iot_demo",
///   "sync_resource_type": "device",
///   "sync_resource_id": "abc123"
/// }
/// ```
const String kFcmSyncFeatureKey = 'sync_feature';
const String kFcmSyncResourceTypeKey = 'sync_resource_type';
const String kFcmSyncResourceIdKey = 'sync_resource_id';

/// Parsed, structured view of the FCM sync-trigger payload.
class FcmSyncTriggerPayload {
  const FcmSyncTriggerPayload({
    this.feature,
    this.resourceType,
    this.resourceId,
  });

  /// Extracts the structured payload from an FCM `data` map.
  ///
  /// Unknown extra keys are ignored.
  factory FcmSyncTriggerPayload.fromData(final Map<String, String> data) {
    return FcmSyncTriggerPayload(
      feature: _normalized(data[kFcmSyncFeatureKey]),
      resourceType: _normalized(data[kFcmSyncResourceTypeKey]),
      resourceId: _normalized(data[kFcmSyncResourceIdKey]),
    );
  }

  final String? feature;
  final String? resourceType;
  final String? resourceId;

  bool get isEmpty =>
      (feature?.isEmpty ?? true) &&
      (resourceType?.isEmpty ?? true) &&
      (resourceId?.isEmpty ?? true);

  static String? _normalized(final String? value) {
    final String? v = value?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  /// Encodes this payload as a compact JSON string for telemetry/logging.
  ///
  /// This stays stable as we add more optional keys over time.
  String toHintString() {
    final Map<String, String> map = <String, String>{};
    final String? f = feature;
    final String? t = resourceType;
    final String? id = resourceId;
    if (f != null) map[kFcmSyncFeatureKey] = f;
    if (t != null) map[kFcmSyncResourceTypeKey] = t;
    if (id != null) map[kFcmSyncResourceIdKey] = id;
    return jsonEncode(map);
  }
}
