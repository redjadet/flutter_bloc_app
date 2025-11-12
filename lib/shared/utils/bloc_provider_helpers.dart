import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper utilities for creating BlocProviders with common patterns
class BlocProviderHelpers {
  BlocProviderHelpers._();

  /// Creates a BlocProvider with async initialization
  /// The initialization function is called with unawaited to avoid blocking
  static Widget withAsyncInit<T extends StateStreamableSource<Object?>>({
    required final T Function() create,
    required final Future<void> Function(T cubit) init,
    required final Widget child,
  }) => BlocProvider<T>(
    create: (_) {
      final cubit = create();
      unawaited(init(cubit));
      return cubit;
    },
    child: child,
  );
}
