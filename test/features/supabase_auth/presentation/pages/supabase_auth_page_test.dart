import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_state.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/pages/supabase_auth_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseAuthPage', () {
    testWidgets('shows not configured message when state is notConfigured', (
      final WidgetTester tester,
    ) async {
      final cubit = SupabaseAuthCubit(
        repository: _FakeRepo(isConfigured: false),
      )..emit(const SupabaseAuthState.notConfigured());
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('not configured', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('shows title from l10n', (final WidgetTester tester) async {
      final cubit = SupabaseAuthCubit(
        repository: _FakeRepo(isConfigured: false),
      )..emit(const SupabaseAuthState.notConfigured());
      addTearDown(cubit.close);

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('Supabase Auth'), findsOneWidget);
    });

    testWidgets(
      'disables submit buttons until email and password are entered',
      (final WidgetTester tester) async {
        final cubit = SupabaseAuthCubit(
          repository: _FakeRepo(isConfigured: true),
        )..emit(const SupabaseAuthState.unauthenticated());
        addTearDown(cubit.close);

        await tester.pumpWidget(_buildTestApp(cubit: cubit));
        await tester.pumpAndSettle();

        FilledButton signInButton() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Sign in'),
        );
        OutlinedButton signUpButton() => tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Sign up'),
        );

        expect(signInButton().onPressed, isNull);
        expect(signUpButton().onPressed, isNull);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.dev',
        );
        await tester.pump();

        expect(signInButton().onPressed, isNull);
        expect(signUpButton().onPressed, isNull);

        await tester.enterText(find.byType(TextFormField).at(1), 'password123');
        await tester.pump();

        expect(signInButton().onPressed, isNotNull);
        expect(signUpButton().onPressed, isNotNull);
      },
    );
  });
}

Widget _buildTestApp({required final SupabaseAuthCubit cubit}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<SupabaseAuthCubit>.value(
      value: cubit,
      child: const SupabaseAuthPage(),
    ),
  );
}

class _FakeRepo implements SupabaseAuthRepository {
  _FakeRepo({required this.isConfigured});

  @override
  final bool isConfigured;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {}

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {}

  @override
  Future<void> signOut() async {}
}
