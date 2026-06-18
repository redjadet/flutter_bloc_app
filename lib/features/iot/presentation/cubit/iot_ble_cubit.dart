import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/iot_ble_runtime_config.dart';
import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/core/domain/result.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_session_coordinator.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_adapter_status.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_log_entry.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/classic_bt_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_failure_mapper.dart';
import 'package:flutter_bloc_app/features/iot/presentation/cubit/iot_ble_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'iot_ble_cubit_connection.part.dart';
part 'iot_ble_cubit_gatt.part.dart';
part 'iot_ble_cubit_scan.part.dart';
part 'iot_ble_cubit_streams.part.dart';

class IotBleCubit extends IotBleCubitCore
    with
        IotBleCubitStreams,
        IotBleCubitScan,
        IotBleCubitConnection,
        IotBleCubitGatt {
  IotBleCubit({
    required super.mockRepository,
    required super.reactiveRepository,
    required super.classicRepository,
    required super.platformGateway,
    required super.runtimeConfig,
    required super.timerService,
  });
}

abstract class IotBleCubitCore extends Cubit<IotBleState>
    with CubitSubscriptionMixin<IotBleState> {
  IotBleCubitCore({
    required this._mockRepository,
    required this._reactiveRepository,
    required this._classicRepository,
    required final BlePlatformGateway platformGateway,
    required final IotBleRuntimeConfig runtimeConfig,
    required this._timerService,
  }) : _platformGateway = platformGateway,
       super(
         IotBleState(
           useMockBle:
               runtimeConfig.defaultMockMode ||
               !platformGateway.supportsRealBle,
           canToggleRealBle: platformGateway.supportsRealBle,
         ),
       );

  final BleRepository _mockRepository;
  final BleRepository _reactiveRepository;
  final ClassicBluetoothRepository _classicRepository;
  final BlePlatformGateway _platformGateway;
  final TimerService _timerService;
  BleSessionCoordinator? _sessionCoordinator;
  BleRepository? _sessionCoordinatorRepository;

  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin and stream bind helpers.
  StreamSubscription<BleAdapterStatus>? _adapterSubscription;
  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin and stream bind helpers.
  StreamSubscription<List<BleDiscoveredDevice>>? _scanSubscription;
  StreamSubscription<BleConnectionPhase>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  TimerDisposable? _scanTimeoutHandle;
  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin and stream bind helpers.
  StreamSubscription<List<ClassicBtDevice>>? _classicSubscription;
  StreamSubscription<ClassicBtMessage>? _classicMessageSubscription;

  BleRepository get activeRepository =>
      state.useMockBle ? _mockRepository : _reactiveRepository;

  ClassicBluetoothRepository get classicRepository => _classicRepository;

  TimerService get timerService => _timerService;

  void setScanTimeout(final Duration timeout) {
    emit(state.copyWith(scanTimeout: timeout));
  }

  void selectDevice(final String deviceId) {
    emit(state.copyWith(selectedDeviceId: deviceId));
  }

  void selectCharacteristic(final BleCharacteristicRef ref) {
    emit(
      state.copyWith(
        selectedCharacteristic: ref,
        lastReadValue: null,
        isSubscribed: false,
      ),
    );
    unawaited(_notifySubscription?.cancel());
    _notifySubscription = null;
  }

  void clearLogs() {
    emit(state.copyWith(logs: const <BleLogEntry>[]));
  }

  void appendLog(final BleLogKind kind, final String message) {
    if (isClosed) {
      return;
    }
    emit(
      state.appendLog(
        BleLogEntry(timestamp: DateTime.now(), kind: kind, message: message),
      ),
    );
  }

  void emitBleFailure(final IotBleErrorCode code, final Object? cause) {
    final String? detail = cause is Failure
        ? cause.toString()
        : cause?.toString();
    emit(
      state.copyWith(
        status: IotBleStatus.error,
        errorCode: code,
        errorDetail: detail,
      ),
    );
    appendLog(BleLogKind.error, '$code${detail == null ? '' : ': $detail'}');
  }

  BleSessionCoordinator get sessionCoordinator {
    final BleRepository repository = activeRepository;
    final BleSessionCoordinator? coordinator = _sessionCoordinator;
    if (coordinator != null && _sessionCoordinatorRepository == repository) {
      return coordinator;
    }
    final BleSessionCoordinator next = BleSessionCoordinator(
      repository: repository,
      platformGateway: _platformGateway,
    );
    _sessionCoordinator = next;
    _sessionCoordinatorRepository = repository;
    return next;
  }

  Future<void> cancelConnectionSubscription() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
  }

  Future<void> cancelNotifySubscription() async {
    await _notifySubscription?.cancel();
    _notifySubscription = null;
  }

  void cancelScanTimeout() {
    _scanTimeoutHandle?.dispose();
    _scanTimeoutHandle = null;
  }

  Future<void> cancelClassicMessageSubscription() async {
    await _classicMessageSubscription?.cancel();
    _classicMessageSubscription = null;
  }
}
