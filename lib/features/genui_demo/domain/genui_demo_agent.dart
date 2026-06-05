import 'dart:async';

import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';

/// Domain interface for GenUI agent operations.
abstract interface class GenUiDemoAgent {
  /// Initializes the agent and establishes connection.
  Future<void> initialize();

  /// Sends a text message to the agent.
  Future<void> sendMessage(final String text);

  /// Stream of surface lifecycle events (add/remove).
  Stream<GenUiSurfaceEvent> get surfaceEvents;

  /// Stream of text responses from the agent (optional, can be ignored).
  Stream<String> get textResponses;

  /// Stream of error messages.
  Stream<String> get errors;

  /// Opaque handle for GenUiSurface; presentation casts to SDK type.
  Object? get hostHandle;

  /// Disposes all resources.
  Future<void> dispose();
}
