import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_inbox_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_messages_state.freezed.dart';

enum StaffDemoMessagesStatus { initial, loading, ready, error }

@freezed
abstract class StaffDemoMessagesState with _$StaffDemoMessagesState {
  const factory StaffDemoMessagesState({
    @Default(StaffDemoMessagesStatus.initial)
    final StaffDemoMessagesStatus status,
    @Default(<StaffDemoInboxItem>[]) final List<StaffDemoInboxItem> items,
    final String? errorMessage,
  }) = _StaffDemoMessagesState;
}
