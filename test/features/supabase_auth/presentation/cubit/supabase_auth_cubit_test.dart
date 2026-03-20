import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseAuthRepository extends Mock
    implements SupabaseAuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;
  late MockSupabaseAuthRepository mockRepository;
  late SupabaseAuthCubit cubit;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() {
    mockRepository = MockSupabaseAuthRepository();
    cubit = SupabaseAuthCubit(repository: mockRepository, l10n: l10n);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is initial', () {
    expect(cubit.state, const SupabaseAuthState.initial());
  });

  group('loadSession', () {
    test('emits notConfigured when repository is not configured', () async {
      when(() => mockRepository.isConfigured).thenReturn(false);

      await cubit.loadSession();

      expect(cubit.state, const SupabaseAuthState.notConfigured());
    });

    test('emits unauthenticated when configured and no user', () async {
      when(() => mockRepository.isConfigured).thenReturn(true);
      when(() => mockRepository.currentUser).thenReturn(null);
      when(
        () => mockRepository.authStateChanges,
      ).thenAnswer((_) => Stream<AuthUser?>.value(null));

      await cubit.loadSession();

      expect(cubit.state, const SupabaseAuthState.unauthenticated());
    });

    test('emits authenticated when configured and has user', () async {
      const user = AuthUser(id: 'uid', isAnonymous: false, email: 'a@b.c');
      when(() => mockRepository.isConfigured).thenReturn(true);
      when(() => mockRepository.currentUser).thenReturn(user);
      when(
        () => mockRepository.authStateChanges,
      ).thenAnswer((_) => Stream<AuthUser?>.value(user));

      await cubit.loadSession();

      expect(cubit.state, SupabaseAuthState.authenticated(user));
    });

    test('replaces previous auth state subscription on reload', () async {
      final controller = StreamController<AuthUser?>.broadcast();
      addTearDown(controller.close);

      const user = AuthUser(id: 'uid', isAnonymous: false, email: 'a@b.c');
      when(() => mockRepository.isConfigured).thenReturn(true);
      when(() => mockRepository.currentUser).thenReturn(null);
      when(
        () => mockRepository.authStateChanges,
      ).thenAnswer((_) => controller.stream);

      final states = <SupabaseAuthState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.loadSession();
      await cubit.loadSession();

      controller.add(user);
      await Future<void>.delayed(Duration.zero);

      final authenticatedStates = states.where(
        (state) => state == SupabaseAuthState.authenticated(user),
      );
      expect(authenticatedStates, hasLength(1));
    });

    test('emits mapped error when auth state stream fails', () async {
      final controller = StreamController<AuthUser?>.broadcast();
      addTearDown(controller.close);

      when(() => mockRepository.isConfigured).thenReturn(true);
      when(() => mockRepository.currentUser).thenReturn(null);
      when(
        () => mockRepository.authStateChanges,
      ).thenAnswer((_) => controller.stream);

      final states = <SupabaseAuthState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.loadSession();
      controller.addError(
        const SupabaseAuthException(
          'Network unavailable',
          code: SupabaseAuthErrorCode.network,
        ),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        states.last,
        SupabaseAuthState.error(l10n.supabaseAuthErrorNetwork),
      );
    });
  });

  group('signIn', () {
    blocTest<SupabaseAuthCubit, SupabaseAuthState>(
      'emits localized invalid credentials error',
      build: () {
        when(
          () => mockRepository.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(
          const SupabaseAuthException(
            'Invalid login credentials',
            code: SupabaseAuthErrorCode.invalidCredentials,
          ),
        );
        return SupabaseAuthCubit(repository: mockRepository, l10n: l10n);
      },
      act: (cubit) => cubit.signIn(email: 'user@example.com', password: 'bad'),
      expect: () => <SupabaseAuthState>[
        const SupabaseAuthState.loading(),
        SupabaseAuthState.error(l10n.supabaseAuthErrorInvalidCredentials),
      ],
    );
  });

  group('clearError', () {
    test('restores authenticated state when repository still has a user', () {
      const user = AuthUser(id: 'uid', isAnonymous: false, email: 'a@b.c');
      when(() => mockRepository.isConfigured).thenReturn(true);
      when(() => mockRepository.currentUser).thenReturn(user);

      cubit.clearError();

      expect(cubit.state, SupabaseAuthState.authenticated(user));
    });

    test('restores notConfigured state when repository is not configured', () {
      when(() => mockRepository.isConfigured).thenReturn(false);

      cubit.clearError();

      expect(cubit.state, const SupabaseAuthState.notConfigured());
    });
  });
}
