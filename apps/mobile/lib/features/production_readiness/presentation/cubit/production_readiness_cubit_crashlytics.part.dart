part of 'production_readiness_cubit.dart';

mixin _ProductionReadinessCubitCrashlytics on _ProductionReadinessCubitBase {
  Future<void> emitTestNonFatal() async {
    if (isClosed) {
      return;
    }
    if (state.lastNonFatalStatus ==
        ProductionReadinessNonFatalStatus.recording) {
      return;
    }

    emit(
      state.copyWith(
        lastNonFatalStatus: ProductionReadinessNonFatalStatus.recording,
      ),
    );

    final Future<void> Function(
      Object exception,
      StackTrace? stack, {
      required bool fatal,
      required String reason,
    })?
    sink = recordNonFatal;

    if (mode == ProductionReadinessMode.simulated || sink == null) {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          lastNonFatalStatus: ProductionReadinessNonFatalStatus.recordedLocal,
        ),
      );
      return;
    }

    try {
      await sink(
        StateError('production_readiness_test_nonfatal'),
        StackTrace.current,
        fatal: false,
        reason: 'production_readiness_test_nonfatal',
      );
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          lastNonFatalStatus:
              ProductionReadinessNonFatalStatus.recordedFirebase,
        ),
      );
    } on Object {
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          lastNonFatalStatus: ProductionReadinessNonFatalStatus.failed,
        ),
      );
    }
  }
}
