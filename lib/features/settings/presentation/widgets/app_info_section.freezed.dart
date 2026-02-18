// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_info_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppInfoViewData {

 bool get showSuccess; bool get showError; AppInfo? get info; String? get errorMessage;
/// Create a copy of _AppInfoViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppInfoViewDataCopyWith<_AppInfoViewData> get copyWith => __$AppInfoViewDataCopyWithImpl<_AppInfoViewData>(this as _AppInfoViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppInfoViewData&&(identical(other.showSuccess, showSuccess) || other.showSuccess == showSuccess)&&(identical(other.showError, showError) || other.showError == showError)&&(identical(other.info, info) || other.info == info)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,showSuccess,showError,info,errorMessage);

@override
String toString() {
  return '_AppInfoViewData(showSuccess: $showSuccess, showError: $showError, info: $info, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AppInfoViewDataCopyWith<$Res>  {
  factory _$AppInfoViewDataCopyWith(_AppInfoViewData value, $Res Function(_AppInfoViewData) _then) = __$AppInfoViewDataCopyWithImpl;
@useResult
$Res call({
 bool showSuccess, bool showError, AppInfo? info, String? errorMessage
});


$AppInfoCopyWith<$Res>? get info;

}
/// @nodoc
class __$AppInfoViewDataCopyWithImpl<$Res>
    implements _$AppInfoViewDataCopyWith<$Res> {
  __$AppInfoViewDataCopyWithImpl(this._self, this._then);

  final _AppInfoViewData _self;
  final $Res Function(_AppInfoViewData) _then;

/// Create a copy of _AppInfoViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showSuccess = null,Object? showError = null,Object? info = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
showSuccess: null == showSuccess ? _self.showSuccess : showSuccess // ignore: cast_nullable_to_non_nullable
as bool,showError: null == showError ? _self.showError : showError // ignore: cast_nullable_to_non_nullable
as bool,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AppInfo?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of _AppInfoViewData
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


/// Adds pattern-matching-related methods to [_AppInfoViewData].
extension _AppInfoViewDataPatterns on _AppInfoViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __AppInfoViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __AppInfoViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __AppInfoViewData value)  $default,){
final _that = this;
switch (_that) {
case __AppInfoViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __AppInfoViewData value)?  $default,){
final _that = this;
switch (_that) {
case __AppInfoViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showSuccess,  bool showError,  AppInfo? info,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __AppInfoViewData() when $default != null:
return $default(_that.showSuccess,_that.showError,_that.info,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showSuccess,  bool showError,  AppInfo? info,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case __AppInfoViewData():
return $default(_that.showSuccess,_that.showError,_that.info,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showSuccess,  bool showError,  AppInfo? info,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case __AppInfoViewData() when $default != null:
return $default(_that.showSuccess,_that.showError,_that.info,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class __AppInfoViewData implements _AppInfoViewData {
  const __AppInfoViewData({required this.showSuccess, required this.showError, required this.info, required this.errorMessage});
  

@override final  bool showSuccess;
@override final  bool showError;
@override final  AppInfo? info;
@override final  String? errorMessage;

/// Create a copy of _AppInfoViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_AppInfoViewDataCopyWith<__AppInfoViewData> get copyWith => __$_AppInfoViewDataCopyWithImpl<__AppInfoViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __AppInfoViewData&&(identical(other.showSuccess, showSuccess) || other.showSuccess == showSuccess)&&(identical(other.showError, showError) || other.showError == showError)&&(identical(other.info, info) || other.info == info)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,showSuccess,showError,info,errorMessage);

@override
String toString() {
  return '_AppInfoViewData(showSuccess: $showSuccess, showError: $showError, info: $info, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$_AppInfoViewDataCopyWith<$Res> implements _$AppInfoViewDataCopyWith<$Res> {
  factory _$_AppInfoViewDataCopyWith(__AppInfoViewData value, $Res Function(__AppInfoViewData) _then) = __$_AppInfoViewDataCopyWithImpl;
@override @useResult
$Res call({
 bool showSuccess, bool showError, AppInfo? info, String? errorMessage
});


@override $AppInfoCopyWith<$Res>? get info;

}
/// @nodoc
class __$_AppInfoViewDataCopyWithImpl<$Res>
    implements _$_AppInfoViewDataCopyWith<$Res> {
  __$_AppInfoViewDataCopyWithImpl(this._self, this._then);

  final __AppInfoViewData _self;
  final $Res Function(__AppInfoViewData) _then;

/// Create a copy of _AppInfoViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showSuccess = null,Object? showError = null,Object? info = freezed,Object? errorMessage = freezed,}) {
  return _then(__AppInfoViewData(
showSuccess: null == showSuccess ? _self.showSuccess : showSuccess // ignore: cast_nullable_to_non_nullable
as bool,showError: null == showError ? _self.showError : showError // ignore: cast_nullable_to_non_nullable
as bool,info: freezed == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AppInfo?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of _AppInfoViewData
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
