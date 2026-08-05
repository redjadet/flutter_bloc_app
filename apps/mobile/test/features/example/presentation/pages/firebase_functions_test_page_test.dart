import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/firebase_functions_test_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class _MockHttpsCallable extends Mock implements HttpsCallable {}

class _FakeHttpsCallableResult<T> implements HttpsCallableResult<T> {
  _FakeHttpsCallableResult(this.data);

  @override
  final T data;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFirebaseFunctions functions;
  late _MockHttpsCallable helloCallable;
  late _MockHttpsCallable tokenCallable;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    functions = _MockFirebaseFunctions();
    helloCallable = _MockHttpsCallable();
    tokenCallable = _MockHttpsCallable();
    when(() => functions.httpsCallable('helloWorld')).thenReturn(helloCallable);
    when(
      () => functions.httpsCallable('issueRenderChatDemoHfReadToken'),
    ).thenReturn(tokenCallable);
  });

  Future<void> pumpPage(
    final WidgetTester tester, {
    required final bool isFirebaseReady,
    required final bool isAuthenticated,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: FirebaseFunctionsTestPage(
          isFirebaseReady: isFirebaseReady,
          isAuthenticated: isAuthenticated,
          functions: functions,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('disables actions when Firebase unavailable', (
    final tester,
  ) async {
    await pumpPage(tester, isFirebaseReady: false, isAuthenticated: false);
    final hello = tester.widget<FilledButton>(
      find.byKey(const ValueKey('firebase-functions-hello-button')),
    );
    final token = tester.widget<FilledButton>(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    expect(hello.onPressed, isNull);
    expect(token.onPressed, isNull);
    expect(
      find.byKey(const ValueKey('firebase-functions-unavailable')),
      findsOneWidget,
    );
  });

  testWidgets('signed-out enables helloWorld only', (final tester) async {
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: false);
    final hello = tester.widget<FilledButton>(
      find.byKey(const ValueKey('firebase-functions-hello-button')),
    );
    final token = tester.widget<FilledButton>(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    expect(hello.onPressed, isNotNull);
    expect(token.onPressed, isNull);
    expect(
      find.byKey(const ValueKey('firebase-functions-auth-required')),
      findsOneWidget,
    );
  });

  testWidgets('helloWorld renders safe message', (final tester) async {
    when(() => helloCallable.call<Map<String, dynamic>>(any())).thenAnswer(
      (final _) async => _FakeHttpsCallableResult<Map<String, dynamic>>(
        <String, dynamic>{'message': 'Hello World'},
      ),
    );
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: true);
    await tester.tap(
      find.byKey(const ValueKey('firebase-functions-hello-button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('token success shows presence and length only', (
    final tester,
  ) async {
    const String secret = 'super-secret-token-value';
    when(() => tokenCallable.call<dynamic>(any())).thenAnswer(
      (final _) async => _FakeHttpsCallableResult<Map<String, dynamic>>(
        <String, dynamic>{'hf_read_token': secret},
      ),
    );
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: true);
    await tester.tap(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('token_present=true length=${secret.length}'),
      findsOneWidget,
    );
    expect(find.textContaining(secret), findsNothing);
  });

  testWidgets('token accepts legacy token key', (final tester) async {
    const String secret = 'legacy-token';
    when(() => tokenCallable.call<dynamic>(any())).thenAnswer(
      (final _) async => _FakeHttpsCallableResult<Map<String, dynamic>>(
        <String, dynamic>{'token': secret},
      ),
    );
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: true);
    await tester.tap(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('token_present=true length=${secret.length}'),
      findsOneWidget,
    );
    expect(find.textContaining(secret), findsNothing);
  });

  testWidgets('token Functions exception hides details', (final tester) async {
    when(() => tokenCallable.call<dynamic>(any())).thenThrow(
      FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'secret-message',
        details: 'secret-details',
      ),
    );
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: true);
    await tester.tap(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('unauthenticated'), findsOneWidget);
    expect(find.textContaining('secret-message'), findsNothing);
    expect(find.textContaining('secret-details'), findsNothing);
  });

  testWidgets('malformed token payload shows safe error', (final tester) async {
    when(() => tokenCallable.call<dynamic>(any())).thenAnswer(
      (final _) async => _FakeHttpsCallableResult<Map<String, dynamic>>(
        <String, dynamic>{'oops': true},
      ),
    );
    await pumpPage(tester, isFirebaseReady: true, isAuthenticated: true);
    await tester.tap(
      find.byKey(const ValueKey('firebase-functions-token-button')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('unexpected'), findsOneWidget);
  });
}
