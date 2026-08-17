import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genui/genui.dart' as genui;

part 'genui_demo_state.freezed.dart';

@freezed
class GenUiDemoState with _$GenUiDemoState {
  const factory GenUiDemoState.initial() = _Initial;

  const factory GenUiDemoState.loading({
    @Default(<String>[]) List<String> surfaceIds,
    @Default(false) bool isSending,
    genui.A2uiMessageProcessor? hostHandle,
  }) = _Loading;

  const factory GenUiDemoState.ready({
    required List<String> surfaceIds,
    required genui.A2uiMessageProcessor? hostHandle,
    @Default(false) bool isSending,
  }) = _Ready;

  const factory GenUiDemoState.error({
    required String message,
    @Default(<String>[]) List<String> surfaceIds,
    genui.A2uiMessageProcessor? hostHandle,
    @Default(false) bool isSending,
  }) = _Error;
}
