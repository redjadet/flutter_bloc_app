import 'package:flutter_bloc_app/core/domain/failure.dart';

Failure unsupportedPlatformFailure() =>
    const PlatformFailure(PlatformFailureReason.unavailable);

Failure bluetoothDisabledFailure() =>
    const ValidationFailure('bluetooth_disabled');

Failure characteristicNotFoundFailure() =>
    const ValidationFailure('characteristic_not_found');
