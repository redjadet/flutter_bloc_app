import 'package:freezed_annotation/freezed_annotation.dart';

part 'genui_demo_events.freezed.dart';

@freezed
sealed class GenUiSurfaceEvent with _$GenUiSurfaceEvent {
  const GenUiSurfaceEvent._();

  const factory GenUiSurfaceEvent.added({
    required final String surfaceId,
  }) = GenUiSurfaceAdded;

  const factory GenUiSurfaceEvent.removed({
    required final String surfaceId,
  }) = GenUiSurfaceRemoved;
}
