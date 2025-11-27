import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_operation.freezed.dart';
part 'sync_operation.g.dart';

@freezed
abstract class SyncOperation with _$SyncOperation {
  const factory SyncOperation({
    required String id,
    required String entityType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    required DateTime createdAt,
    DateTime? nextRetryAt,
    @Default(0) int retryCount,
  }) = _SyncOperation;

  const SyncOperation._();

  factory SyncOperation.fromJson(final Map<String, dynamic> json) =>
      _$SyncOperationFromJson(json);

  factory SyncOperation.create({
    required final String entityType,
    required final Map<String, dynamic> payload,
    required final String idempotencyKey,
    final DateTime? createdAt,
    final DateTime? nextRetryAt,
    final int retryCount = 0,
  }) => SyncOperation(
    id: _SyncOperationIdGenerator.instance.generate(),
    entityType: entityType,
    payload: Map<String, dynamic>.from(payload),
    idempotencyKey: idempotencyKey,
    createdAt: createdAt ?? DateTime.now().toUtc(),
    nextRetryAt: nextRetryAt,
    retryCount: retryCount,
  );
}

class _SyncOperationIdGenerator {
  _SyncOperationIdGenerator._();
  static final _SyncOperationIdGenerator instance =
      _SyncOperationIdGenerator._();
  final Random _random = Random();

  String generate() {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final int randomPart = _random.nextInt(0xFFFFFF);
    return '${timestamp.toRadixString(16)}-${randomPart.toRadixString(16).padLeft(6, '0')}';
  }
}
