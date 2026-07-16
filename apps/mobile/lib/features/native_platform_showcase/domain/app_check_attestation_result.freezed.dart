// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_check_attestation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppCheckAttestationResult {

 AppCheckAttestationStatus get status; String get providerLabel; String get reasonCode;
/// Create a copy of AppCheckAttestationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppCheckAttestationResultCopyWith<AppCheckAttestationResult> get copyWith => _$AppCheckAttestationResultCopyWithImpl<AppCheckAttestationResult>(this as AppCheckAttestationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppCheckAttestationResult&&(identical(other.status, status) || other.status == status)&&(identical(other.providerLabel, providerLabel) || other.providerLabel == providerLabel)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode));
}


@override
int get hashCode => Object.hash(runtimeType,status,providerLabel,reasonCode);

@override
String toString() {
  return 'AppCheckAttestationResult(status: $status, providerLabel: $providerLabel, reasonCode: $reasonCode)';
}


}

/// @nodoc
abstract mixin class $AppCheckAttestationResultCopyWith<$Res>  {
  factory $AppCheckAttestationResultCopyWith(AppCheckAttestationResult value, $Res Function(AppCheckAttestationResult) _then) = _$AppCheckAttestationResultCopyWithImpl;
@useResult
$Res call({
 AppCheckAttestationStatus status, String providerLabel, String reasonCode
});




}
/// @nodoc
class _$AppCheckAttestationResultCopyWithImpl<$Res>
    implements $AppCheckAttestationResultCopyWith<$Res> {
  _$AppCheckAttestationResultCopyWithImpl(this._self, this._then);

  final AppCheckAttestationResult _self;
  final $Res Function(AppCheckAttestationResult) _then;

/// Create a copy of AppCheckAttestationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? providerLabel = null,Object? reasonCode = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppCheckAttestationStatus,providerLabel: null == providerLabel ? _self.providerLabel : providerLabel // ignore: cast_nullable_to_non_nullable
as String,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppCheckAttestationResult].
extension AppCheckAttestationResultPatterns on AppCheckAttestationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppCheckAttestationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppCheckAttestationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppCheckAttestationResult value)  $default,){
final _that = this;
switch (_that) {
case _AppCheckAttestationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppCheckAttestationResult value)?  $default,){
final _that = this;
switch (_that) {
case _AppCheckAttestationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppCheckAttestationStatus status,  String providerLabel,  String reasonCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppCheckAttestationResult() when $default != null:
return $default(_that.status,_that.providerLabel,_that.reasonCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppCheckAttestationStatus status,  String providerLabel,  String reasonCode)  $default,) {final _that = this;
switch (_that) {
case _AppCheckAttestationResult():
return $default(_that.status,_that.providerLabel,_that.reasonCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppCheckAttestationStatus status,  String providerLabel,  String reasonCode)?  $default,) {final _that = this;
switch (_that) {
case _AppCheckAttestationResult() when $default != null:
return $default(_that.status,_that.providerLabel,_that.reasonCode);case _:
  return null;

}
}

}

/// @nodoc


class _AppCheckAttestationResult implements AppCheckAttestationResult {
  const _AppCheckAttestationResult({required this.status, required this.providerLabel, required this.reasonCode});
  

@override final  AppCheckAttestationStatus status;
@override final  String providerLabel;
@override final  String reasonCode;

/// Create a copy of AppCheckAttestationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppCheckAttestationResultCopyWith<_AppCheckAttestationResult> get copyWith => __$AppCheckAttestationResultCopyWithImpl<_AppCheckAttestationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppCheckAttestationResult&&(identical(other.status, status) || other.status == status)&&(identical(other.providerLabel, providerLabel) || other.providerLabel == providerLabel)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode));
}


@override
int get hashCode => Object.hash(runtimeType,status,providerLabel,reasonCode);

@override
String toString() {
  return 'AppCheckAttestationResult(status: $status, providerLabel: $providerLabel, reasonCode: $reasonCode)';
}


}

/// @nodoc
abstract mixin class _$AppCheckAttestationResultCopyWith<$Res> implements $AppCheckAttestationResultCopyWith<$Res> {
  factory _$AppCheckAttestationResultCopyWith(_AppCheckAttestationResult value, $Res Function(_AppCheckAttestationResult) _then) = __$AppCheckAttestationResultCopyWithImpl;
@override @useResult
$Res call({
 AppCheckAttestationStatus status, String providerLabel, String reasonCode
});




}
/// @nodoc
class __$AppCheckAttestationResultCopyWithImpl<$Res>
    implements _$AppCheckAttestationResultCopyWith<$Res> {
  __$AppCheckAttestationResultCopyWithImpl(this._self, this._then);

  final _AppCheckAttestationResult _self;
  final $Res Function(_AppCheckAttestationResult) _then;

/// Create a copy of AppCheckAttestationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? providerLabel = null,Object? reasonCode = null,}) {
  return _then(_AppCheckAttestationResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppCheckAttestationStatus,providerLabel: null == providerLabel ? _self.providerLabel : providerLabel // ignore: cast_nullable_to_non_nullable
as String,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
