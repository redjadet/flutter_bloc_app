import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

part 'scapes_state.freezed.dart';

enum ScapesViewMode { grid, list }

@freezed
sealed class ScapesState with _$ScapesState {
  const factory ScapesState.initial() = ScapesInitial;

  const factory ScapesState.loading() = ScapesLoading;

  const factory ScapesState.ready({
    required List<Scape> scapes,
    @Default(ScapesViewMode.grid) ScapesViewMode viewMode,
  }) = ScapesReady;

  const factory ScapesState.error(AppError error) = ScapesError;

  const ScapesState._();

  List<Scape> get scapes => maybeWhen(
    ready: (scapes, _) => scapes,
    orElse: () => const <Scape>[],
  );

  ScapesViewMode get viewMode => maybeWhen(
    ready: (_, viewMode) => viewMode,
    orElse: () => ScapesViewMode.grid,
  );

  bool get isLoading => this is ScapesLoading;

  AppError? get lastError => maybeWhen(
    error: (error) => error,
    orElse: () => null,
  );

  String? get errorMessage => lastError?.message;

  bool get hasError => this is ScapesError;
}
