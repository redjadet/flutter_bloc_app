import 'dart:async';

import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:genui/genui.dart' as genui;

/// Domain interface for GenUI agent operations.
/// Keeps all types Flutter-free for clean architecture.
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

  /// Opaque handle to pass into GenUiSurface widget.
  /// Keep the type consistent with GenUiSurface.host (verify SDK type).
  genui.GenUiManager? get hostHandle;

  /// Disposes all resources.
  Future<void> dispose();
}
