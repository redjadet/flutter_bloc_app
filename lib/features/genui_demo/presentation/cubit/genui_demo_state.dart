import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genui/genui.dart' as genui;

part 'genui_demo_state.freezed.dart';

@freezed
class GenUiDemoState with _$GenUiDemoState {
  const factory GenUiDemoState.initial() = _Initial;

  const factory GenUiDemoState.loading({
    @Default(<String>[]) final List<String> surfaceIds,
    @Default(false) final bool isSending,
    final genui.GenUiManager? hostHandle,
  }) = _Loading;

  const factory GenUiDemoState.ready({
    required final List<String> surfaceIds,
    required final genui.GenUiManager? hostHandle,
    @Default(false) final bool isSending,
  }) = _Ready;

  const factory GenUiDemoState.error({
    required final String message,
    @Default(<String>[]) final List<String> surfaceIds,
    final genui.GenUiManager? hostHandle,
    @Default(false) final bool isSending,
  }) = _Error;
}
