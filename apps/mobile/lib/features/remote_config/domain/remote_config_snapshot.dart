import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_snapshot.freezed.dart';

/// Immutable snapshot of cached Remote Config values + metadata.
@freezed
abstract class RemoteConfigSnapshot with _$RemoteConfigSnapshot {
  factory RemoteConfigSnapshot({
    required Map<String, dynamic> values,
    DateTime? lastFetchedAt,
    String? templateVersion,
    String? dataSource,
    DateTime? lastSyncedAt,
  }) = _RemoteConfigSnapshot;

  const RemoteConfigSnapshot._();

  /// Convenience empty snapshot used when cache is missing.
  static final RemoteConfigSnapshot empty = RemoteConfigSnapshot(
    values: const <String, dynamic>{},
  );

  bool get hasValues => values.isNotEmpty;

  T? getValue<T>(String key) {
    final dynamic raw = values[key];
    if (raw is T) {
      return raw;
    }
    return null;
  }
}
