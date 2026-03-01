import 'package:flutter_bloc_app/features/genui_demo/data/genui_demo_agent_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenUiDemoAgentImpl', () {
    test('hostHandle is null before initialize', () {
      final agent = GenUiDemoAgentImpl();

      expect(agent.hostHandle, isNull);
    });

    test('sendMessage throws StateError before initialize', () async {
      final agent = GenUiDemoAgentImpl();

      expect(() => agent.sendMessage('hello'), throwsA(isA<StateError>()));
    });

    test('dispose completes before initialize', () async {
      final agent = GenUiDemoAgentImpl();

      await expectLater(agent.dispose(), completes);
    });
  });
}
