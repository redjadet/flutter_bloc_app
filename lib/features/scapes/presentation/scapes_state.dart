import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/shared/utils/app_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scapes_state.freezed.dart';

enum ScapesViewMode { grid, list }

@freezed
abstract class ScapesState with _$ScapesState {
  const factory ScapesState({
    @Default(<Scape>[]) final List<Scape> scapes,
    @Default(ScapesViewMode.grid) final ScapesViewMode viewMode,
    @Default(false) final bool isLoading,
    final AppError? lastError,
  }) = _ScapesState;

  const ScapesState._();

  String? get errorMessage => lastError?.message;

  bool get hasError => lastError != null;
}
