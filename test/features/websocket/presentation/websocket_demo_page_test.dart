import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/pages/websocket_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WebsocketDemoPage renders and sends messages', (tester) async {
    final _FakeWebsocketRepository repository = _FakeWebsocketRepository(
      Uri.parse('wss://echo.websocket.events'),
    );
    final WebsocketCubit cubit = WebsocketCubit(repository: repository);
    addTearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const WebsocketDemoPage(),
        ),
      ),
    );

    await tester.pump();

    final AppLocalizationsEn l10n = AppLocalizationsEn();
    expect(find.text(l10n.websocketEmptyState), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hi');
    await tester.tap(find.text(l10n.websocketSendButton));
    await tester.pump();
    await tester.pump();

    expect(find.text('hi'), findsOneWidget);
    expect(find.text('echo: hi'), findsOneWidget);
  });
}

class _FakeWebsocketRepository implements WebsocketRepository {
  _FakeWebsocketRepository(this.endpoint);

  @override
  final Uri endpoint;

  final StreamController<WebsocketConnectionState> _stateController =
      StreamController<WebsocketConnectionState>.broadcast();
  final StreamController<WebsocketMessage> _messageController =
      StreamController<WebsocketMessage>.broadcast();

  WebsocketConnectionState _state =
      const WebsocketConnectionState.disconnected();

  @override
  Stream<WebsocketConnectionState> get connectionStates =>
      _stateController.stream;

  @override
  WebsocketConnectionState get currentState => _state;

  @override
  Stream<WebsocketMessage> get incomingMessages => _messageController.stream;

  @override
  Future<void> connect() async {
    _state = const WebsocketConnectionState.connected();
    _stateController.add(_state);
  }

  @override
  Future<void> disconnect() async {
    _state = const WebsocketConnectionState.disconnected();
    _stateController.add(_state);
  }

  @override
  Future<void> send(String message) async {
    _messageController.add(
      WebsocketMessage(
        direction: WebsocketMessageDirection.incoming,
        text: 'echo: $message',
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _messageController.close();
  }
}
