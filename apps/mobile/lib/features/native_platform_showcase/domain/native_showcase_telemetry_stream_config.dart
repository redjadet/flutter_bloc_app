import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_showcase_telemetry_stream_config.freezed.dart';

/// Delivery mode for native showcase telemetry.
///
/// Only [render] is implemented. Hosts reject [latencyCritical].
enum NativeShowcaseTelemetryMode {
  render,
  latencyCritical,
}

/// Native pre-bridge aggregation policy for a delivery window.
enum NativeShowcaseTelemetryAggregation {
  mean,
  latest,
}

/// Versioned listen arguments for the telemetry EventChannel.
@freezed
abstract class NativeShowcaseTelemetryStreamConfig
    with _$NativeShowcaseTelemetryStreamConfig {
  const factory NativeShowcaseTelemetryStreamConfig({
    required int schemaVersion,
    required NativeShowcaseTelemetryMode mode,
    required int maxDeliveryHz,
    required NativeShowcaseTelemetryAggregation aggregation,
    required String sessionId,
  }) = _NativeShowcaseTelemetryStreamConfig;

  const NativeShowcaseTelemetryStreamConfig._();

  /// Default render-mode contract used by the showcase Cubit.
  factory NativeShowcaseTelemetryStreamConfig.renderDefault({
    required String sessionId,
  }) {
    return NativeShowcaseTelemetryStreamConfig(
      schemaVersion: supportedSchemaVersion,
      mode: NativeShowcaseTelemetryMode.render,
      maxDeliveryHz: defaultMaxDeliveryHz,
      aggregation: NativeShowcaseTelemetryAggregation.mean,
      sessionId: sessionId,
    );
  }

  static const int supportedSchemaVersion = 1;
  static const int minMaxDeliveryHz = 4;
  static const int maxMaxDeliveryHz = 15;
  static const int defaultMaxDeliveryHz = 4;

  /// Clamp [maxDeliveryHz] into the host-supported render range.
  int get clampedMaxDeliveryHz {
    if (maxDeliveryHz < minMaxDeliveryHz) {
      return minMaxDeliveryHz;
    }
    if (maxDeliveryHz > maxMaxDeliveryHz) {
      return maxMaxDeliveryHz;
    }
    return maxDeliveryHz;
  }

  /// Compact map passed to `EventChannel.receiveBroadcastStream(arguments)`.
  Map<String, Object> toChannelArguments() {
    return <String, Object>{
      'schemaVersion': schemaVersion,
      'mode': switch (mode) {
        NativeShowcaseTelemetryMode.render => 'render',
        NativeShowcaseTelemetryMode.latencyCritical => 'latencyCritical',
      },
      'maxDeliveryHz': clampedMaxDeliveryHz,
      'aggregation': switch (aggregation) {
        NativeShowcaseTelemetryAggregation.mean => 'mean',
        NativeShowcaseTelemetryAggregation.latest => 'latest',
      },
      'sessionId': sessionId,
    };
  }
}
