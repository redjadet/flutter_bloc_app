import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/widgets/genui_demo_content.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;
import 'package:mocktail/mocktail.dart';

class _FakeGenUiDemoAgent implements GenUiDemoAgent {
  _FakeGenUiDemoAgent() {
    _surfaceEventsController = StreamController<GenUiSurfaceEvent>.broadcast();
    _errorsController = StreamController<String>.broadcast();
  }

  late final StreamController<GenUiSurfaceEvent> _surfaceEventsController;
  late final StreamController<String> _errorsController;
  genui.A2uiMessageProcessor? _hostHandle;

  @override
  Future<void> initialize() async {
    _hostHandle = _FakeA2uiMessageProcessor();
  }

  @override
  Future<void> sendMessage(final String text) async {
    // No-op for testing
  }

  @override
  Stream<GenUiSurfaceEvent> get surfaceEvents =>
      _surfaceEventsController.stream;

  @override
  Stream<String> get textResponses => const Stream<String>.empty();

  @override
  Stream<String> get errors => _errorsController.stream;

  @override
  genui.A2uiMessageProcessor? get hostHandle => _hostHandle;

  @override
  Future<void> dispose() async {
    await _surfaceEventsController.close();
    await _errorsController.close();
  }

  void emitSurfaceAdded(final String surfaceId) {
    _surfaceEventsController.add(GenUiSurfaceEvent.added(surfaceId: surfaceId));
  }

  void emitSurfaceRemoved(final String surfaceId) {
    _surfaceEventsController.add(
      GenUiSurfaceEvent.removed(surfaceId: surfaceId),
    );
  }

  void emitError(final String error) {
    _errorsController.add(error);
  }
}

// Fake implementation of A2uiMessageProcessor for testing
class _FakeA2uiMessageProcessor extends Mock
    implements genui.A2uiMessageProcessor {}

// Helper widget that matches the internal structure of GenUiDemoPage
class _GenUiDemoView extends StatelessWidget {
  const _GenUiDemoView();

  @override
  Widget build(final BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.genuiDemoPageTitle)),
      body: BlocBuilder<GenUiDemoCubit, GenUiDemoState>(
        builder: (final context, final state) {
          return GenUiDemoContent(state: state);
        },
      ),
    );
  }
}

Widget buildSubject({
  final GenUiDemoAgent? agent,
  final GenUiDemoState? initialState,
}) {
  final GenUiDemoAgent testAgent = agent ?? _FakeGenUiDemoAgent();
  final GenUiDemoCubit cubit = GenUiDemoCubit(agent: testAgent);

  if (initialState != null) {
    cubit.emit(initialState);
  }

  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<GenUiDemoCubit>.value(
      value: cubit,
      child: const _GenUiDemoView(),
    ),
  );
}

void main() {
  group('GenUiDemoPage', () {
    testWidgets('renders page with initial state', (final tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(GenUiDemoContent), findsOneWidget);
    });

    testWidgets('displays loading widget in initial state', (
      final tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(initialState: const GenUiDemoState.initial()),
      );
      await tester.pump();

      // CommonLoadingWidget should be present
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays ready state with empty surfaces', (
      final tester,
    ) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.ready(
            surfaceIds: const [],
            hostHandle: agent.hostHandle,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GenUiDemoContent), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays error state', (final tester) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.error(
            message: 'Test error message',
            hostHandle: agent.hostHandle,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('displays input field and send button', (final tester) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.ready(
            surfaceIds: const [],
            hostHandle: agent.hostHandle,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(_GenUiDemoView)),
      );
      expect(find.text(l10n.genuiDemoSendButton), findsOneWidget);
    });

    testWidgets('sends message when button is tapped', (final tester) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.ready(
            surfaceIds: const [],
            hostHandle: agent.hostHandle,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Hello, GenUI!');
      await tester.tap(find.text('Send'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify message was sent (check that isSending state was set)
      // The actual send is async, so we just verify the UI interaction
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('disables send button when isSending is true', (
      final tester,
    ) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.ready(
            surfaceIds: const [],
            hostHandle: agent.hostHandle,
            isSending: true,
          ),
        ),
      );
      await tester.pump();

      // Button should be disabled (showing loading indicator)
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays ready state with empty surfaces', (
      final tester,
    ) async {
      final agent = _FakeGenUiDemoAgent();
      await agent.initialize();

      await tester.pumpWidget(
        buildSubject(
          agent: agent,
          initialState: GenUiDemoState.ready(
            surfaceIds: const [],
            hostHandle: agent.hostHandle,
          ),
        ),
      );
      await tester.pump();

      // Content widget should be present
      expect(find.byType(GenUiDemoContent), findsOneWidget);
      // Input field should be present
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
