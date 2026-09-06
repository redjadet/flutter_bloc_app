import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_error_code.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'iot_demo_state.freezed.dart';

/// State for the IoT demo page.
@freezed
abstract class IotDemoState with _$IotDemoState {
  const factory initial() = _IotDemoInitial;

  const factory loading() = _IotDemoLoading;

  const factory loaded(
    List<IotDevice> devices, {
    String? selectedDeviceId,
    @Default(IotDemoDeviceFilter.all) IotDemoDeviceFilter filter,
  }) = _IotDemoLoaded;

  const factory error({required IotDemoErrorCode code, String? detail}) =
      _IotDemoError;
}
