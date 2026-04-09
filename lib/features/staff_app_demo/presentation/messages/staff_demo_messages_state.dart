import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';

enum StaffDemoMessagesStatus { initial, loading, ready, error }

class StaffDemoMessagesState extends Equatable {
  const StaffDemoMessagesState({
    this.status = StaffDemoMessagesStatus.initial,
    this.items = const <StaffDemoInboxItem>[],
    this.errorMessage,
  });

  final StaffDemoMessagesStatus status;
  final List<StaffDemoInboxItem> items;
  final String? errorMessage;

  static const Object _unset = Object();

  StaffDemoMessagesState copyWith({
    final StaffDemoMessagesStatus? status,
    final List<StaffDemoInboxItem>? items,
    final Object? errorMessage = _unset,
  }) => StaffDemoMessagesState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  List<Object?> get props => <Object?>[status, items, errorMessage];
}
