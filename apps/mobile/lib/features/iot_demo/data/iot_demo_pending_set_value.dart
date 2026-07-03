import 'package:flutter_bloc_app/core/time/timer_service.dart';

/// Holds a debounce timer for a pending setValue sync operation.
class IotDemoPendingSetValue {
  IotDemoPendingSetValue({required this.timer});
  final TimerDisposable timer;
}
