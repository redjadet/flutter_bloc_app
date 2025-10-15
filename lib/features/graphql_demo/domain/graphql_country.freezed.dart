// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graphql_country.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphqlContinent {

 String get code; String get name;
/// Create a copy of GraphqlContinent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphqlContinentCopyWith<GraphqlContinent> get copyWith => _$GraphqlContinentCopyWithImpl<GraphqlContinent>(this as GraphqlContinent, _$identity);

  /// Serializes this GraphqlContinent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphqlContinent&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'GraphqlContinent(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class $GraphqlContinentCopyWith<$Res>  {
  factory $GraphqlContinentCopyWith(GraphqlContinent value, $Res Function(GraphqlContinent) _then) = _$GraphqlContinentCopyWithImpl;
@useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class _$GraphqlContinentCopyWithImpl<$Res>
    implements $GraphqlContinentCopyWith<$Res> {
  _$GraphqlContinentCopyWithImpl(this._self, this._then);

  final GraphqlContinent _self;
  final $Res Function(GraphqlContinent) _then;

/// Create a copy of GraphqlContinent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphqlContinent].
extension GraphqlContinentPatterns on GraphqlContinent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphqlContinent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphqlContinent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphqlContinent value)  $default,){
final _that = this;
switch (_that) {
case _GraphqlContinent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphqlContinent value)?  $default,){
final _that = this;
switch (_that) {
case _GraphqlContinent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphqlContinent() when $default != null:
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _GraphqlContinent():
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _GraphqlContinent() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GraphqlContinent implements GraphqlContinent {
  const _GraphqlContinent({required this.code, required this.name});
  factory _GraphqlContinent.fromJson(Map<String, dynamic> json) => _$GraphqlContinentFromJson(json);

@override final  String code;
@override final  String name;

/// Create a copy of GraphqlContinent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphqlContinentCopyWith<_GraphqlContinent> get copyWith => __$GraphqlContinentCopyWithImpl<_GraphqlContinent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GraphqlContinentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphqlContinent&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'GraphqlContinent(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GraphqlContinentCopyWith<$Res> implements $GraphqlContinentCopyWith<$Res> {
  factory _$GraphqlContinentCopyWith(_GraphqlContinent value, $Res Function(_GraphqlContinent) _then) = __$GraphqlContinentCopyWithImpl;
@override @useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class __$GraphqlContinentCopyWithImpl<$Res>
    implements _$GraphqlContinentCopyWith<$Res> {
  __$GraphqlContinentCopyWithImpl(this._self, this._then);

  final _GraphqlContinent _self;
  final $Res Function(_GraphqlContinent) _then;

/// Create a copy of GraphqlContinent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,}) {
  return _then(_GraphqlContinent(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GraphqlCountry {

 String get code; String get name; String? get capital; String? get currency; String? get emoji; GraphqlContinent get continent;
/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphqlCountryCopyWith<GraphqlCountry> get copyWith => _$GraphqlCountryCopyWithImpl<GraphqlCountry>(this as GraphqlCountry, _$identity);

  /// Serializes this GraphqlCountry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphqlCountry&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.capital, capital) || other.capital == capital)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.continent, continent) || other.continent == continent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,capital,currency,emoji,continent);

@override
String toString() {
  return 'GraphqlCountry(code: $code, name: $name, capital: $capital, currency: $currency, emoji: $emoji, continent: $continent)';
}


}

/// @nodoc
abstract mixin class $GraphqlCountryCopyWith<$Res>  {
  factory $GraphqlCountryCopyWith(GraphqlCountry value, $Res Function(GraphqlCountry) _then) = _$GraphqlCountryCopyWithImpl;
@useResult
$Res call({
 String code, String name, String? capital, String? currency, String? emoji, GraphqlContinent continent
});


$GraphqlContinentCopyWith<$Res> get continent;

}
/// @nodoc
class _$GraphqlCountryCopyWithImpl<$Res>
    implements $GraphqlCountryCopyWith<$Res> {
  _$GraphqlCountryCopyWithImpl(this._self, this._then);

  final GraphqlCountry _self;
  final $Res Function(GraphqlCountry) _then;

/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? capital = freezed,Object? currency = freezed,Object? emoji = freezed,Object? continent = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capital: freezed == capital ? _self.capital : capital // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,continent: null == continent ? _self.continent : continent // ignore: cast_nullable_to_non_nullable
as GraphqlContinent,
  ));
}
/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GraphqlContinentCopyWith<$Res> get continent {
  
  return $GraphqlContinentCopyWith<$Res>(_self.continent, (value) {
    return _then(_self.copyWith(continent: value));
  });
}
}


/// Adds pattern-matching-related methods to [GraphqlCountry].
extension GraphqlCountryPatterns on GraphqlCountry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphqlCountry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphqlCountry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphqlCountry value)  $default,){
final _that = this;
switch (_that) {
case _GraphqlCountry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphqlCountry value)?  $default,){
final _that = this;
switch (_that) {
case _GraphqlCountry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String? capital,  String? currency,  String? emoji,  GraphqlContinent continent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphqlCountry() when $default != null:
return $default(_that.code,_that.name,_that.capital,_that.currency,_that.emoji,_that.continent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String? capital,  String? currency,  String? emoji,  GraphqlContinent continent)  $default,) {final _that = this;
switch (_that) {
case _GraphqlCountry():
return $default(_that.code,_that.name,_that.capital,_that.currency,_that.emoji,_that.continent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String? capital,  String? currency,  String? emoji,  GraphqlContinent continent)?  $default,) {final _that = this;
switch (_that) {
case _GraphqlCountry() when $default != null:
return $default(_that.code,_that.name,_that.capital,_that.currency,_that.emoji,_that.continent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GraphqlCountry implements GraphqlCountry {
  const _GraphqlCountry({required this.code, required this.name, this.capital, this.currency, this.emoji, required this.continent});
  factory _GraphqlCountry.fromJson(Map<String, dynamic> json) => _$GraphqlCountryFromJson(json);

@override final  String code;
@override final  String name;
@override final  String? capital;
@override final  String? currency;
@override final  String? emoji;
@override final  GraphqlContinent continent;

/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphqlCountryCopyWith<_GraphqlCountry> get copyWith => __$GraphqlCountryCopyWithImpl<_GraphqlCountry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GraphqlCountryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphqlCountry&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.capital, capital) || other.capital == capital)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.continent, continent) || other.continent == continent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,capital,currency,emoji,continent);

@override
String toString() {
  return 'GraphqlCountry(code: $code, name: $name, capital: $capital, currency: $currency, emoji: $emoji, continent: $continent)';
}


}

/// @nodoc
abstract mixin class _$GraphqlCountryCopyWith<$Res> implements $GraphqlCountryCopyWith<$Res> {
  factory _$GraphqlCountryCopyWith(_GraphqlCountry value, $Res Function(_GraphqlCountry) _then) = __$GraphqlCountryCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String? capital, String? currency, String? emoji, GraphqlContinent continent
});


@override $GraphqlContinentCopyWith<$Res> get continent;

}
/// @nodoc
class __$GraphqlCountryCopyWithImpl<$Res>
    implements _$GraphqlCountryCopyWith<$Res> {
  __$GraphqlCountryCopyWithImpl(this._self, this._then);

  final _GraphqlCountry _self;
  final $Res Function(_GraphqlCountry) _then;

/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? capital = freezed,Object? currency = freezed,Object? emoji = freezed,Object? continent = null,}) {
  return _then(_GraphqlCountry(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capital: freezed == capital ? _self.capital : capital // ignore: cast_nullable_to_non_nullable
as String?,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,continent: null == continent ? _self.continent : continent // ignore: cast_nullable_to_non_nullable
as GraphqlContinent,
  ));
}

/// Create a copy of GraphqlCountry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GraphqlContinentCopyWith<$Res> get continent {
  
  return $GraphqlContinentCopyWith<$Res>(_self.continent, (value) {
    return _then(_self.copyWith(continent: value));
  });
}
}

// dart format on
