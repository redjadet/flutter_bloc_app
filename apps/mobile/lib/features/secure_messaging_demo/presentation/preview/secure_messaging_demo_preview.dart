import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_cubit.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/pages/secure_messaging_demo_page.dart';

/// Widget preview host for secure messaging demo (fake repository).
Widget secureMessagingDemoPreview() {
  return BlocProvider<SecureMessagingDemoCubit>(
    create: (_) {
      final SecureMessagingDemoCubit cubit = SecureMessagingDemoCubit(
        repository: const _PreviewSecureCoreRepository(),
      );
      unawaited(cubit.initialize());
      return cubit;
    },
    child: const SecureMessagingDemoPage(),
  );
}

final class _PreviewSecureCoreRepository implements SecureCoreRepository {
  const new();

  @override
  Future<EncryptedPayload> encrypt(String plaintext) async =>
      const EncryptedPayload('cHJldmlldw==');

  @override
  Future<String> decrypt(EncryptedPayload ciphertext) async => 'preview';

  @override
  Future<bool> healthCheck() async => true;

  @override
  Future<String> version() async => 'preview';
}
