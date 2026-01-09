import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scapes_state.freezed.dart';

enum ScapesViewMode { grid, list }

@freezed
abstract class ScapesState with _$ScapesState {
  const factory ScapesState({
    @Default(<Scape>[]) final List<Scape> scapes,
    @Default(ScapesViewMode.grid) final ScapesViewMode viewMode,
    @Default(false) final bool isLoading,
    final String? errorMessage,
  }) = _ScapesState;

  const ScapesState._();

  bool get hasError => errorMessage != null;
}
