import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_message_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'WebsocketMessageList keys repaint boundaries by stable list position',
    (tester) async {
      final WebsocketMessage incoming = WebsocketMessage(
        sequence: 0,
        direction: WebsocketMessageDirection.incoming,
        text: 'hello',
      );
      final WebsocketMessage outgoing = WebsocketMessage(
        sequence: 1,
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

      expect(
        find.byKey(const ValueKey<String>('ws-msg-incoming-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('ws-msg-outgoing-1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'WebsocketMessageList keeps position keys when messages are new instances',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebsocketMessageList(
              messages: <WebsocketMessage>[
                WebsocketMessage(
                  sequence: 0,
                  direction: WebsocketMessageDirection.incoming,
                  text: 'hello',
                ),
                WebsocketMessage(
                  sequence: 1,
                  direction: WebsocketMessageDirection.outgoing,
                  text: 'hi',
                ),
              ],
              emptyLabel: 'No messages',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('ws-msg-incoming-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('ws-msg-outgoing-1')),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebsocketMessageList(
              messages: <WebsocketMessage>[
                WebsocketMessage(
                  sequence: 0,
                  direction: WebsocketMessageDirection.incoming,
                  text: 'hello',
                ),
                WebsocketMessage(
                  sequence: 1,
                  direction: WebsocketMessageDirection.outgoing,
                  text: 'hi',
                ),
              ],
              emptyLabel: 'No messages',
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('ws-msg-incoming-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('ws-msg-outgoing-1')),
        findsOneWidget,
      );
    },
  );
}
