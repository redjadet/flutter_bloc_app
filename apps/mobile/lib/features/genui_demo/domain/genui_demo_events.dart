import 'package:freezed_annotation/freezed_annotation.dart';

part 'genui_demo_events.freezed.dart';

@freezed
sealed class GenUiSurfaceEvent with _$GenUiSurfaceEvent {
  const new _();

  const factory added({required String surfaceId}) = GenUiSurfaceAdded;

  const factory removed({required String surfaceId}) = GenUiSurfaceRemoved;
}
