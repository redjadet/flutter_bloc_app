// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncOperation {

 String get id; String get entityType; Map<String, dynamic> get payload; String get idempotencyKey; DateTime get createdAt; DateTime? get nextRetryAt; int get retryCount;
/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncOperationCopyWith<SyncOperation> get copyWith => _$SyncOperationCopyWithImpl<SyncOperation>(this as SyncOperation, _$identity);

  /// Serializes this SyncOperation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.nextRetryAt, nextRetryAt) || other.nextRetryAt == nextRetryAt)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,const DeepCollectionEquality().hash(payload),idempotencyKey,createdAt,nextRetryAt,retryCount);

@override
String toString() {
  return 'SyncOperation(id: $id, entityType: $entityType, payload: $payload, idempotencyKey: $idempotencyKey, createdAt: $createdAt, nextRetryAt: $nextRetryAt, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class $SyncOperationCopyWith<$Res>  {
  factory $SyncOperationCopyWith(SyncOperation value, $Res Function(SyncOperation) _then) = _$SyncOperationCopyWithImpl;
@useResult
$Res call({
 String id, String entityType, Map<String, dynamic> payload, String idempotencyKey, DateTime createdAt, DateTime? nextRetryAt, int retryCount
});




}
/// @nodoc
class _$SyncOperationCopyWithImpl<$Res>
    implements $SyncOperationCopyWith<$Res> {
  _$SyncOperationCopyWithImpl(this._self, this._then);

  final SyncOperation _self;
  final $Res Function(SyncOperation) _then;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityType = null,Object? payload = null,Object? idempotencyKey = null,Object? createdAt = null,Object? nextRetryAt = freezed,Object? retryCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncOperation].
extension SyncOperationPatterns on SyncOperation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncOperation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncOperation value)  $default,){
final _that = this;
switch (_that) {
case _SyncOperation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncOperation value)?  $default,){
final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entityType,  Map<String, dynamic> payload,  String idempotencyKey,  DateTime createdAt,  DateTime? nextRetryAt,  int retryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that.id,_that.entityType,_that.payload,_that.idempotencyKey,_that.createdAt,_that.nextRetryAt,_that.retryCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entityType,  Map<String, dynamic> payload,  String idempotencyKey,  DateTime createdAt,  DateTime? nextRetryAt,  int retryCount)  $default,) {final _that = this;
switch (_that) {
case _SyncOperation():
return $default(_that.id,_that.entityType,_that.payload,_that.idempotencyKey,_that.createdAt,_that.nextRetryAt,_that.retryCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entityType,  Map<String, dynamic> payload,  String idempotencyKey,  DateTime createdAt,  DateTime? nextRetryAt,  int retryCount)?  $default,) {final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that.id,_that.entityType,_that.payload,_that.idempotencyKey,_that.createdAt,_that.nextRetryAt,_that.retryCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncOperation extends SyncOperation {
  const _SyncOperation({required this.id, required this.entityType, required final  Map<String, dynamic> payload, required this.idempotencyKey, required this.createdAt, this.nextRetryAt, this.retryCount = 0}): _payload = payload,super._();
  factory _SyncOperation.fromJson(Map<String, dynamic> json) => _$SyncOperationFromJson(json);

@override final  String id;
@override final  String entityType;
 final  Map<String, dynamic> _payload;
@override Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override final  String idempotencyKey;
@override final  DateTime createdAt;
@override final  DateTime? nextRetryAt;
@override@JsonKey() final  int retryCount;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncOperationCopyWith<_SyncOperation> get copyWith => __$SyncOperationCopyWithImpl<_SyncOperation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncOperationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.nextRetryAt, nextRetryAt) || other.nextRetryAt == nextRetryAt)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,const DeepCollectionEquality().hash(_payload),idempotencyKey,createdAt,nextRetryAt,retryCount);

@override
String toString() {
  return 'SyncOperation(id: $id, entityType: $entityType, payload: $payload, idempotencyKey: $idempotencyKey, createdAt: $createdAt, nextRetryAt: $nextRetryAt, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class _$SyncOperationCopyWith<$Res> implements $SyncOperationCopyWith<$Res> {
  factory _$SyncOperationCopyWith(_SyncOperation value, $Res Function(_SyncOperation) _then) = __$SyncOperationCopyWithImpl;
@override @useResult
$Res call({
 String id, String entityType, Map<String, dynamic> payload, String idempotencyKey, DateTime createdAt, DateTime? nextRetryAt, int retryCount
});




}
/// @nodoc
class __$SyncOperationCopyWithImpl<$Res>
    implements _$SyncOperationCopyWith<$Res> {
  __$SyncOperationCopyWithImpl(this._self, this._then);

  final _SyncOperation _self;
  final $Res Function(_SyncOperation) _then;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityType = null,Object? payload = null,Object? idempotencyKey = null,Object? createdAt = null,Object? nextRetryAt = freezed,Object? retryCount = null,}) {
  return _then(_SyncOperation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,nextRetryAt: freezed == nextRetryAt ? _self.nextRetryAt : nextRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
