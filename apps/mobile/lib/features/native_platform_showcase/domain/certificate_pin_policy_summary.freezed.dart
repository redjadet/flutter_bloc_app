// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certificate_pin_policy_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CertificatePinPolicySummary {

 String get modeName; String get pinHashKindName; int get configuredHostCount; int get primaryPinCount; int get backupPinCount; bool get canOpenMutableDemo;
/// Create a copy of CertificatePinPolicySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CertificatePinPolicySummaryCopyWith<CertificatePinPolicySummary> get copyWith => _$CertificatePinPolicySummaryCopyWithImpl<CertificatePinPolicySummary>(this as CertificatePinPolicySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CertificatePinPolicySummary&&(identical(other.modeName, modeName) || other.modeName == modeName)&&(identical(other.pinHashKindName, pinHashKindName) || other.pinHashKindName == pinHashKindName)&&(identical(other.configuredHostCount, configuredHostCount) || other.configuredHostCount == configuredHostCount)&&(identical(other.primaryPinCount, primaryPinCount) || other.primaryPinCount == primaryPinCount)&&(identical(other.backupPinCount, backupPinCount) || other.backupPinCount == backupPinCount)&&(identical(other.canOpenMutableDemo, canOpenMutableDemo) || other.canOpenMutableDemo == canOpenMutableDemo));
}


@override
int get hashCode => Object.hash(runtimeType,modeName,pinHashKindName,configuredHostCount,primaryPinCount,backupPinCount,canOpenMutableDemo);

@override
String toString() {
  return 'CertificatePinPolicySummary(modeName: $modeName, pinHashKindName: $pinHashKindName, configuredHostCount: $configuredHostCount, primaryPinCount: $primaryPinCount, backupPinCount: $backupPinCount, canOpenMutableDemo: $canOpenMutableDemo)';
}


}

/// @nodoc
abstract mixin class $CertificatePinPolicySummaryCopyWith<$Res>  {
  factory $CertificatePinPolicySummaryCopyWith(CertificatePinPolicySummary value, $Res Function(CertificatePinPolicySummary) _then) = _$CertificatePinPolicySummaryCopyWithImpl;
@useResult
$Res call({
 String modeName, String pinHashKindName, int configuredHostCount, int primaryPinCount, int backupPinCount, bool canOpenMutableDemo
});




}
/// @nodoc
class _$CertificatePinPolicySummaryCopyWithImpl<$Res>
    implements $CertificatePinPolicySummaryCopyWith<$Res> {
  _$CertificatePinPolicySummaryCopyWithImpl(this._self, this._then);

  final CertificatePinPolicySummary _self;
  final $Res Function(CertificatePinPolicySummary) _then;

/// Create a copy of CertificatePinPolicySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modeName = null,Object? pinHashKindName = null,Object? configuredHostCount = null,Object? primaryPinCount = null,Object? backupPinCount = null,Object? canOpenMutableDemo = null,}) {
  return _then(_self.copyWith(
modeName: null == modeName ? _self.modeName : modeName // ignore: cast_nullable_to_non_nullable
as String,pinHashKindName: null == pinHashKindName ? _self.pinHashKindName : pinHashKindName // ignore: cast_nullable_to_non_nullable
as String,configuredHostCount: null == configuredHostCount ? _self.configuredHostCount : configuredHostCount // ignore: cast_nullable_to_non_nullable
as int,primaryPinCount: null == primaryPinCount ? _self.primaryPinCount : primaryPinCount // ignore: cast_nullable_to_non_nullable
as int,backupPinCount: null == backupPinCount ? _self.backupPinCount : backupPinCount // ignore: cast_nullable_to_non_nullable
as int,canOpenMutableDemo: null == canOpenMutableDemo ? _self.canOpenMutableDemo : canOpenMutableDemo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CertificatePinPolicySummary].
extension CertificatePinPolicySummaryPatterns on CertificatePinPolicySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CertificatePinPolicySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CertificatePinPolicySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CertificatePinPolicySummary value)  $default,){
final _that = this;
switch (_that) {
case _CertificatePinPolicySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CertificatePinPolicySummary value)?  $default,){
final _that = this;
switch (_that) {
case _CertificatePinPolicySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String modeName,  String pinHashKindName,  int configuredHostCount,  int primaryPinCount,  int backupPinCount,  bool canOpenMutableDemo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CertificatePinPolicySummary() when $default != null:
return $default(_that.modeName,_that.pinHashKindName,_that.configuredHostCount,_that.primaryPinCount,_that.backupPinCount,_that.canOpenMutableDemo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String modeName,  String pinHashKindName,  int configuredHostCount,  int primaryPinCount,  int backupPinCount,  bool canOpenMutableDemo)  $default,) {final _that = this;
switch (_that) {
case _CertificatePinPolicySummary():
return $default(_that.modeName,_that.pinHashKindName,_that.configuredHostCount,_that.primaryPinCount,_that.backupPinCount,_that.canOpenMutableDemo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String modeName,  String pinHashKindName,  int configuredHostCount,  int primaryPinCount,  int backupPinCount,  bool canOpenMutableDemo)?  $default,) {final _that = this;
switch (_that) {
case _CertificatePinPolicySummary() when $default != null:
return $default(_that.modeName,_that.pinHashKindName,_that.configuredHostCount,_that.primaryPinCount,_that.backupPinCount,_that.canOpenMutableDemo);case _:
  return null;

}
}

}

/// @nodoc


class _CertificatePinPolicySummary implements CertificatePinPolicySummary {
  const _CertificatePinPolicySummary({required this.modeName, required this.pinHashKindName, required this.configuredHostCount, required this.primaryPinCount, required this.backupPinCount, required this.canOpenMutableDemo});
  

@override final  String modeName;
@override final  String pinHashKindName;
@override final  int configuredHostCount;
@override final  int primaryPinCount;
@override final  int backupPinCount;
@override final  bool canOpenMutableDemo;

/// Create a copy of CertificatePinPolicySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CertificatePinPolicySummaryCopyWith<_CertificatePinPolicySummary> get copyWith => __$CertificatePinPolicySummaryCopyWithImpl<_CertificatePinPolicySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CertificatePinPolicySummary&&(identical(other.modeName, modeName) || other.modeName == modeName)&&(identical(other.pinHashKindName, pinHashKindName) || other.pinHashKindName == pinHashKindName)&&(identical(other.configuredHostCount, configuredHostCount) || other.configuredHostCount == configuredHostCount)&&(identical(other.primaryPinCount, primaryPinCount) || other.primaryPinCount == primaryPinCount)&&(identical(other.backupPinCount, backupPinCount) || other.backupPinCount == backupPinCount)&&(identical(other.canOpenMutableDemo, canOpenMutableDemo) || other.canOpenMutableDemo == canOpenMutableDemo));
}


@override
int get hashCode => Object.hash(runtimeType,modeName,pinHashKindName,configuredHostCount,primaryPinCount,backupPinCount,canOpenMutableDemo);

@override
String toString() {
  return 'CertificatePinPolicySummary(modeName: $modeName, pinHashKindName: $pinHashKindName, configuredHostCount: $configuredHostCount, primaryPinCount: $primaryPinCount, backupPinCount: $backupPinCount, canOpenMutableDemo: $canOpenMutableDemo)';
}


}

/// @nodoc
abstract mixin class _$CertificatePinPolicySummaryCopyWith<$Res> implements $CertificatePinPolicySummaryCopyWith<$Res> {
  factory _$CertificatePinPolicySummaryCopyWith(_CertificatePinPolicySummary value, $Res Function(_CertificatePinPolicySummary) _then) = __$CertificatePinPolicySummaryCopyWithImpl;
@override @useResult
$Res call({
 String modeName, String pinHashKindName, int configuredHostCount, int primaryPinCount, int backupPinCount, bool canOpenMutableDemo
});




}
/// @nodoc
class __$CertificatePinPolicySummaryCopyWithImpl<$Res>
    implements _$CertificatePinPolicySummaryCopyWith<$Res> {
  __$CertificatePinPolicySummaryCopyWithImpl(this._self, this._then);

  final _CertificatePinPolicySummary _self;
  final $Res Function(_CertificatePinPolicySummary) _then;

/// Create a copy of CertificatePinPolicySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modeName = null,Object? pinHashKindName = null,Object? configuredHostCount = null,Object? primaryPinCount = null,Object? backupPinCount = null,Object? canOpenMutableDemo = null,}) {
  return _then(_CertificatePinPolicySummary(
modeName: null == modeName ? _self.modeName : modeName // ignore: cast_nullable_to_non_nullable
as String,pinHashKindName: null == pinHashKindName ? _self.pinHashKindName : pinHashKindName // ignore: cast_nullable_to_non_nullable
as String,configuredHostCount: null == configuredHostCount ? _self.configuredHostCount : configuredHostCount // ignore: cast_nullable_to_non_nullable
as int,primaryPinCount: null == primaryPinCount ? _self.primaryPinCount : primaryPinCount // ignore: cast_nullable_to_non_nullable
as int,backupPinCount: null == backupPinCount ? _self.backupPinCount : backupPinCount // ignore: cast_nullable_to_non_nullable
as int,canOpenMutableDemo: null == canOpenMutableDemo ? _self.canOpenMutableDemo : canOpenMutableDemo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
