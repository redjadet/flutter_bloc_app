// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_timeclock_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoTimeclockState {

 StaffDemoTimeclockStatus get status; String? get openEntryId; StaffDemoClockResult? get lastResult; String? get errorMessage;
/// Create a copy of StaffDemoTimeclockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoTimeclockStateCopyWith<StaffDemoTimeclockState> get copyWith => _$StaffDemoTimeclockStateCopyWithImpl<StaffDemoTimeclockState>(this as StaffDemoTimeclockState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoTimeclockState&&(identical(other.status, status) || other.status == status)&&(identical(other.openEntryId, openEntryId) || other.openEntryId == openEntryId)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,openEntryId,lastResult,errorMessage);

@override
String toString() {
  return 'StaffDemoTimeclockState(status: $status, openEntryId: $openEntryId, lastResult: $lastResult, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $StaffDemoTimeclockStateCopyWith<$Res>  {
  factory $StaffDemoTimeclockStateCopyWith(StaffDemoTimeclockState value, $Res Function(StaffDemoTimeclockState) _then) = _$StaffDemoTimeclockStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoTimeclockStatus status, String? openEntryId, StaffDemoClockResult? lastResult, String? errorMessage
});




}
/// @nodoc
class _$StaffDemoTimeclockStateCopyWithImpl<$Res>
    implements $StaffDemoTimeclockStateCopyWith<$Res> {
  _$StaffDemoTimeclockStateCopyWithImpl(this._self, this._then);

  final StaffDemoTimeclockState _self;
  final $Res Function(StaffDemoTimeclockState) _then;

/// Create a copy of StaffDemoTimeclockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? openEntryId = freezed,Object? lastResult = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoTimeclockStatus,openEntryId: freezed == openEntryId ? _self.openEntryId : openEntryId // ignore: cast_nullable_to_non_nullable
as String?,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as StaffDemoClockResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoTimeclockState].
extension StaffDemoTimeclockStatePatterns on StaffDemoTimeclockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoTimeclockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoTimeclockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoTimeclockState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoTimeclockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoTimeclockState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoTimeclockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoTimeclockStatus status,  String? openEntryId,  StaffDemoClockResult? lastResult,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoTimeclockState() when $default != null:
return $default(_that.status,_that.openEntryId,_that.lastResult,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoTimeclockStatus status,  String? openEntryId,  StaffDemoClockResult? lastResult,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoTimeclockState():
return $default(_that.status,_that.openEntryId,_that.lastResult,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoTimeclockStatus status,  String? openEntryId,  StaffDemoClockResult? lastResult,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoTimeclockState() when $default != null:
return $default(_that.status,_that.openEntryId,_that.lastResult,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoTimeclockState implements StaffDemoTimeclockState {
  const _StaffDemoTimeclockState({this.status = StaffDemoTimeclockStatus.initial, this.openEntryId, this.lastResult, this.errorMessage});
  

@override@JsonKey() final  StaffDemoTimeclockStatus status;
@override final  String? openEntryId;
@override final  StaffDemoClockResult? lastResult;
@override final  String? errorMessage;

/// Create a copy of StaffDemoTimeclockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoTimeclockStateCopyWith<_StaffDemoTimeclockState> get copyWith => __$StaffDemoTimeclockStateCopyWithImpl<_StaffDemoTimeclockState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoTimeclockState&&(identical(other.status, status) || other.status == status)&&(identical(other.openEntryId, openEntryId) || other.openEntryId == openEntryId)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,openEntryId,lastResult,errorMessage);

@override
String toString() {
  return 'StaffDemoTimeclockState(status: $status, openEntryId: $openEntryId, lastResult: $lastResult, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoTimeclockStateCopyWith<$Res> implements $StaffDemoTimeclockStateCopyWith<$Res> {
  factory _$StaffDemoTimeclockStateCopyWith(_StaffDemoTimeclockState value, $Res Function(_StaffDemoTimeclockState) _then) = __$StaffDemoTimeclockStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoTimeclockStatus status, String? openEntryId, StaffDemoClockResult? lastResult, String? errorMessage
});




}
/// @nodoc
class __$StaffDemoTimeclockStateCopyWithImpl<$Res>
    implements _$StaffDemoTimeclockStateCopyWith<$Res> {
  __$StaffDemoTimeclockStateCopyWithImpl(this._self, this._then);

  final _StaffDemoTimeclockState _self;
  final $Res Function(_StaffDemoTimeclockState) _then;

/// Create a copy of StaffDemoTimeclockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? openEntryId = freezed,Object? lastResult = freezed,Object? errorMessage = freezed,}) {
  return _then(_StaffDemoTimeclockState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoTimeclockStatus,openEntryId: freezed == openEntryId ? _self.openEntryId : openEntryId // ignore: cast_nullable_to_non_nullable
as String?,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as StaffDemoClockResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
