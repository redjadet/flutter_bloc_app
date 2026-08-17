import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_content_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_content_state.freezed.dart';

enum StaffDemoContentStatus { initial, loading, ready, error }

@freezed
abstract class StaffDemoContentState with _$StaffDemoContentState {
  const factory StaffDemoContentState({
    @Default(StaffDemoContentStatus.initial) StaffDemoContentStatus status,
    @Default(<StaffDemoContentItem>[]) List<StaffDemoContentItem> items,
    String? errorMessage,
  }) = _StaffDemoContentState;
}
