// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_security_operation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeSecurityOperationResult {

 NativeSecurityStatus get status; String get reasonCode; String get platform; NativeSecurityKeyResidency? get keyResidency; bool? get hardwareBacked; String? get algorithm; bool? get verified; int? get challengeByteCount; int? get ciphertextByteCount; int? get plaintextByteCount; int? get aadByteCount; bool? get wrote; bool? get readMatched; bool? get deleted;
/// Create a copy of NativeSecurityOperationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeSecurityOperationResultCopyWith<NativeSecurityOperationResult> get copyWith => _$NativeSecurityOperationResultCopyWithImpl<NativeSecurityOperationResult>(this as NativeSecurityOperationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeSecurityOperationResult&&(identical(other.status, status) || other.status == status)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.keyResidency, keyResidency) || other.keyResidency == keyResidency)&&(identical(other.hardwareBacked, hardwareBacked) || other.hardwareBacked == hardwareBacked)&&(identical(other.algorithm, algorithm) || other.algorithm == algorithm)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.challengeByteCount, challengeByteCount) || other.challengeByteCount == challengeByteCount)&&(identical(other.ciphertextByteCount, ciphertextByteCount) || other.ciphertextByteCount == ciphertextByteCount)&&(identical(other.plaintextByteCount, plaintextByteCount) || other.plaintextByteCount == plaintextByteCount)&&(identical(other.aadByteCount, aadByteCount) || other.aadByteCount == aadByteCount)&&(identical(other.wrote, wrote) || other.wrote == wrote)&&(identical(other.readMatched, readMatched) || other.readMatched == readMatched)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,status,reasonCode,platform,keyResidency,hardwareBacked,algorithm,verified,challengeByteCount,ciphertextByteCount,plaintextByteCount,aadByteCount,wrote,readMatched,deleted);

@override
String toString() {
  return 'NativeSecurityOperationResult(status: $status, reasonCode: $reasonCode, platform: $platform, keyResidency: $keyResidency, hardwareBacked: $hardwareBacked, algorithm: $algorithm, verified: $verified, challengeByteCount: $challengeByteCount, ciphertextByteCount: $ciphertextByteCount, plaintextByteCount: $plaintextByteCount, aadByteCount: $aadByteCount, wrote: $wrote, readMatched: $readMatched, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class $NativeSecurityOperationResultCopyWith<$Res>  {
  factory $NativeSecurityOperationResultCopyWith(NativeSecurityOperationResult value, $Res Function(NativeSecurityOperationResult) _then) = _$NativeSecurityOperationResultCopyWithImpl;
@useResult
$Res call({
 NativeSecurityStatus status, String reasonCode, String platform, NativeSecurityKeyResidency? keyResidency, bool? hardwareBacked, String? algorithm, bool? verified, int? challengeByteCount, int? ciphertextByteCount, int? plaintextByteCount, int? aadByteCount, bool? wrote, bool? readMatched, bool? deleted
});




}
/// @nodoc
class _$NativeSecurityOperationResultCopyWithImpl<$Res>
    implements $NativeSecurityOperationResultCopyWith<$Res> {
  _$NativeSecurityOperationResultCopyWithImpl(this._self, this._then);

  final NativeSecurityOperationResult _self;
  final $Res Function(NativeSecurityOperationResult) _then;

/// Create a copy of NativeSecurityOperationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? reasonCode = null,Object? platform = null,Object? keyResidency = freezed,Object? hardwareBacked = freezed,Object? algorithm = freezed,Object? verified = freezed,Object? challengeByteCount = freezed,Object? ciphertextByteCount = freezed,Object? plaintextByteCount = freezed,Object? aadByteCount = freezed,Object? wrote = freezed,Object? readMatched = freezed,Object? deleted = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeSecurityStatus,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,keyResidency: freezed == keyResidency ? _self.keyResidency : keyResidency // ignore: cast_nullable_to_non_nullable
as NativeSecurityKeyResidency?,hardwareBacked: freezed == hardwareBacked ? _self.hardwareBacked : hardwareBacked // ignore: cast_nullable_to_non_nullable
as bool?,algorithm: freezed == algorithm ? _self.algorithm : algorithm // ignore: cast_nullable_to_non_nullable
as String?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,challengeByteCount: freezed == challengeByteCount ? _self.challengeByteCount : challengeByteCount // ignore: cast_nullable_to_non_nullable
as int?,ciphertextByteCount: freezed == ciphertextByteCount ? _self.ciphertextByteCount : ciphertextByteCount // ignore: cast_nullable_to_non_nullable
as int?,plaintextByteCount: freezed == plaintextByteCount ? _self.plaintextByteCount : plaintextByteCount // ignore: cast_nullable_to_non_nullable
as int?,aadByteCount: freezed == aadByteCount ? _self.aadByteCount : aadByteCount // ignore: cast_nullable_to_non_nullable
as int?,wrote: freezed == wrote ? _self.wrote : wrote // ignore: cast_nullable_to_non_nullable
as bool?,readMatched: freezed == readMatched ? _self.readMatched : readMatched // ignore: cast_nullable_to_non_nullable
as bool?,deleted: freezed == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeSecurityOperationResult].
extension NativeSecurityOperationResultPatterns on NativeSecurityOperationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeSecurityOperationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeSecurityOperationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeSecurityOperationResult value)  $default,){
final _that = this;
switch (_that) {
case _NativeSecurityOperationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeSecurityOperationResult value)?  $default,){
final _that = this;
switch (_that) {
case _NativeSecurityOperationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NativeSecurityStatus status,  String reasonCode,  String platform,  NativeSecurityKeyResidency? keyResidency,  bool? hardwareBacked,  String? algorithm,  bool? verified,  int? challengeByteCount,  int? ciphertextByteCount,  int? plaintextByteCount,  int? aadByteCount,  bool? wrote,  bool? readMatched,  bool? deleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeSecurityOperationResult() when $default != null:
return $default(_that.status,_that.reasonCode,_that.platform,_that.keyResidency,_that.hardwareBacked,_that.algorithm,_that.verified,_that.challengeByteCount,_that.ciphertextByteCount,_that.plaintextByteCount,_that.aadByteCount,_that.wrote,_that.readMatched,_that.deleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NativeSecurityStatus status,  String reasonCode,  String platform,  NativeSecurityKeyResidency? keyResidency,  bool? hardwareBacked,  String? algorithm,  bool? verified,  int? challengeByteCount,  int? ciphertextByteCount,  int? plaintextByteCount,  int? aadByteCount,  bool? wrote,  bool? readMatched,  bool? deleted)  $default,) {final _that = this;
switch (_that) {
case _NativeSecurityOperationResult():
return $default(_that.status,_that.reasonCode,_that.platform,_that.keyResidency,_that.hardwareBacked,_that.algorithm,_that.verified,_that.challengeByteCount,_that.ciphertextByteCount,_that.plaintextByteCount,_that.aadByteCount,_that.wrote,_that.readMatched,_that.deleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NativeSecurityStatus status,  String reasonCode,  String platform,  NativeSecurityKeyResidency? keyResidency,  bool? hardwareBacked,  String? algorithm,  bool? verified,  int? challengeByteCount,  int? ciphertextByteCount,  int? plaintextByteCount,  int? aadByteCount,  bool? wrote,  bool? readMatched,  bool? deleted)?  $default,) {final _that = this;
switch (_that) {
case _NativeSecurityOperationResult() when $default != null:
return $default(_that.status,_that.reasonCode,_that.platform,_that.keyResidency,_that.hardwareBacked,_that.algorithm,_that.verified,_that.challengeByteCount,_that.ciphertextByteCount,_that.plaintextByteCount,_that.aadByteCount,_that.wrote,_that.readMatched,_that.deleted);case _:
  return null;

}
}

}

/// @nodoc


class _NativeSecurityOperationResult implements NativeSecurityOperationResult {
  const _NativeSecurityOperationResult({required this.status, required this.reasonCode, required this.platform, this.keyResidency, this.hardwareBacked, this.algorithm, this.verified, this.challengeByteCount, this.ciphertextByteCount, this.plaintextByteCount, this.aadByteCount, this.wrote, this.readMatched, this.deleted});
  

@override final  NativeSecurityStatus status;
@override final  String reasonCode;
@override final  String platform;
@override final  NativeSecurityKeyResidency? keyResidency;
@override final  bool? hardwareBacked;
@override final  String? algorithm;
@override final  bool? verified;
@override final  int? challengeByteCount;
@override final  int? ciphertextByteCount;
@override final  int? plaintextByteCount;
@override final  int? aadByteCount;
@override final  bool? wrote;
@override final  bool? readMatched;
@override final  bool? deleted;

/// Create a copy of NativeSecurityOperationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeSecurityOperationResultCopyWith<_NativeSecurityOperationResult> get copyWith => __$NativeSecurityOperationResultCopyWithImpl<_NativeSecurityOperationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeSecurityOperationResult&&(identical(other.status, status) || other.status == status)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.keyResidency, keyResidency) || other.keyResidency == keyResidency)&&(identical(other.hardwareBacked, hardwareBacked) || other.hardwareBacked == hardwareBacked)&&(identical(other.algorithm, algorithm) || other.algorithm == algorithm)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.challengeByteCount, challengeByteCount) || other.challengeByteCount == challengeByteCount)&&(identical(other.ciphertextByteCount, ciphertextByteCount) || other.ciphertextByteCount == ciphertextByteCount)&&(identical(other.plaintextByteCount, plaintextByteCount) || other.plaintextByteCount == plaintextByteCount)&&(identical(other.aadByteCount, aadByteCount) || other.aadByteCount == aadByteCount)&&(identical(other.wrote, wrote) || other.wrote == wrote)&&(identical(other.readMatched, readMatched) || other.readMatched == readMatched)&&(identical(other.deleted, deleted) || other.deleted == deleted));
}


@override
int get hashCode => Object.hash(runtimeType,status,reasonCode,platform,keyResidency,hardwareBacked,algorithm,verified,challengeByteCount,ciphertextByteCount,plaintextByteCount,aadByteCount,wrote,readMatched,deleted);

@override
String toString() {
  return 'NativeSecurityOperationResult(status: $status, reasonCode: $reasonCode, platform: $platform, keyResidency: $keyResidency, hardwareBacked: $hardwareBacked, algorithm: $algorithm, verified: $verified, challengeByteCount: $challengeByteCount, ciphertextByteCount: $ciphertextByteCount, plaintextByteCount: $plaintextByteCount, aadByteCount: $aadByteCount, wrote: $wrote, readMatched: $readMatched, deleted: $deleted)';
}


}

/// @nodoc
abstract mixin class _$NativeSecurityOperationResultCopyWith<$Res> implements $NativeSecurityOperationResultCopyWith<$Res> {
  factory _$NativeSecurityOperationResultCopyWith(_NativeSecurityOperationResult value, $Res Function(_NativeSecurityOperationResult) _then) = __$NativeSecurityOperationResultCopyWithImpl;
@override @useResult
$Res call({
 NativeSecurityStatus status, String reasonCode, String platform, NativeSecurityKeyResidency? keyResidency, bool? hardwareBacked, String? algorithm, bool? verified, int? challengeByteCount, int? ciphertextByteCount, int? plaintextByteCount, int? aadByteCount, bool? wrote, bool? readMatched, bool? deleted
});




}
/// @nodoc
class __$NativeSecurityOperationResultCopyWithImpl<$Res>
    implements _$NativeSecurityOperationResultCopyWith<$Res> {
  __$NativeSecurityOperationResultCopyWithImpl(this._self, this._then);

  final _NativeSecurityOperationResult _self;
  final $Res Function(_NativeSecurityOperationResult) _then;

/// Create a copy of NativeSecurityOperationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? reasonCode = null,Object? platform = null,Object? keyResidency = freezed,Object? hardwareBacked = freezed,Object? algorithm = freezed,Object? verified = freezed,Object? challengeByteCount = freezed,Object? ciphertextByteCount = freezed,Object? plaintextByteCount = freezed,Object? aadByteCount = freezed,Object? wrote = freezed,Object? readMatched = freezed,Object? deleted = freezed,}) {
  return _then(_NativeSecurityOperationResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeSecurityStatus,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,keyResidency: freezed == keyResidency ? _self.keyResidency : keyResidency // ignore: cast_nullable_to_non_nullable
as NativeSecurityKeyResidency?,hardwareBacked: freezed == hardwareBacked ? _self.hardwareBacked : hardwareBacked // ignore: cast_nullable_to_non_nullable
as bool?,algorithm: freezed == algorithm ? _self.algorithm : algorithm // ignore: cast_nullable_to_non_nullable
as String?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool?,challengeByteCount: freezed == challengeByteCount ? _self.challengeByteCount : challengeByteCount // ignore: cast_nullable_to_non_nullable
as int?,ciphertextByteCount: freezed == ciphertextByteCount ? _self.ciphertextByteCount : ciphertextByteCount // ignore: cast_nullable_to_non_nullable
as int?,plaintextByteCount: freezed == plaintextByteCount ? _self.plaintextByteCount : plaintextByteCount // ignore: cast_nullable_to_non_nullable
as int?,aadByteCount: freezed == aadByteCount ? _self.aadByteCount : aadByteCount // ignore: cast_nullable_to_non_nullable
as int?,wrote: freezed == wrote ? _self.wrote : wrote // ignore: cast_nullable_to_non_nullable
as bool?,readMatched: freezed == readMatched ? _self.readMatched : readMatched // ignore: cast_nullable_to_non_nullable
as bool?,deleted: freezed == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
