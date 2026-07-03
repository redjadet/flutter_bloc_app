import 'package:ai/ai.dart';
import 'package:test/test.dart';

void main() {
  test('public AI contracts are constructible', () {
    const template = PromptTemplate(
      id: 'greet',
      version: PromptVersion(1, 0, 0),
      body: 'Hello {{name}}',
      variables: ['name'],
    );
    expect(template.render({'name': 'world'}), 'Hello world');

    final registry = ToolRegistry();
    registry.register(
      descriptor: const ToolDescriptor(name: 'ping', description: 'ping'),
      handler: (call) async => ToolResult(callId: call.id, output: 'pong'),
    );
    expect(registry.descriptors.length, 1);
  });
}
