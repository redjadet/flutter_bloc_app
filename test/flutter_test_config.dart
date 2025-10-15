import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppLogger.silenceGlobally();
  await testMain();
  AppLogger.restoreGlobalLogging();
}
