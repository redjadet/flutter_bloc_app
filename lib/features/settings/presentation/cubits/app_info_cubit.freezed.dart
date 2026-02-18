// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_info_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppInfoState {

 ViewStatus get status; AppInfo? get info; String? get errorMessage;
/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppInfoStateCopyWith<AppInfoState> get copyWith => _$AppInfoStateCopyWithImpl<AppInfoState>(this as AppInfoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppInfoState&&(identical(other.status, status) || other.status == status)&&(identical(other.info, info) || other.info == info)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,info,errorMessage);

@override
String toString() {
  return 'AppInfoState(status: $status, info: $info, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AppInfoStateCopyWith<$Res>  {
  factory $AppInfoStateCopyWith(AppInfoState value, $Res Function(AppInfoState) _then) = _$AppInfoStateCopyWithImpl;
@useResult
$Res call({
 ViewStatus status, AppInfo? info, String? errorMessage
});


$AppInfoCopyWith<$Res>? get info;

}
/// @nodoc
class _$AppInfoStateCopyWithImpl<$Res>
    implements $AppInfoStateCopyWith<$Res> {
  _$AppInfoStateCopyWithImpl(this._self, this._then);

  final AppInfoState _self;
  final $Res Function(AppInfoState) _then;

/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? info = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AppInfo?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $AppInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppInfoState].
extension AppInfoStatePatterns on AppInfoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppInfoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppInfoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppInfoState value)  $default,){
final _that = this;
switch (_that) {
case _AppInfoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppInfoState value)?  $default,){
final _that = this;
switch (_that) {
case _AppInfoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ViewStatus status,  AppInfo? info,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppInfoState() when $default != null:
return $default(_that.status,_that.info,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ViewStatus status,  AppInfo? info,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AppInfoState():
return $default(_that.status,_that.info,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ViewStatus status,  AppInfo? info,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AppInfoState() when $default != null:
return $default(_that.status,_that.info,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AppInfoState implements AppInfoState {
  const _AppInfoState({this.status = ViewStatus.initial, this.info, this.errorMessage});
  

@override@JsonKey() final  ViewStatus status;
@override final  AppInfo? info;
@override final  String? errorMessage;

/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppInfoStateCopyWith<_AppInfoState> get copyWith => __$AppInfoStateCopyWithImpl<_AppInfoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppInfoState&&(identical(other.status, status) || other.status == status)&&(identical(other.info, info) || other.info == info)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,info,errorMessage);

@override
String toString() {
  return 'AppInfoState(status: $status, info: $info, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AppInfoStateCopyWith<$Res> implements $AppInfoStateCopyWith<$Res> {
  factory _$AppInfoStateCopyWith(_AppInfoState value, $Res Function(_AppInfoState) _then) = __$AppInfoStateCopyWithImpl;
@override @useResult
$Res call({
 ViewStatus status, AppInfo? info, String? errorMessage
});


@override $AppInfoCopyWith<$Res>? get info;

}
/// @nodoc
class __$AppInfoStateCopyWithImpl<$Res>
    implements _$AppInfoStateCopyWith<$Res> {
  __$AppInfoStateCopyWithImpl(this._self, this._then);

  final _AppInfoState _self;
  final $Res Function(_AppInfoState) _then;

/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? info = freezed,Object? errorMessage = freezed,}) {
  return _then(_AppInfoState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AppInfo?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AppInfoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppInfoCopyWith<$Res>? get info {
    if (_self.info == null) {
    return null;
  }

  return $AppInfoCopyWith<$Res>(_self.info!, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

// dart format on
