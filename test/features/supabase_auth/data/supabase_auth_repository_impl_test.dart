import 'dart:async';

import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

void main() {
  group('SupabaseAuthRepositoryImpl', () {
    test(
      'returns null current user and auth stream when unconfigured',
      () async {
        final SupabaseAuthRepositoryImpl repository =
            SupabaseAuthRepositoryImpl(isConfiguredOverride: () => false);

        expect(repository.isConfigured, isFalse);
        expect(repository.currentUser, isNull);
        await expectLater(
          repository.authStateChanges,
          emitsInOrder(<Object?>[null, emitsDone]),
        );
      },
    );

    test('maps current user metadata safely', () {
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        readCurrentUser: () => User(
          id: 'user-1',
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{'full_name': '  Test User  '},
          aud: 'authenticated',
          email: ' user@example.com ',
          createdAt: '2025-03-11T10:00:00Z',
        ),
      );

      expect(
        repository.currentUser,
        isA<AuthUser>()
            .having((final AuthUser user) => user.id, 'id', 'user-1')
            .having(
              (final AuthUser user) => user.email,
              'email',
              'user@example.com',
            )
            .having(
              (final AuthUser user) => user.displayName,
              'displayName',
              'Test User',
            )
            .having(
              (final AuthUser user) => user.isAnonymous,
              'isAnonymous',
              isFalse,
            ),
      );
    });

    test('returns null display name for wrong-typed metadata', () {
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        readCurrentUser: () => User(
          id: 'user-2',
          appMetadata: const <String, dynamic>{},
          userMetadata: const <String, dynamic>{'full_name': 42},
          aud: 'authenticated',
          email: 'user2@example.com',
          createdAt: '2025-03-11T10:00:00Z',
        ),
      );

      expect(repository.currentUser?.displayName, isNull);
    });

    test('maps auth state changes to domain users', () async {
      final StreamController<AuthState> controller =
          StreamController<AuthState>();
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        authStateChangesStream: () => controller.stream,
      );

      unawaited(
        Future<void>(() async {
          controller
            ..add(
              AuthState(
                AuthChangeEvent.signedIn,
                Session(
                  accessToken: 'token',
                  tokenType: 'bearer',
                  user: User(
                    id: 'stream-user',
                    appMetadata: const <String, dynamic>{},
                    userMetadata: const <String, dynamic>{
                      'full_name': 'Stream User',
                    },
                    aud: 'authenticated',
                    email: 'stream@example.com',
                    createdAt: '2025-03-11T10:00:00Z',
                  ),
                ),
              ),
            )
            ..add(const AuthState(AuthChangeEvent.signedOut, null));
          await controller.close();
        }),
      );

      await expectLater(
        repository.authStateChanges,
        emitsInOrder(<Object?>[
          isA<AuthUser>().having(
            (final AuthUser user) => user.displayName,
            'displayName',
            'Stream User',
          ),
          null,
          emitsDone,
        ]),
      );
    });

    test('maps sign in auth failures to invalid credentials', () async {
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        signInWithPasswordImpl:
            ({
              required final String email,
              required final String password,
            }) async {
              expect(email, 'user@example.com');
              expect(password, 'secret');
              throw const AuthException(
                'Invalid login credentials',
                statusCode: '400',
              );
            },
      );

      await expectLater(
        repository.signInWithPassword(
          email: ' user@example.com ',
          password: 'secret',
        ),
        throwsA(
          isA<SupabaseAuthException>()
              .having(
                (final SupabaseAuthException error) => error.code,
                'code',
                SupabaseAuthErrorCode.invalidCredentials,
              )
              .having(
                (final SupabaseAuthException error) => error.message,
                'message',
                'Invalid login credentials',
              ),
        ),
      );
    });

    test('maps sign up retryable fetch failures to network', () async {
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        signUpImpl:
            ({
              required final String email,
              required final String password,
              final Map<String, dynamic>? data,
            }) async {
              expect(email, 'user@example.com');
              expect(password, 'secret');
              expect(data, const <String, dynamic>{
                'full_name': 'Display Name',
              });
              throw AuthRetryableFetchException(message: 'temporary issue');
            },
      );

      await expectLater(
        repository.signUp(
          email: ' user@example.com ',
          password: 'secret',
          displayName: ' Display Name ',
        ),
        throwsA(
          isA<SupabaseAuthException>().having(
            (final SupabaseAuthException error) => error.code,
            'code',
            SupabaseAuthErrorCode.network,
          ),
        ),
      );
    });

    test('wraps unexpected sign in failures consistently', () async {
      final StateError failure = StateError('boom');
      final SupabaseAuthRepositoryImpl repository = SupabaseAuthRepositoryImpl(
        isConfiguredOverride: () => true,
        signInWithPasswordImpl:
            ({
              required final String email,
              required final String password,
            }) async {
              throw failure;
            },
      );

      await expectLater(
        repository.signInWithPassword(email: 'user@example.com', password: 'x'),
        throwsA(
          isA<SupabaseAuthException>()
              .having(
                (final SupabaseAuthException error) => error.message,
                'message',
                'Bad state: boom',
              )
              .having(
                (final SupabaseAuthException error) => error.cause,
                'cause',
                same(failure),
              ),
        ),
      );
    });

    test(
      'configured signOut delegates and unconfigured signOut is no-op',
      () async {
        var signOutCalls = 0;
        final SupabaseAuthRepositoryImpl configured =
            SupabaseAuthRepositoryImpl(
              isConfiguredOverride: () => true,
              signOutImpl: () async {
                signOutCalls += 1;
              },
            );
        final SupabaseAuthRepositoryImpl unconfigured =
            SupabaseAuthRepositoryImpl(
              isConfiguredOverride: () => false,
              signOutImpl: () async {
                signOutCalls += 100;
              },
            );

        await configured.signOut();
        await unconfigured.signOut();

        expect(signOutCalls, 1);
      },
    );
  });
}
