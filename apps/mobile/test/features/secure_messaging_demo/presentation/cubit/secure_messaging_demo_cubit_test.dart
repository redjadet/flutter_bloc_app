import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_cubit.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSecureCoreRepository implements SecureCoreRepository {
  _FakeSecureCoreRepository({
    required this.health,
    required this.versionValue,
    this.encryptResult,
    this.decryptResult,
    this.encryptError,
    this.decryptError,
    this.healthError,
  });

  bool health;
  String versionValue;
  EncryptedPayload? encryptResult;
  String? decryptResult;
  SecureCoreFailure? encryptError;
  SecureCoreFailure? decryptError;
  SecureCoreFailure? healthError;
  Duration encryptDelay = Duration.zero;
  String? encryptedPlaintext;

  @override
  Future<EncryptedPayload> encrypt(String plaintext) async {
    encryptedPlaintext = plaintext;
    if (encryptDelay > Duration.zero) {
      await Future<void>.delayed(encryptDelay);
    }
    if (encryptError != null) {
      throw encryptError!;
    }
    return encryptResult ?? const EncryptedPayload('c2VjdXJl');
  }

  @override
  Future<String> decrypt(EncryptedPayload ciphertext) async {
    if (decryptError != null) {
      throw decryptError!;
    }
    return decryptResult ?? 'hello';
  }

  @override
  Future<bool> healthCheck() async {
    if (healthError != null) {
      throw healthError!;
    }
    return health;
  }

  @override
  Future<String> version() async => versionValue;
}

_FakeSecureCoreRepository _healthyRepo({
  EncryptedPayload? encryptResult,
  String? decryptResult,
  SecureCoreFailure? encryptError,
  SecureCoreFailure? decryptError,
}) => _FakeSecureCoreRepository(
  health: true,
  versionValue: '0.1.0-test',
  encryptResult: encryptResult,
  decryptResult: decryptResult,
  encryptError: encryptError,
  decryptError: decryptError,
);

void main() {
  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'initialize emits ready when healthy',
    build: () => SecureMessagingDemoCubit(repository: _healthyRepo()),
    act: (cubit) => cubit.initialize(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoCheckingHealth>(),
      isA<SecureMessagingDemoReady>().having(
        (s) => s.version,
        'version',
        '0.1.0-test',
      ),
    ],
  );

  test('encrypt preserves meaningful whitespace', () async {
    final _FakeSecureCoreRepository repo = _healthyRepo();
    final SecureMessagingDemoCubit cubit = SecureMessagingDemoCubit(
      repository: repo,
    );
    await cubit.initialize();
    cubit.updatePlaintext('  secret  ');

    await cubit.encrypt();

    expect(repo.encryptedPlaintext, '  secret  ');
    expect(cubit.state.plaintext, '  secret  ');
    await cubit.close();
  });

  test('decrypt can retry from failure retaining ciphertext', () async {
    final _FakeSecureCoreRepository repo = _healthyRepo(
      encryptResult: const EncryptedPayload('YWJj'),
      decryptResult: 'secret',
      decryptError: SecureCoreFailures.authenticationFailed,
    );
    final SecureMessagingDemoCubit cubit = SecureMessagingDemoCubit(
      repository: repo,
    );
    await cubit.initialize();
    cubit.updatePlaintext('secret');
    await cubit.encrypt();

    await cubit.decrypt();
    expect(cubit.state, isA<SecureMessagingDemoFailure>());
    repo.decryptError = null;
    await cubit.decrypt();

    expect(cubit.state, isA<SecureMessagingDemoSuccess>());
    await cubit.close();
  });

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'decrypt detects recovered plaintext mismatch',
    build: () => SecureMessagingDemoCubit(
      repository: _healthyRepo(
        encryptResult: const EncryptedPayload('YWJj'),
        decryptResult: 'different',
      ),
    ),
    seed: () => const SecureMessagingDemoReady(
      version: '0.1.0-test',
      plaintext: 'secret',
    ),
    act: (SecureMessagingDemoCubit cubit) async {
      await cubit.encrypt();
      await cubit.decrypt();
    },
    expect: () => <Matcher>[
      isA<SecureMessagingDemoEncrypting>(),
      isA<SecureMessagingDemoEncrypted>(),
      isA<SecureMessagingDemoDecrypting>(),
      isA<SecureMessagingDemoFailure>().having(
        (SecureMessagingDemoFailure state) => state.failure,
        'failure',
        isA<SecureCoreMismatchFailure>(),
      ),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'initialize emits unavailable when health is false',
    build: () => SecureMessagingDemoCubit(
      repository: _FakeSecureCoreRepository(
        health: false,
        versionValue: '0.1.0-test',
      ),
    ),
    act: (cubit) => cubit.initialize(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoCheckingHealth>(),
      isA<SecureMessagingDemoUnavailable>(),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'initialize emits unavailable on unavailable failure',
    build: () => SecureMessagingDemoCubit(
      repository: _FakeSecureCoreRepository(
        health: true,
        versionValue: '0.1.0-test',
        healthError: SecureCoreFailures.unavailable,
      ),
    ),
    act: (cubit) => cubit.initialize(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoCheckingHealth>(),
      isA<SecureMessagingDemoUnavailable>(),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'encrypt then decrypt success',
    build: () => SecureMessagingDemoCubit(
      repository: _healthyRepo(
        encryptResult: const EncryptedPayload('YWJj'),
        decryptResult: 'secret',
      ),
    ),
    seed: () => const SecureMessagingDemoReady(
      version: '0.1.0-test',
      plaintext: 'secret',
    ),
    act: (cubit) async {
      await cubit.encrypt();
      await cubit.decrypt();
    },
    expect: () => <Matcher>[
      isA<SecureMessagingDemoEncrypting>(),
      isA<SecureMessagingDemoEncrypted>().having(
        (s) => s.payload.base64Envelope,
        'payload',
        'YWJj',
      ),
      isA<SecureMessagingDemoDecrypting>(),
      isA<SecureMessagingDemoSuccess>().having(
        (s) => s.recoveredPlaintext,
        'recovered',
        'secret',
      ),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'encrypt maps repository failure',
    build: () => SecureMessagingDemoCubit(
      repository: _healthyRepo(encryptError: SecureCoreFailures.internal),
    ),
    seed: () => const SecureMessagingDemoReady(
      version: '0.1.0-test',
      plaintext: 'secret',
    ),
    act: (cubit) => cubit.encrypt(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoEncrypting>(),
      isA<SecureMessagingDemoFailure>().having(
        (s) => s.failure,
        'failure',
        isA<SecureCoreInternalFailure>(),
      ),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'decrypt maps repository failure',
    build: () => SecureMessagingDemoCubit(
      repository: _healthyRepo(
        decryptError: SecureCoreFailures.authenticationFailed,
      ),
    ),
    seed: () => SecureMessagingDemoEncrypted(
      version: '0.1.0-test',
      plaintext: 'secret',
      payload: const EncryptedPayload('YWJj'),
    ),
    act: (cubit) => cubit.decrypt(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoDecrypting>(),
      isA<SecureMessagingDemoFailure>().having(
        (s) => s.failure,
        'failure',
        isA<SecureCoreAuthenticationFailedFailure>(),
      ),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'empty plaintext encrypt emits invalid input',
    build: () => SecureMessagingDemoCubit(repository: _healthyRepo()),
    seed: () =>
        const SecureMessagingDemoReady(version: '0.1.0-test', plaintext: '   '),
    act: (cubit) => cubit.encrypt(),
    expect: () => <Matcher>[
      isA<SecureMessagingDemoFailure>().having(
        (s) => s.failure,
        'failure',
        isA<SecureCoreInvalidInputFailure>(),
      ),
    ],
  );

  blocTest<SecureMessagingDemoCubit, SecureMessagingDemoState>(
    'stale encrypt does not overwrite newer state',
    build: () {
      final _FakeSecureCoreRepository repo = _healthyRepo(
        encryptResult: const EncryptedPayload('slow'),
      )..encryptDelay = const Duration(milliseconds: 50);
      return SecureMessagingDemoCubit(repository: repo);
    },
    seed: () =>
        const SecureMessagingDemoReady(version: '0.1.0-test', plaintext: 'one'),
    act: (cubit) async {
      final Future<void> first = cubit.encrypt();
      cubit.updatePlaintext('two');
      await first;
    },
    expect: () => <Matcher>[
      isA<SecureMessagingDemoEncrypting>(),
      isA<SecureMessagingDemoReady>().having(
        (s) => s.plaintext,
        'plaintext',
        'two',
      ),
    ],
  );
}
