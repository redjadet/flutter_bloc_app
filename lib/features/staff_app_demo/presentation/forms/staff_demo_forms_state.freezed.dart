// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_forms_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoFormsState {

 StaffDemoFormsStatus get status; String? get errorMessage; String? get lastSubmitLabel;
/// Create a copy of StaffDemoFormsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoFormsStateCopyWith<StaffDemoFormsState> get copyWith => _$StaffDemoFormsStateCopyWithImpl<StaffDemoFormsState>(this as StaffDemoFormsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoFormsState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastSubmitLabel, lastSubmitLabel) || other.lastSubmitLabel == lastSubmitLabel));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,lastSubmitLabel);

@override
String toString() {
  return 'StaffDemoFormsState(status: $status, errorMessage: $errorMessage, lastSubmitLabel: $lastSubmitLabel)';
}


}

/// @nodoc
abstract mixin class $StaffDemoFormsStateCopyWith<$Res>  {
  factory $StaffDemoFormsStateCopyWith(StaffDemoFormsState value, $Res Function(StaffDemoFormsState) _then) = _$StaffDemoFormsStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoFormsStatus status, String? errorMessage, String? lastSubmitLabel
});




}
/// @nodoc
class _$StaffDemoFormsStateCopyWithImpl<$Res>
    implements $StaffDemoFormsStateCopyWith<$Res> {
  _$StaffDemoFormsStateCopyWithImpl(this._self, this._then);

  final StaffDemoFormsState _self;
  final $Res Function(StaffDemoFormsState) _then;

/// Create a copy of StaffDemoFormsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? lastSubmitLabel = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoFormsStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastSubmitLabel: freezed == lastSubmitLabel ? _self.lastSubmitLabel : lastSubmitLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoFormsState].
extension StaffDemoFormsStatePatterns on StaffDemoFormsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoFormsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoFormsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoFormsState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoFormsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoFormsState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoFormsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoFormsStatus status,  String? errorMessage,  String? lastSubmitLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoFormsState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.lastSubmitLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoFormsStatus status,  String? errorMessage,  String? lastSubmitLabel)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoFormsState():
return $default(_that.status,_that.errorMessage,_that.lastSubmitLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoFormsStatus status,  String? errorMessage,  String? lastSubmitLabel)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoFormsState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.lastSubmitLabel);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoFormsState implements StaffDemoFormsState {
  const _StaffDemoFormsState({this.status = StaffDemoFormsStatus.initial, this.errorMessage, this.lastSubmitLabel});
  

@override@JsonKey() final  StaffDemoFormsStatus status;
@override final  String? errorMessage;
@override final  String? lastSubmitLabel;

/// Create a copy of StaffDemoFormsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoFormsStateCopyWith<_StaffDemoFormsState> get copyWith => __$StaffDemoFormsStateCopyWithImpl<_StaffDemoFormsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoFormsState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastSubmitLabel, lastSubmitLabel) || other.lastSubmitLabel == lastSubmitLabel));
}


@override
int get hashCode => Object.hash(runtimeType,status,errorMessage,lastSubmitLabel);

@override
String toString() {
  return 'StaffDemoFormsState(status: $status, errorMessage: $errorMessage, lastSubmitLabel: $lastSubmitLabel)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoFormsStateCopyWith<$Res> implements $StaffDemoFormsStateCopyWith<$Res> {
  factory _$StaffDemoFormsStateCopyWith(_StaffDemoFormsState value, $Res Function(_StaffDemoFormsState) _then) = __$StaffDemoFormsStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoFormsStatus status, String? errorMessage, String? lastSubmitLabel
});




}
/// @nodoc
class __$StaffDemoFormsStateCopyWithImpl<$Res>
    implements _$StaffDemoFormsStateCopyWith<$Res> {
  __$StaffDemoFormsStateCopyWithImpl(this._self, this._then);

  final _StaffDemoFormsState _self;
  final $Res Function(_StaffDemoFormsState) _then;

/// Create a copy of StaffDemoFormsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? lastSubmitLabel = freezed,}) {
  return _then(_StaffDemoFormsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoFormsStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastSubmitLabel: freezed == lastSubmitLabel ? _self.lastSubmitLabel : lastSubmitLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
