import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';

class const CarrierLineState({
  final bool isLoading = true,
  final List<CarrierInboxItem> inbox = const <CarrierInboxItem>[],
  final LineStatusSnapshot lineStatus = const LineStatusSnapshot(
    esim: LineLifecycleStatus.unknown,
    porting: LineLifecycleStatus.unknown,
    billing: LineLifecycleStatus.unknown,
  ),
  final CarrierConnectionStatus connection =
      CarrierConnectionStatus.disconnected,
  final String? connectionError,
  final String? errorMessage,
}) {
  factory initial() => const CarrierLineState();

  CarrierLineState copyWith({
    bool? isLoading,
    List<CarrierInboxItem>? inbox,
    LineStatusSnapshot? lineStatus,
    CarrierConnectionStatus? connection,
    String? connectionError,
    bool clearConnectionError = false,
    String? errorMessage,
    bool clearError = false,
  }) => CarrierLineState(
    isLoading: isLoading ?? this.isLoading,
    inbox: inbox ?? this.inbox,
    lineStatus: lineStatus ?? this.lineStatus,
    connection: connection ?? this.connection,
    connectionError: clearConnectionError
        ? null
        : (connectionError ?? this.connectionError),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
