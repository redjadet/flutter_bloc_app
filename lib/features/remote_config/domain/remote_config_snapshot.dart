import 'package:equatable/equatable.dart';

/// Immutable snapshot of cached Remote Config values + metadata.
class RemoteConfigSnapshot extends Equatable {
  RemoteConfigSnapshot({
    required Map<String, dynamic> values,
    this.lastFetchedAt,
    this.templateVersion,
  }) : values = Map<String, dynamic>.unmodifiable(values);

  /// Convenience empty snapshot used when cache is missing.
  static final RemoteConfigSnapshot empty = RemoteConfigSnapshot(
    values: const <String, dynamic>{},
  );

  final Map<String, dynamic> values;
  final DateTime? lastFetchedAt;
  final String? templateVersion;

  bool get hasValues => values.isNotEmpty;

  T? getValue<T>(final String key) {
    final dynamic raw = values[key];
    if (raw is T) {
      return raw;
    }
    return null;
  }

  RemoteConfigSnapshot copyWith({
    Map<String, dynamic>? values,
    DateTime? lastFetchedAt,
    String? templateVersion,
  }) => RemoteConfigSnapshot(
    values: values ?? this.values,
    lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    templateVersion: templateVersion ?? this.templateVersion,
  );

  @override
  List<Object?> get props => <Object?>[values, lastFetchedAt, templateVersion];
}
