// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoSessionState {

 StaffDemoSessionStatus get status; StaffDemoProfile? get profile; String? get errorMessage;
/// Create a copy of StaffDemoSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoSessionStateCopyWith<StaffDemoSessionState> get copyWith => _$StaffDemoSessionStateCopyWithImpl<StaffDemoSessionState>(this as StaffDemoSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoSessionState&&(identical(other.status, status) || other.status == status)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,profile,errorMessage);

@override
String toString() {
  return 'StaffDemoSessionState(status: $status, profile: $profile, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $StaffDemoSessionStateCopyWith<$Res>  {
  factory $StaffDemoSessionStateCopyWith(StaffDemoSessionState value, $Res Function(StaffDemoSessionState) _then) = _$StaffDemoSessionStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoSessionStatus status, StaffDemoProfile? profile, String? errorMessage
});




}
/// @nodoc
class _$StaffDemoSessionStateCopyWithImpl<$Res>
    implements $StaffDemoSessionStateCopyWith<$Res> {
  _$StaffDemoSessionStateCopyWithImpl(this._self, this._then);

  final StaffDemoSessionState _self;
  final $Res Function(StaffDemoSessionState) _then;

/// Create a copy of StaffDemoSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? profile = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoSessionStatus,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as StaffDemoProfile?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoSessionState].
extension StaffDemoSessionStatePatterns on StaffDemoSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoSessionState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoSessionStatus status,  StaffDemoProfile? profile,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoSessionState() when $default != null:
return $default(_that.status,_that.profile,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoSessionStatus status,  StaffDemoProfile? profile,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoSessionState():
return $default(_that.status,_that.profile,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoSessionStatus status,  StaffDemoProfile? profile,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoSessionState() when $default != null:
return $default(_that.status,_that.profile,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoSessionState implements StaffDemoSessionState {
  const _StaffDemoSessionState({this.status = StaffDemoSessionStatus.initial, this.profile, this.errorMessage});
  

@override@JsonKey() final  StaffDemoSessionStatus status;
@override final  StaffDemoProfile? profile;
@override final  String? errorMessage;

/// Create a copy of StaffDemoSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoSessionStateCopyWith<_StaffDemoSessionState> get copyWith => __$StaffDemoSessionStateCopyWithImpl<_StaffDemoSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoSessionState&&(identical(other.status, status) || other.status == status)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,profile,errorMessage);

@override
String toString() {
  return 'StaffDemoSessionState(status: $status, profile: $profile, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoSessionStateCopyWith<$Res> implements $StaffDemoSessionStateCopyWith<$Res> {
  factory _$StaffDemoSessionStateCopyWith(_StaffDemoSessionState value, $Res Function(_StaffDemoSessionState) _then) = __$StaffDemoSessionStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoSessionStatus status, StaffDemoProfile? profile, String? errorMessage
});




}
/// @nodoc
class __$StaffDemoSessionStateCopyWithImpl<$Res>
    implements _$StaffDemoSessionStateCopyWith<$Res> {
  __$StaffDemoSessionStateCopyWithImpl(this._self, this._then);

  final _StaffDemoSessionState _self;
  final $Res Function(_StaffDemoSessionState) _then;

/// Create a copy of StaffDemoSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? profile = freezed,Object? errorMessage = freezed,}) {
  return _then(_StaffDemoSessionState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoSessionStatus,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as StaffDemoProfile?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
