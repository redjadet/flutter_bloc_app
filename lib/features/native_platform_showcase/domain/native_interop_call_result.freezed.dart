// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'native_interop_call_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NativeInteropCallResult {

 NativeInteropBridgeKind get kind; NativeInteropStatus get status; String get message;
/// Create a copy of NativeInteropCallResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NativeInteropCallResultCopyWith<NativeInteropCallResult> get copyWith => _$NativeInteropCallResultCopyWithImpl<NativeInteropCallResult>(this as NativeInteropCallResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NativeInteropCallResult&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,kind,status,message);

@override
String toString() {
  return 'NativeInteropCallResult(kind: $kind, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class $NativeInteropCallResultCopyWith<$Res>  {
  factory $NativeInteropCallResultCopyWith(NativeInteropCallResult value, $Res Function(NativeInteropCallResult) _then) = _$NativeInteropCallResultCopyWithImpl;
@useResult
$Res call({
 NativeInteropBridgeKind kind, NativeInteropStatus status, String message
});




}
/// @nodoc
class _$NativeInteropCallResultCopyWithImpl<$Res>
    implements $NativeInteropCallResultCopyWith<$Res> {
  _$NativeInteropCallResultCopyWithImpl(this._self, this._then);

  final NativeInteropCallResult _self;
  final $Res Function(NativeInteropCallResult) _then;

/// Create a copy of NativeInteropCallResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? status = null,Object? message = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NativeInteropBridgeKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeInteropStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NativeInteropCallResult].
extension NativeInteropCallResultPatterns on NativeInteropCallResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NativeInteropCallResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NativeInteropCallResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NativeInteropCallResult value)  $default,){
final _that = this;
switch (_that) {
case _NativeInteropCallResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NativeInteropCallResult value)?  $default,){
final _that = this;
switch (_that) {
case _NativeInteropCallResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NativeInteropBridgeKind kind,  NativeInteropStatus status,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NativeInteropCallResult() when $default != null:
return $default(_that.kind,_that.status,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NativeInteropBridgeKind kind,  NativeInteropStatus status,  String message)  $default,) {final _that = this;
switch (_that) {
case _NativeInteropCallResult():
return $default(_that.kind,_that.status,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NativeInteropBridgeKind kind,  NativeInteropStatus status,  String message)?  $default,) {final _that = this;
switch (_that) {
case _NativeInteropCallResult() when $default != null:
return $default(_that.kind,_that.status,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _NativeInteropCallResult implements NativeInteropCallResult {
  const _NativeInteropCallResult({required this.kind, required this.status, required this.message});
  

@override final  NativeInteropBridgeKind kind;
@override final  NativeInteropStatus status;
@override final  String message;

/// Create a copy of NativeInteropCallResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NativeInteropCallResultCopyWith<_NativeInteropCallResult> get copyWith => __$NativeInteropCallResultCopyWithImpl<_NativeInteropCallResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NativeInteropCallResult&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,kind,status,message);

@override
String toString() {
  return 'NativeInteropCallResult(kind: $kind, status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class _$NativeInteropCallResultCopyWith<$Res> implements $NativeInteropCallResultCopyWith<$Res> {
  factory _$NativeInteropCallResultCopyWith(_NativeInteropCallResult value, $Res Function(_NativeInteropCallResult) _then) = __$NativeInteropCallResultCopyWithImpl;
@override @useResult
$Res call({
 NativeInteropBridgeKind kind, NativeInteropStatus status, String message
});




}
/// @nodoc
class __$NativeInteropCallResultCopyWithImpl<$Res>
    implements _$NativeInteropCallResultCopyWith<$Res> {
  __$NativeInteropCallResultCopyWithImpl(this._self, this._then);

  final _NativeInteropCallResult _self;
  final $Res Function(_NativeInteropCallResult) _then;

/// Create a copy of NativeInteropCallResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? status = null,Object? message = null,}) {
  return _then(_NativeInteropCallResult(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as NativeInteropBridgeKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NativeInteropStatus,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
