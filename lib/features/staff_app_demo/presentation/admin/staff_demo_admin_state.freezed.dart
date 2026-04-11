// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_admin_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoAdminState {

 StaffDemoAdminStatus get status; List<StaffDemoTimeEntrySummary> get recentEntries; String? get errorMessage;
/// Create a copy of StaffDemoAdminState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoAdminStateCopyWith<StaffDemoAdminState> get copyWith => _$StaffDemoAdminStateCopyWithImpl<StaffDemoAdminState>(this as StaffDemoAdminState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoAdminState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.recentEntries, recentEntries)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(recentEntries),errorMessage);

@override
String toString() {
  return 'StaffDemoAdminState(status: $status, recentEntries: $recentEntries, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $StaffDemoAdminStateCopyWith<$Res>  {
  factory $StaffDemoAdminStateCopyWith(StaffDemoAdminState value, $Res Function(StaffDemoAdminState) _then) = _$StaffDemoAdminStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoAdminStatus status, List<StaffDemoTimeEntrySummary> recentEntries, String? errorMessage
});




}
/// @nodoc
class _$StaffDemoAdminStateCopyWithImpl<$Res>
    implements $StaffDemoAdminStateCopyWith<$Res> {
  _$StaffDemoAdminStateCopyWithImpl(this._self, this._then);

  final StaffDemoAdminState _self;
  final $Res Function(StaffDemoAdminState) _then;

/// Create a copy of StaffDemoAdminState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? recentEntries = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoAdminStatus,recentEntries: null == recentEntries ? _self.recentEntries : recentEntries // ignore: cast_nullable_to_non_nullable
as List<StaffDemoTimeEntrySummary>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoAdminState].
extension StaffDemoAdminStatePatterns on StaffDemoAdminState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoAdminState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoAdminState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoAdminState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoAdminState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoAdminState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoAdminState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoAdminStatus status,  List<StaffDemoTimeEntrySummary> recentEntries,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoAdminState() when $default != null:
return $default(_that.status,_that.recentEntries,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoAdminStatus status,  List<StaffDemoTimeEntrySummary> recentEntries,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoAdminState():
return $default(_that.status,_that.recentEntries,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoAdminStatus status,  List<StaffDemoTimeEntrySummary> recentEntries,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoAdminState() when $default != null:
return $default(_that.status,_that.recentEntries,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoAdminState implements StaffDemoAdminState {
  const _StaffDemoAdminState({this.status = StaffDemoAdminStatus.initial, final  List<StaffDemoTimeEntrySummary> recentEntries = const <StaffDemoTimeEntrySummary>[], this.errorMessage}): _recentEntries = recentEntries;
  

@override@JsonKey() final  StaffDemoAdminStatus status;
 final  List<StaffDemoTimeEntrySummary> _recentEntries;
@override@JsonKey() List<StaffDemoTimeEntrySummary> get recentEntries {
  if (_recentEntries is EqualUnmodifiableListView) return _recentEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentEntries);
}

@override final  String? errorMessage;

/// Create a copy of StaffDemoAdminState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoAdminStateCopyWith<_StaffDemoAdminState> get copyWith => __$StaffDemoAdminStateCopyWithImpl<_StaffDemoAdminState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoAdminState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._recentEntries, _recentEntries)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_recentEntries),errorMessage);

@override
String toString() {
  return 'StaffDemoAdminState(status: $status, recentEntries: $recentEntries, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoAdminStateCopyWith<$Res> implements $StaffDemoAdminStateCopyWith<$Res> {
  factory _$StaffDemoAdminStateCopyWith(_StaffDemoAdminState value, $Res Function(_StaffDemoAdminState) _then) = __$StaffDemoAdminStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoAdminStatus status, List<StaffDemoTimeEntrySummary> recentEntries, String? errorMessage
});




}
/// @nodoc
class __$StaffDemoAdminStateCopyWithImpl<$Res>
    implements _$StaffDemoAdminStateCopyWith<$Res> {
  __$StaffDemoAdminStateCopyWithImpl(this._self, this._then);

  final _StaffDemoAdminState _self;
  final $Res Function(_StaffDemoAdminState) _then;

/// Create a copy of StaffDemoAdminState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? recentEntries = null,Object? errorMessage = freezed,}) {
  return _then(_StaffDemoAdminState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoAdminStatus,recentEntries: null == recentEntries ? _self._recentEntries : recentEntries // ignore: cast_nullable_to_non_nullable
as List<StaffDemoTimeEntrySummary>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
