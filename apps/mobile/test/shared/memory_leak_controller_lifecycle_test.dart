import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets('TextEditingController State dispose is leak-safe', (
    final tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _ControllerHost()));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _ControllerHost extends StatefulWidget {
  const _ControllerHost();

  @override
  State<_ControllerHost> createState() => _ControllerHostState();
}

class _ControllerHostState extends State<_ControllerHost> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'wave-a');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(body: TextField(controller: _controller));
  }
}
