// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'awesome_feature_widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeatureEnabledData {

 bool get isEnabled;
/// Create a copy of _FeatureEnabledData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureEnabledDataCopyWith<_FeatureEnabledData> get copyWith => __$FeatureEnabledDataCopyWithImpl<_FeatureEnabledData>(this as _FeatureEnabledData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureEnabledData&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled);

@override
String toString() {
  return '_FeatureEnabledData(isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$FeatureEnabledDataCopyWith<$Res>  {
  factory _$FeatureEnabledDataCopyWith(_FeatureEnabledData value, $Res Function(_FeatureEnabledData) _then) = __$FeatureEnabledDataCopyWithImpl;
@useResult
$Res call({
 bool isEnabled
});




}
/// @nodoc
class __$FeatureEnabledDataCopyWithImpl<$Res>
    implements _$FeatureEnabledDataCopyWith<$Res> {
  __$FeatureEnabledDataCopyWithImpl(this._self, this._then);

  final _FeatureEnabledData _self;
  final $Res Function(_FeatureEnabledData) _then;

/// Create a copy of _FeatureEnabledData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = null,}) {
  return _then(_self.copyWith(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_FeatureEnabledData].
extension _FeatureEnabledDataPatterns on _FeatureEnabledData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __FeatureEnabledData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __FeatureEnabledData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __FeatureEnabledData value)  $default,){
final _that = this;
switch (_that) {
case __FeatureEnabledData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __FeatureEnabledData value)?  $default,){
final _that = this;
switch (_that) {
case __FeatureEnabledData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __FeatureEnabledData() when $default != null:
return $default(_that.isEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEnabled)  $default,) {final _that = this;
switch (_that) {
case __FeatureEnabledData():
return $default(_that.isEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEnabled)?  $default,) {final _that = this;
switch (_that) {
case __FeatureEnabledData() when $default != null:
return $default(_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class __FeatureEnabledData implements _FeatureEnabledData {
  const __FeatureEnabledData({required this.isEnabled});
  

@override final  bool isEnabled;

/// Create a copy of _FeatureEnabledData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_FeatureEnabledDataCopyWith<__FeatureEnabledData> get copyWith => __$_FeatureEnabledDataCopyWithImpl<__FeatureEnabledData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __FeatureEnabledData&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled);

@override
String toString() {
  return '_FeatureEnabledData(isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$_FeatureEnabledDataCopyWith<$Res> implements _$FeatureEnabledDataCopyWith<$Res> {
  factory _$_FeatureEnabledDataCopyWith(__FeatureEnabledData value, $Res Function(__FeatureEnabledData) _then) = __$_FeatureEnabledDataCopyWithImpl;
@override @useResult
$Res call({
 bool isEnabled
});




}
/// @nodoc
class __$_FeatureEnabledDataCopyWithImpl<$Res>
    implements _$_FeatureEnabledDataCopyWith<$Res> {
  __$_FeatureEnabledDataCopyWithImpl(this._self, this._then);

  final __FeatureEnabledData _self;
  final $Res Function(__FeatureEnabledData) _then;

/// Create a copy of _FeatureEnabledData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,}) {
  return _then(__FeatureEnabledData(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
