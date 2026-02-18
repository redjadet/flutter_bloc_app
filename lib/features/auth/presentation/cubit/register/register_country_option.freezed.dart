// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_country_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountryOption {

 String get code; String get name; String get dialCode;
/// Create a copy of CountryOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountryOptionCopyWith<CountryOption> get copyWith => _$CountryOptionCopyWithImpl<CountryOption>(this as CountryOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountryOption&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,dialCode);

@override
String toString() {
  return 'CountryOption(code: $code, name: $name, dialCode: $dialCode)';
}


}

/// @nodoc
abstract mixin class $CountryOptionCopyWith<$Res>  {
  factory $CountryOptionCopyWith(CountryOption value, $Res Function(CountryOption) _then) = _$CountryOptionCopyWithImpl;
@useResult
$Res call({
 String code, String name, String dialCode
});




}
/// @nodoc
class _$CountryOptionCopyWithImpl<$Res>
    implements $CountryOptionCopyWith<$Res> {
  _$CountryOptionCopyWithImpl(this._self, this._then);

  final CountryOption _self;
  final $Res Function(CountryOption) _then;

/// Create a copy of CountryOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? dialCode = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountryOption].
extension CountryOptionPatterns on CountryOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountryOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountryOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountryOption value)  $default,){
final _that = this;
switch (_that) {
case _CountryOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountryOption value)?  $default,){
final _that = this;
switch (_that) {
case _CountryOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String dialCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountryOption() when $default != null:
return $default(_that.code,_that.name,_that.dialCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String dialCode)  $default,) {final _that = this;
switch (_that) {
case _CountryOption():
return $default(_that.code,_that.name,_that.dialCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String dialCode)?  $default,) {final _that = this;
switch (_that) {
case _CountryOption() when $default != null:
return $default(_that.code,_that.name,_that.dialCode);case _:
  return null;

}
}

}

/// @nodoc


class _CountryOption extends CountryOption {
  const _CountryOption({required this.code, required this.name, required this.dialCode}): super._();
  

@override final  String code;
@override final  String name;
@override final  String dialCode;

/// Create a copy of CountryOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountryOptionCopyWith<_CountryOption> get copyWith => __$CountryOptionCopyWithImpl<_CountryOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountryOption&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode));
}


@override
int get hashCode => Object.hash(runtimeType,code,name,dialCode);

@override
String toString() {
  return 'CountryOption(code: $code, name: $name, dialCode: $dialCode)';
}


}

/// @nodoc
abstract mixin class _$CountryOptionCopyWith<$Res> implements $CountryOptionCopyWith<$Res> {
  factory _$CountryOptionCopyWith(_CountryOption value, $Res Function(_CountryOption) _then) = __$CountryOptionCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String dialCode
});




}
/// @nodoc
class __$CountryOptionCopyWithImpl<$Res>
    implements _$CountryOptionCopyWith<$Res> {
  __$CountryOptionCopyWithImpl(this._self, this._then);

  final _CountryOption _self;
  final $Res Function(_CountryOption) _then;

/// Create a copy of CountryOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? dialCode = null,}) {
  return _then(_CountryOption(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
