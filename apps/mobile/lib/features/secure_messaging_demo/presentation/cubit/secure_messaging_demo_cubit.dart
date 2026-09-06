import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/encrypted_payload.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_failure.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_state.dart';

class SecureMessagingDemoCubit extends Cubit<SecureMessagingDemoState> {
  new({required this._repository}) : super(const SecureMessagingDemoInitial());

  final SecureCoreRepository _repository;
  int _requestGeneration = 0;
  String? _retainedPlaintext;

  Future<void> initialize() async {
    final int generation = ++_requestGeneration;
    emit(const SecureMessagingDemoCheckingHealth());
    try {
      final bool healthy = await _repository.healthCheck();
      if (!_isRequestActive(generation)) {
        return;
      }
      if (!healthy) {
        emit(const SecureMessagingDemoUnavailable());
        return;
      }
      final String version = await _repository.version();
      if (!_isRequestActive(generation)) {
        return;
      }
      emit(SecureMessagingDemoReady(version: version));
    } on SecureCoreFailure catch (failure) {
      if (!_isRequestActive(generation)) {
        return;
      }
      if (failure is SecureCoreUnavailableFailure) {
        emit(const SecureMessagingDemoUnavailable());
        return;
      }
      emit(SecureMessagingDemoFailure(failure: failure));
    }
  }

  void updatePlaintext(String value) {
    ++_requestGeneration;
    _retainedPlaintext = null;
    final SecureMessagingDemoState current = state;
    final String version = current.version ?? '';
    if (current is SecureMessagingDemoUnavailable ||
        current is SecureMessagingDemoCheckingHealth ||
        current is SecureMessagingDemoInitial) {
      return;
    }
    emit(SecureMessagingDemoReady(version: version, plaintext: value));
  }

  Future<void> encrypt() async {
    final String plaintext = state.plaintext;
    final String version = state.version ?? '';
    if (plaintext.trim().isEmpty) {
      emit(
        SecureMessagingDemoFailure(
          failure: SecureCoreFailures.invalidInput,
          version: version,
          plaintext: plaintext,
        ),
      );
      return;
    }
    final int generation = ++_requestGeneration;
    _retainedPlaintext = plaintext;
    emit(SecureMessagingDemoEncrypting(version: version, plaintext: plaintext));
    try {
      final EncryptedPayload payload = await _repository.encrypt(plaintext);
      if (!_isRequestActive(generation)) {
        return;
      }
      emit(
        SecureMessagingDemoEncrypted(
          version: version,
          plaintext: plaintext,
          payload: payload,
        ),
      );
    } on SecureCoreFailure catch (failure) {
      if (!_isRequestActive(generation)) {
        return;
      }
      emit(
        SecureMessagingDemoFailure(
          failure: failure,
          version: version,
          plaintext: plaintext,
        ),
      );
    }
  }

  Future<void> decrypt() async {
    final SecureMessagingDemoState current = state;
    final EncryptedPayload? payload = current.payload;
    if (payload == null) {
      return;
    }
    final String version = current.version ?? '';
    final String plaintext = current.plaintext;
    final int generation = ++_requestGeneration;
    emit(
      SecureMessagingDemoDecrypting(
        version: version,
        plaintext: plaintext,
        payload: payload,
      ),
    );
    try {
      final String recovered = await _repository.decrypt(payload);
      if (!_isRequestActive(generation)) {
        return;
      }
      final String? expected = _retainedPlaintext;
      if (expected != null && recovered != expected) {
        emit(
          SecureMessagingDemoFailure(
            failure: SecureCoreFailures.mismatch,
            version: version,
            plaintext: plaintext,
            payload: payload,
          ),
        );
        return;
      }
      emit(
        SecureMessagingDemoSuccess(
          version: version,
          plaintext: plaintext,
          payload: payload,
          recoveredPlaintext: recovered,
        ),
      );
    } on SecureCoreFailure catch (failure) {
      if (!_isRequestActive(generation)) {
        return;
      }
      emit(
        SecureMessagingDemoFailure(
          failure: failure,
          version: version,
          plaintext: plaintext,
          payload: payload,
        ),
      );
    }
  }

  void reset() {
    ++_requestGeneration;
    _retainedPlaintext = null;
    final String version = state.version ?? '';
    if (state is SecureMessagingDemoUnavailable) {
      emit(const SecureMessagingDemoUnavailable());
      return;
    }
    if (version.isEmpty) {
      emit(const SecureMessagingDemoInitial());
      return;
    }
    emit(SecureMessagingDemoReady(version: version));
  }

  @override
  Future<void> close() {
    ++_requestGeneration;
    _retainedPlaintext = null;
    return super.close();
  }

  bool _isRequestActive(int generation) =>
      !isClosed && generation == _requestGeneration;
}
