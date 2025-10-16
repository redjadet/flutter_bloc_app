import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Suppress all logging during tests
  AppLogger.silenceGlobally();

  try {
    await testMain();
  } finally {
    // Restore logging
    AppLogger.restoreGlobalLogging();
  }
}
