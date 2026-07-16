import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeSecurityChannelReplyMapper', () {
    test('maps a successful P-256 reply', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'hardwareBacked': true,
            'algorithm': 'P256',
            'verified': true,
            'keyResidency': 'android_keystore',
            'challengeByteCount': 32,
          });

      expect(result.status, NativeSecurityStatus.success);
      expect(result.reasonCode, 'ok');
      expect(result.platform, 'android');
      expect(result.hardwareBacked, isTrue);
      expect(result.algorithm, 'P256');
      expect(result.verified, isTrue);
      expect(result.keyResidency, NativeSecurityKeyResidency.androidKeystore);
      expect(result.challengeByteCount, 32);
    });

    test('maps a successful AES-GCM reply', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'ios',
            'algorithm': 'AES-GCM',
            'verified': true,
            'keyResidency': 'secure_enclave',
            'ciphertextByteCount': 48,
            'plaintextByteCount': 32,
            'aadByteCount': 16,
          });

      expect(result.status, NativeSecurityStatus.success);
      expect(result.algorithm, 'AES-GCM');
      expect(result.verified, isTrue);
      expect(result.keyResidency, NativeSecurityKeyResidency.secureEnclave);
      expect(result.ciphertextByteCount, 48);
      expect(result.plaintextByteCount, 32);
      expect(result.aadByteCount, 16);
    });

    test('maps a successful secure storage lifecycle reply', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'wrote': true,
            'readMatched': true,
            'deleted': true,
          });

      expect(result.status, NativeSecurityStatus.success);
      expect(result.wrote, isTrue);
      expect(result.readMatched, isTrue);
      expect(result.deleted, isTrue);
    });

    test('maps a denied biometric reply', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'denied',
            'reasonCode': 'biometric_canceled',
            'platform': 'ios',
          });

      expect(result.status, NativeSecurityStatus.denied);
      expect(result.reasonCode, 'biometric_canceled');
    });

    test('rejects a missing schemaVersion as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });

    test('rejects an unsupported schemaVersion as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 2,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });

    test('rejects a non-Map reply as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply('not a map');

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
      expect(result.platform, 'unknown');
    });

    test('rejects a null reply as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(null);

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });

    test('rejects an unknown status string as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'not_a_real_status',
            'reasonCode': 'ok',
            'platform': 'android',
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });

    test('rejects a missing reasonCode as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'platform': 'android',
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
    });

    test('ignores unexpected extra keys instead of copying them', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'rawPrivateKey': 'should-never-appear',
            'secretToken': 'should-never-appear',
          });

      expect(result.status, NativeSecurityStatus.success);
      final String serialized = result.toString();
      expect(serialized, isNot(contains('should-never-appear')));
    });

    test('defaults platform to unknown when missing', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'unavailable',
            'reasonCode': 'mobile_only',
          });

      expect(result.platform, 'unknown');
    });

    test('rejects unknown reasonCode as malformed', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'sk-secret-looking-code',
            'platform': 'android',
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'malformed_reply');
      expect(result.toString(), isNot(contains('sk-secret')));
    });

    test('coerces unknown platform to unknown', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'windows-exfil',
          });

      expect(result.status, NativeSecurityStatus.success);
      expect(result.platform, 'unknown');
      expect(result.toString(), isNot(contains('windows-exfil')));
    });

    test('strips unknown algorithm instead of echoing it', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'algorithm': 'RSA-PRIVATE-KEY-MATERIAL',
          });

      expect(result.algorithm, isNull);
      expect(result.toString(), isNot(contains('RSA-PRIVATE')));
    });

    test('downgrades success when verified is false', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'verified': false,
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'platform_error');
      expect(result.verified, isFalse);
    });

    test('rejects success missing operation-specific proof', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
          }, operation: NativeSecurityOperation.p256SignVerify);

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'platform_error');
    });

    test('drops negative byte counts', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'android',
            'verified': true,
            'challengeByteCount': -1,
          });

      expect(result.status, NativeSecurityStatus.success);
      expect(result.challengeByteCount, isNull);
    });

    test('downgrades success when secure-storage checks fail', () {
      final NativeSecurityOperationResult result =
          NativeSecurityChannelReplyMapper.fromChannelReply(<String, Object?>{
            'schemaVersion': 1,
            'status': 'success',
            'reasonCode': 'ok',
            'platform': 'ios',
            'wrote': true,
            'readMatched': false,
            'deleted': true,
          });

      expect(result.status, NativeSecurityStatus.failed);
      expect(result.reasonCode, 'platform_error');
      expect(result.readMatched, isFalse);
    });
  });
}
