import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_state.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/widgets/secure_messaging_demo_body.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpBody(
    WidgetTester tester, {
    required SecureMessagingDemoState state,
    VoidCallback? onEncrypt,
    VoidCallback? onDecrypt,
    VoidCallback? onReset,
    String? failureMessage,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SecureMessagingDemoBody(
            state: state,
            onPlaintextChanged: (_) {},
            onEncrypt: onEncrypt ?? () {},
            onDecrypt: onDecrypt ?? () {},
            onReset: onReset ?? () {},
            failureMessage: failureMessage,
          ),
        ),
      ),
    );
  }

  group('SecureMessagingDemoBody', () {
    testWidgets('ready state shows encrypt controls', (
      WidgetTester tester,
    ) async {
      await pumpBody(
        tester,
        state: const SecureMessagingDemoReady(version: '0.1.0'),
      );

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-warning')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('secure-messaging-demo-version')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('secure-messaging-demo-plaintext')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('secure-messaging-demo-encrypt')),
        findsOneWidget,
      );
    });

    testWidgets('unavailable state hides encrypt controls', (
      WidgetTester tester,
    ) async {
      await pumpBody(tester, state: const SecureMessagingDemoUnavailable());

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-unavailable')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('secure-messaging-demo-plaintext')),
        findsNothing,
      );
    });

    testWidgets('encrypted state enables decrypt and shows ciphertext', (
      WidgetTester tester,
    ) async {
      var decryptTapped = false;
      await pumpBody(
        tester,
        state: SecureMessagingDemoEncrypted(
          version: '0.1.0',
          plaintext: 'hello',
          payload: const EncryptedPayload('Y2lwaGVydGV4dA=='),
        ),
        onDecrypt: () => decryptTapped = true,
      );

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-ciphertext')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('secure-messaging-demo-decrypt')),
      );
      expect(decryptTapped, isTrue);
    });

    testWidgets('processing state shows progress and disables actions', (
      WidgetTester tester,
    ) async {
      await pumpBody(
        tester,
        state: const SecureMessagingDemoEncrypting(
          version: '0.1.0',
          plaintext: 'hello',
        ),
      );

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-processing')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('secure-messaging-demo-encrypt')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey('secure-messaging-demo-reset')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('success shows recovered plaintext', (
      WidgetTester tester,
    ) async {
      await pumpBody(
        tester,
        state: const SecureMessagingDemoSuccess(
          version: '0.1.0',
          plaintext: 'hello',
          payload: EncryptedPayload('Y2lwaGVydGV4dA=='),
          recoveredPlaintext: 'hello',
        ),
      );

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-success')),
        findsOneWidget,
      );
      expect(find.text('hello'), findsWidgets);
    });

    testWidgets('failure retains ciphertext and reset remains available', (
      WidgetTester tester,
    ) async {
      var resetTapped = false;
      await pumpBody(
        tester,
        state: SecureMessagingDemoFailure(
          failure: SecureCoreFailures.authenticationFailed,
          version: '0.1.0',
          plaintext: 'hello',
          payload: const EncryptedPayload('Y2lwaGVydGV4dA=='),
        ),
        failureMessage: 'Authentication failed',
        onReset: () => resetTapped = true,
      );

      expect(
        find.byKey(const ValueKey('secure-messaging-demo-failure')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('secure-messaging-demo-ciphertext')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('secure-messaging-demo-reset')),
      );
      expect(resetTapped, isTrue);
    });
  });
}
