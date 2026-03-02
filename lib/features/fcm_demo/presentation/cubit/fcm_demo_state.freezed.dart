// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fcm_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FcmDemoState {

 FcmDemoStatus get status; FcmPermissionState get permissionState; String? get fcmToken; String? get apnsToken; PushMessage? get lastMessage; String? get errorMessage;
/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FcmDemoStateCopyWith<FcmDemoState> get copyWith => _$FcmDemoStateCopyWithImpl<FcmDemoState>(this as FcmDemoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FcmDemoState&&(identical(other.status, status) || other.status == status)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.apnsToken, apnsToken) || other.apnsToken == apnsToken)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,permissionState,fcmToken,apnsToken,lastMessage,errorMessage);

@override
String toString() {
  return 'FcmDemoState(status: $status, permissionState: $permissionState, fcmToken: $fcmToken, apnsToken: $apnsToken, lastMessage: $lastMessage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FcmDemoStateCopyWith<$Res>  {
  factory $FcmDemoStateCopyWith(FcmDemoState value, $Res Function(FcmDemoState) _then) = _$FcmDemoStateCopyWithImpl;
@useResult
$Res call({
 FcmDemoStatus status, FcmPermissionState permissionState, String? fcmToken, String? apnsToken, PushMessage? lastMessage, String? errorMessage
});


$PushMessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$FcmDemoStateCopyWithImpl<$Res>
    implements $FcmDemoStateCopyWith<$Res> {
  _$FcmDemoStateCopyWithImpl(this._self, this._then);

  final FcmDemoState _self;
  final $Res Function(FcmDemoState) _then;

/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? permissionState = null,Object? fcmToken = freezed,Object? apnsToken = freezed,Object? lastMessage = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FcmDemoStatus,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as FcmPermissionState,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,apnsToken: freezed == apnsToken ? _self.apnsToken : apnsToken // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as PushMessage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushMessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $PushMessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [FcmDemoState].
extension FcmDemoStatePatterns on FcmDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FcmDemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FcmDemoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FcmDemoState value)  $default,){
final _that = this;
switch (_that) {
case _FcmDemoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FcmDemoState value)?  $default,){
final _that = this;
switch (_that) {
case _FcmDemoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FcmDemoStatus status,  FcmPermissionState permissionState,  String? fcmToken,  String? apnsToken,  PushMessage? lastMessage,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FcmDemoState() when $default != null:
return $default(_that.status,_that.permissionState,_that.fcmToken,_that.apnsToken,_that.lastMessage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FcmDemoStatus status,  FcmPermissionState permissionState,  String? fcmToken,  String? apnsToken,  PushMessage? lastMessage,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FcmDemoState():
return $default(_that.status,_that.permissionState,_that.fcmToken,_that.apnsToken,_that.lastMessage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FcmDemoStatus status,  FcmPermissionState permissionState,  String? fcmToken,  String? apnsToken,  PushMessage? lastMessage,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FcmDemoState() when $default != null:
return $default(_that.status,_that.permissionState,_that.fcmToken,_that.apnsToken,_that.lastMessage,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FcmDemoState implements FcmDemoState {
  const _FcmDemoState({this.status = FcmDemoStatus.initial, this.permissionState = FcmPermissionState.notDetermined, this.fcmToken, this.apnsToken, this.lastMessage, this.errorMessage});
  

@override@JsonKey() final  FcmDemoStatus status;
@override@JsonKey() final  FcmPermissionState permissionState;
@override final  String? fcmToken;
@override final  String? apnsToken;
@override final  PushMessage? lastMessage;
@override final  String? errorMessage;

/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FcmDemoStateCopyWith<_FcmDemoState> get copyWith => __$FcmDemoStateCopyWithImpl<_FcmDemoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FcmDemoState&&(identical(other.status, status) || other.status == status)&&(identical(other.permissionState, permissionState) || other.permissionState == permissionState)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.apnsToken, apnsToken) || other.apnsToken == apnsToken)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,permissionState,fcmToken,apnsToken,lastMessage,errorMessage);

@override
String toString() {
  return 'FcmDemoState(status: $status, permissionState: $permissionState, fcmToken: $fcmToken, apnsToken: $apnsToken, lastMessage: $lastMessage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FcmDemoStateCopyWith<$Res> implements $FcmDemoStateCopyWith<$Res> {
  factory _$FcmDemoStateCopyWith(_FcmDemoState value, $Res Function(_FcmDemoState) _then) = __$FcmDemoStateCopyWithImpl;
@override @useResult
$Res call({
 FcmDemoStatus status, FcmPermissionState permissionState, String? fcmToken, String? apnsToken, PushMessage? lastMessage, String? errorMessage
});


@override $PushMessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$FcmDemoStateCopyWithImpl<$Res>
    implements _$FcmDemoStateCopyWith<$Res> {
  __$FcmDemoStateCopyWithImpl(this._self, this._then);

  final _FcmDemoState _self;
  final $Res Function(_FcmDemoState) _then;

/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? permissionState = null,Object? fcmToken = freezed,Object? apnsToken = freezed,Object? lastMessage = freezed,Object? errorMessage = freezed,}) {
  return _then(_FcmDemoState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FcmDemoStatus,permissionState: null == permissionState ? _self.permissionState : permissionState // ignore: cast_nullable_to_non_nullable
as FcmPermissionState,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,apnsToken: freezed == apnsToken ? _self.apnsToken : apnsToken // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as PushMessage?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FcmDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PushMessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $PushMessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}

// dart format on
