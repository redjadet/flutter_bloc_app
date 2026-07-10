import 'package:flutter_bloc_app/features/chat/data/chat_render_orchestration_diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('renderOrchestrationNotRunnableReason', () {
    test('returns FirebaseAuth_not_registered when auth is not registered', () {
      expect(
        renderOrchestrationNotRunnableReason(
          () => false,
          chatRenderDemoEnabledOverride: true,
          chatRenderDemoBaseUrlOverride: 'https://example.fastapicloud.dev',
        ),
        'FirebaseAuth_not_registered',
      );
    });
  });
}
