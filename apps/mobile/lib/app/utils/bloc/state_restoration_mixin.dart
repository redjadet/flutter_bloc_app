import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef StateRestorationOutcome<S> = ({
  S state,
  bool shouldPersist,
  bool holdSideEffects,
});

/// Standardizes state restoration flows across cubits.
mixin StateRestorationMixin<S> on Cubit<S> {
  /// Applies a restoration outcome safely, ensuring lifecycle guards and
  /// optional persistence.
  @protected
  Future<void> applyRestorationOutcome(
    StateRestorationOutcome<S> outcome, {
    FutureOr<void> Function(S state)? onPersist,
    void Function({required bool holdSideEffects})? onHoldChanged,
    void Function()? onHoldSideEffects,
    void Function(S state)? onAfterEmit,
    String logContext = 'StateRestorationMixin.applyRestorationOutcome',
  }) async {
    onHoldChanged?.call(holdSideEffects: outcome.holdSideEffects);
    if (outcome.holdSideEffects) {
      onHoldSideEffects?.call();
    }
    if (isClosed) {
      return;
    }

    emit(outcome.state);
    onAfterEmit?.call(outcome.state);

    if (outcome.shouldPersist && onPersist != null) {
      await onPersist(outcome.state);
    }
  }
}
