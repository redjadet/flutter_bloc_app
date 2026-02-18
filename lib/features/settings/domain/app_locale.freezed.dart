// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_locale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppLocale {

 String get languageCode; String? get countryCode;
/// Create a copy of AppLocale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLocaleCopyWith<AppLocale> get copyWith => _$AppLocaleCopyWithImpl<AppLocale>(this as AppLocale, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLocale&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}


@override
int get hashCode => Object.hash(runtimeType,languageCode,countryCode);

@override
String toString() {
  return 'AppLocale(languageCode: $languageCode, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class $AppLocaleCopyWith<$Res>  {
  factory $AppLocaleCopyWith(AppLocale value, $Res Function(AppLocale) _then) = _$AppLocaleCopyWithImpl;
@useResult
$Res call({
 String languageCode, String? countryCode
});




}
/// @nodoc
class _$AppLocaleCopyWithImpl<$Res>
    implements $AppLocaleCopyWith<$Res> {
  _$AppLocaleCopyWithImpl(this._self, this._then);

  final AppLocale _self;
  final $Res Function(AppLocale) _then;

/// Create a copy of AppLocale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? languageCode = null,Object? countryCode = freezed,}) {
  return _then(_self.copyWith(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLocale].
extension AppLocalePatterns on AppLocale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLocale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLocale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLocale value)  $default,){
final _that = this;
switch (_that) {
case _AppLocale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLocale value)?  $default,){
final _that = this;
switch (_that) {
case _AppLocale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String languageCode,  String? countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLocale() when $default != null:
return $default(_that.languageCode,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String languageCode,  String? countryCode)  $default,) {final _that = this;
switch (_that) {
case _AppLocale():
return $default(_that.languageCode,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String languageCode,  String? countryCode)?  $default,) {final _that = this;
switch (_that) {
case _AppLocale() when $default != null:
return $default(_that.languageCode,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc


class _AppLocale extends AppLocale {
  const _AppLocale({required this.languageCode, this.countryCode}): super._();
  

@override final  String languageCode;
@override final  String? countryCode;

/// Create a copy of AppLocale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLocaleCopyWith<_AppLocale> get copyWith => __$AppLocaleCopyWithImpl<_AppLocale>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLocale&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}


@override
int get hashCode => Object.hash(runtimeType,languageCode,countryCode);

@override
String toString() {
  return 'AppLocale(languageCode: $languageCode, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$AppLocaleCopyWith<$Res> implements $AppLocaleCopyWith<$Res> {
  factory _$AppLocaleCopyWith(_AppLocale value, $Res Function(_AppLocale) _then) = __$AppLocaleCopyWithImpl;
@override @useResult
$Res call({
 String languageCode, String? countryCode
});




}
/// @nodoc
class __$AppLocaleCopyWithImpl<$Res>
    implements _$AppLocaleCopyWith<$Res> {
  __$AppLocaleCopyWithImpl(this._self, this._then);

  final _AppLocale _self;
  final $Res Function(_AppLocale) _then;

/// Create a copy of AppLocale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? languageCode = null,Object? countryCode = freezed,}) {
  return _then(_AppLocale(
languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
