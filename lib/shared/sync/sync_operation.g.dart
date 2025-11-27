// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncOperation _$SyncOperationFromJson(Map<String, dynamic> json) =>
    _SyncOperation(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      idempotencyKey: json['idempotencyKey'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SyncOperationToJson(_SyncOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': instance.entityType,
      'payload': instance.payload,
      'idempotencyKey': instance.idempotencyKey,
      'createdAt': instance.createdAt.toIso8601String(),
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
      'retryCount': instance.retryCount,
    };
