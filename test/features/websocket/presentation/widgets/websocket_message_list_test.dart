import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_message_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'WebsocketMessageList keys repaint boundaries by message identity',
    (tester) async {
      final WebsocketMessage incoming = WebsocketMessage(
        direction: WebsocketMessageDirection.incoming,
        text: 'hello',
      );
      final WebsocketMessage outgoing = WebsocketMessage(
        direction: WebsocketMessageDirection.outgoing,
        text: 'hi',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebsocketMessageList(
              messages: <WebsocketMessage>[incoming, outgoing],
              emptyLabel: 'No messages',
            ),
          ),
        ),
      );

      expect(find.byKey(ObjectKey(incoming)), findsOneWidget);
      expect(find.byKey(ObjectKey(outgoing)), findsOneWidget);
    },
  );
}
