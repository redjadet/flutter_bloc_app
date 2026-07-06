import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';

/// Orchestrates connect → discover without presentation imports.
class BleSessionCoordinator {
  BleSessionCoordinator({
    required this._repository,
    required this._platformGateway,
  });

  final BleRepository _repository;
  final BlePlatformGateway _platformGateway;

  String? _connectedDeviceId;

  String? get connectedDeviceId => _connectedDeviceId;

  Future<Result<void>> prepareSession() async {
    if (!_platformGateway.supportsRealBle) {
      return const Success<void>(null);
    }
    return _repository.ensureReady();
  }

  Future<Result<List<BleService>>> connectAndDiscover(
    final String deviceId,
  ) async {
    await _repository.stopScan();
    final Result<void> connectResult = await _repository.connect(deviceId);
    if (connectResult case FailureResult<void>()) {
      return FailureResult<List<BleService>>(connectResult.failure);
    }
    _connectedDeviceId = deviceId;
    final Result<List<BleService>> services = await _repository
        .discoverServices();
    if (services case FailureResult<List<BleService>>()) {
      return services;
    }
    return services;
  }

  Future<Result<void>> reconnect() async {
    final String? deviceId = _connectedDeviceId;
    if (deviceId == null) {
      return const FailureResult<void>(
        ValidationFailure('no_connected_device'),
      );
    }
    await _repository.disconnect();
    return connectAndDiscover(deviceId).then((final result) {
      if (result case FailureResult<List<BleService>>(:final failure)) {
        return FailureResult<void>(failure);
      }
      return const Success<void>(null);
    });
  }

  Future<void> teardown() async {
    await _repository.stopScan();
    await _repository.disconnect();
    _connectedDeviceId = null;
  }
}
