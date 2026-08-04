import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

/// Product-owned disposables named in dual dry-run B2 candidacy (PR0):
/// TextEditingController, ScrollController, confetti/ParticleSystem path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets(
    'chat dual TextEditingController+ScrollController dispose is leak-safe',
    (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: _ChatControllersHost()));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  leakSafeTestWidgets(
    'counter ConfettiController dispose is leak-safe',
    (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: _ConfettiHost()));
      await tester.pump();
      expect(find.byType(ConfettiWidget), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    },
    // package:confetti leaves ParticleSystem after ConfettiController.dispose;
    // controller ownership (CounterPage path) is still tracked and exercised.
    ignoredNotDisposedClasses: <String>[
      ...memoryLeakHarnessLayerClasses,
      'ParticleSystem',
    ],
  );
}

/// Mirrors [ChatPage] dual-controller ownership (controllers only).
class _ChatControllersHost extends StatefulWidget {
  const _ChatControllersHost();

  @override
  State<_ChatControllersHost> createState() => _ChatControllersHostState();
}

class _ChatControllersHostState extends State<_ChatControllersHost> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'b2-chat');
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: const [Text('message')],
            ),
          ),
          TextField(controller: _controller),
        ],
      ),
    );
  }
}

/// Mirrors [CounterPage] confetti ownership (ParticleSystem via confetti package).
class _ConfettiHost extends StatefulWidget {
  const _ConfettiHost();

  @override
  State<_ConfettiHost> createState() => _ConfettiHostState();
}

class _ConfettiHostState extends State<_ConfettiHost> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
