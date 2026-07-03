import 'package:core/core.dart';

/// Holds a debounce timer for a pending setValue sync operation.
class IotDemoPendingSetValue {
  IotDemoPendingSetValue({required this.timer});
  final TimerDisposable timer;
}
