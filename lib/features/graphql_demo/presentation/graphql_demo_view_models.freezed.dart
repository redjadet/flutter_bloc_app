// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graphql_demo_view_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GraphqlFilterBarData {

 List<GraphqlContinent> get continents; String? get activeContinentCode; bool get isLoading;
/// Create a copy of GraphqlFilterBarData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphqlFilterBarDataCopyWith<GraphqlFilterBarData> get copyWith => _$GraphqlFilterBarDataCopyWithImpl<GraphqlFilterBarData>(this as GraphqlFilterBarData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphqlFilterBarData&&const DeepCollectionEquality().equals(other.continents, continents)&&(identical(other.activeContinentCode, activeContinentCode) || other.activeContinentCode == activeContinentCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(continents),activeContinentCode,isLoading);

@override
String toString() {
  return 'GraphqlFilterBarData(continents: $continents, activeContinentCode: $activeContinentCode, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $GraphqlFilterBarDataCopyWith<$Res>  {
  factory $GraphqlFilterBarDataCopyWith(GraphqlFilterBarData value, $Res Function(GraphqlFilterBarData) _then) = _$GraphqlFilterBarDataCopyWithImpl;
@useResult
$Res call({
 List<GraphqlContinent> continents, String? activeContinentCode, bool isLoading
});




}
/// @nodoc
class _$GraphqlFilterBarDataCopyWithImpl<$Res>
    implements $GraphqlFilterBarDataCopyWith<$Res> {
  _$GraphqlFilterBarDataCopyWithImpl(this._self, this._then);

  final GraphqlFilterBarData _self;
  final $Res Function(GraphqlFilterBarData) _then;

/// Create a copy of GraphqlFilterBarData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? continents = null,Object? activeContinentCode = freezed,Object? isLoading = null,}) {
  return _then(_self.copyWith(
continents: null == continents ? _self.continents : continents // ignore: cast_nullable_to_non_nullable
as List<GraphqlContinent>,activeContinentCode: freezed == activeContinentCode ? _self.activeContinentCode : activeContinentCode // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphqlFilterBarData].
extension GraphqlFilterBarDataPatterns on GraphqlFilterBarData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphqlFilterBarData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphqlFilterBarData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphqlFilterBarData value)  $default,){
final _that = this;
switch (_that) {
case _GraphqlFilterBarData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphqlFilterBarData value)?  $default,){
final _that = this;
switch (_that) {
case _GraphqlFilterBarData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GraphqlContinent> continents,  String? activeContinentCode,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphqlFilterBarData() when $default != null:
return $default(_that.continents,_that.activeContinentCode,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GraphqlContinent> continents,  String? activeContinentCode,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _GraphqlFilterBarData():
return $default(_that.continents,_that.activeContinentCode,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GraphqlContinent> continents,  String? activeContinentCode,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _GraphqlFilterBarData() when $default != null:
return $default(_that.continents,_that.activeContinentCode,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _GraphqlFilterBarData implements GraphqlFilterBarData {
  const _GraphqlFilterBarData({required final  List<GraphqlContinent> continents, required this.activeContinentCode, required this.isLoading}): _continents = continents;
  

 final  List<GraphqlContinent> _continents;
@override List<GraphqlContinent> get continents {
  if (_continents is EqualUnmodifiableListView) return _continents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_continents);
}

@override final  String? activeContinentCode;
@override final  bool isLoading;

/// Create a copy of GraphqlFilterBarData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphqlFilterBarDataCopyWith<_GraphqlFilterBarData> get copyWith => __$GraphqlFilterBarDataCopyWithImpl<_GraphqlFilterBarData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphqlFilterBarData&&const DeepCollectionEquality().equals(other._continents, _continents)&&(identical(other.activeContinentCode, activeContinentCode) || other.activeContinentCode == activeContinentCode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_continents),activeContinentCode,isLoading);

@override
String toString() {
  return 'GraphqlFilterBarData(continents: $continents, activeContinentCode: $activeContinentCode, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$GraphqlFilterBarDataCopyWith<$Res> implements $GraphqlFilterBarDataCopyWith<$Res> {
  factory _$GraphqlFilterBarDataCopyWith(_GraphqlFilterBarData value, $Res Function(_GraphqlFilterBarData) _then) = __$GraphqlFilterBarDataCopyWithImpl;
@override @useResult
$Res call({
 List<GraphqlContinent> continents, String? activeContinentCode, bool isLoading
});




}
/// @nodoc
class __$GraphqlFilterBarDataCopyWithImpl<$Res>
    implements _$GraphqlFilterBarDataCopyWith<$Res> {
  __$GraphqlFilterBarDataCopyWithImpl(this._self, this._then);

  final _GraphqlFilterBarData _self;
  final $Res Function(_GraphqlFilterBarData) _then;

/// Create a copy of GraphqlFilterBarData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? continents = null,Object? activeContinentCode = freezed,Object? isLoading = null,}) {
  return _then(_GraphqlFilterBarData(
continents: null == continents ? _self._continents : continents // ignore: cast_nullable_to_non_nullable
as List<GraphqlContinent>,activeContinentCode: freezed == activeContinentCode ? _self.activeContinentCode : activeContinentCode // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GraphqlBodyData {

 bool get isLoading; bool get hasError; List<GraphqlCountry> get countries; GraphqlDemoErrorType? get errorType; String? get errorMessage;
/// Create a copy of GraphqlBodyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphqlBodyDataCopyWith<GraphqlBodyData> get copyWith => _$GraphqlBodyDataCopyWithImpl<GraphqlBodyData>(this as GraphqlBodyData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphqlBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&const DeepCollectionEquality().equals(other.countries, countries)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,hasError,const DeepCollectionEquality().hash(countries),errorType,errorMessage);

@override
String toString() {
  return 'GraphqlBodyData(isLoading: $isLoading, hasError: $hasError, countries: $countries, errorType: $errorType, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $GraphqlBodyDataCopyWith<$Res>  {
  factory $GraphqlBodyDataCopyWith(GraphqlBodyData value, $Res Function(GraphqlBodyData) _then) = _$GraphqlBodyDataCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool hasError, List<GraphqlCountry> countries, GraphqlDemoErrorType? errorType, String? errorMessage
});




}
/// @nodoc
class _$GraphqlBodyDataCopyWithImpl<$Res>
    implements $GraphqlBodyDataCopyWith<$Res> {
  _$GraphqlBodyDataCopyWithImpl(this._self, this._then);

  final GraphqlBodyData _self;
  final $Res Function(GraphqlBodyData) _then;

/// Create a copy of GraphqlBodyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? hasError = null,Object? countries = null,Object? errorType = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<GraphqlCountry>,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as GraphqlDemoErrorType?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphqlBodyData].
extension GraphqlBodyDataPatterns on GraphqlBodyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphqlBodyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphqlBodyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphqlBodyData value)  $default,){
final _that = this;
switch (_that) {
case _GraphqlBodyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphqlBodyData value)?  $default,){
final _that = this;
switch (_that) {
case _GraphqlBodyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool hasError,  List<GraphqlCountry> countries,  GraphqlDemoErrorType? errorType,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphqlBodyData() when $default != null:
return $default(_that.isLoading,_that.hasError,_that.countries,_that.errorType,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool hasError,  List<GraphqlCountry> countries,  GraphqlDemoErrorType? errorType,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _GraphqlBodyData():
return $default(_that.isLoading,_that.hasError,_that.countries,_that.errorType,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool hasError,  List<GraphqlCountry> countries,  GraphqlDemoErrorType? errorType,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _GraphqlBodyData() when $default != null:
return $default(_that.isLoading,_that.hasError,_that.countries,_that.errorType,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _GraphqlBodyData implements GraphqlBodyData {
  const _GraphqlBodyData({required this.isLoading, required this.hasError, required final  List<GraphqlCountry> countries, required this.errorType, required this.errorMessage}): _countries = countries;
  

@override final  bool isLoading;
@override final  bool hasError;
 final  List<GraphqlCountry> _countries;
@override List<GraphqlCountry> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

@override final  GraphqlDemoErrorType? errorType;
@override final  String? errorMessage;

/// Create a copy of GraphqlBodyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphqlBodyDataCopyWith<_GraphqlBodyData> get copyWith => __$GraphqlBodyDataCopyWithImpl<_GraphqlBodyData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphqlBodyData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasError, hasError) || other.hasError == hasError)&&const DeepCollectionEquality().equals(other._countries, _countries)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,hasError,const DeepCollectionEquality().hash(_countries),errorType,errorMessage);

@override
String toString() {
  return 'GraphqlBodyData(isLoading: $isLoading, hasError: $hasError, countries: $countries, errorType: $errorType, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$GraphqlBodyDataCopyWith<$Res> implements $GraphqlBodyDataCopyWith<$Res> {
  factory _$GraphqlBodyDataCopyWith(_GraphqlBodyData value, $Res Function(_GraphqlBodyData) _then) = __$GraphqlBodyDataCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool hasError, List<GraphqlCountry> countries, GraphqlDemoErrorType? errorType, String? errorMessage
});




}
/// @nodoc
class __$GraphqlBodyDataCopyWithImpl<$Res>
    implements _$GraphqlBodyDataCopyWith<$Res> {
  __$GraphqlBodyDataCopyWithImpl(this._self, this._then);

  final _GraphqlBodyData _self;
  final $Res Function(_GraphqlBodyData) _then;

/// Create a copy of GraphqlBodyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? hasError = null,Object? countries = null,Object? errorType = freezed,Object? errorMessage = freezed,}) {
  return _then(_GraphqlBodyData(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasError: null == hasError ? _self.hasError : hasError // ignore: cast_nullable_to_non_nullable
as bool,countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<GraphqlCountry>,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as GraphqlDemoErrorType?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
