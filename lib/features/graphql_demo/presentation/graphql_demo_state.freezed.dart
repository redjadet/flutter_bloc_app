// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graphql_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GraphqlDemoState {

 GraphqlDemoStatus get status; List<GraphqlCountry> get countries; List<GraphqlContinent> get continents; String? get activeContinentCode; String? get errorMessage; GraphqlDemoErrorType? get errorType;
/// Create a copy of GraphqlDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphqlDemoStateCopyWith<GraphqlDemoState> get copyWith => _$GraphqlDemoStateCopyWithImpl<GraphqlDemoState>(this as GraphqlDemoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphqlDemoState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.countries, countries)&&const DeepCollectionEquality().equals(other.continents, continents)&&(identical(other.activeContinentCode, activeContinentCode) || other.activeContinentCode == activeContinentCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(countries),const DeepCollectionEquality().hash(continents),activeContinentCode,errorMessage,errorType);

@override
String toString() {
  return 'GraphqlDemoState(status: $status, countries: $countries, continents: $continents, activeContinentCode: $activeContinentCode, errorMessage: $errorMessage, errorType: $errorType)';
}


}

/// @nodoc
abstract mixin class $GraphqlDemoStateCopyWith<$Res>  {
  factory $GraphqlDemoStateCopyWith(GraphqlDemoState value, $Res Function(GraphqlDemoState) _then) = _$GraphqlDemoStateCopyWithImpl;
@useResult
$Res call({
 GraphqlDemoStatus status, List<GraphqlCountry> countries, List<GraphqlContinent> continents, String? activeContinentCode, String? errorMessage, GraphqlDemoErrorType? errorType
});




}
/// @nodoc
class _$GraphqlDemoStateCopyWithImpl<$Res>
    implements $GraphqlDemoStateCopyWith<$Res> {
  _$GraphqlDemoStateCopyWithImpl(this._self, this._then);

  final GraphqlDemoState _self;
  final $Res Function(GraphqlDemoState) _then;

/// Create a copy of GraphqlDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? countries = null,Object? continents = null,Object? activeContinentCode = freezed,Object? errorMessage = freezed,Object? errorType = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GraphqlDemoStatus,countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<GraphqlCountry>,continents: null == continents ? _self.continents : continents // ignore: cast_nullable_to_non_nullable
as List<GraphqlContinent>,activeContinentCode: freezed == activeContinentCode ? _self.activeContinentCode : activeContinentCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as GraphqlDemoErrorType?,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphqlDemoState].
extension GraphqlDemoStatePatterns on GraphqlDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphqlDemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphqlDemoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphqlDemoState value)  $default,){
final _that = this;
switch (_that) {
case _GraphqlDemoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphqlDemoState value)?  $default,){
final _that = this;
switch (_that) {
case _GraphqlDemoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GraphqlDemoStatus status,  List<GraphqlCountry> countries,  List<GraphqlContinent> continents,  String? activeContinentCode,  String? errorMessage,  GraphqlDemoErrorType? errorType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphqlDemoState() when $default != null:
return $default(_that.status,_that.countries,_that.continents,_that.activeContinentCode,_that.errorMessage,_that.errorType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GraphqlDemoStatus status,  List<GraphqlCountry> countries,  List<GraphqlContinent> continents,  String? activeContinentCode,  String? errorMessage,  GraphqlDemoErrorType? errorType)  $default,) {final _that = this;
switch (_that) {
case _GraphqlDemoState():
return $default(_that.status,_that.countries,_that.continents,_that.activeContinentCode,_that.errorMessage,_that.errorType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GraphqlDemoStatus status,  List<GraphqlCountry> countries,  List<GraphqlContinent> continents,  String? activeContinentCode,  String? errorMessage,  GraphqlDemoErrorType? errorType)?  $default,) {final _that = this;
switch (_that) {
case _GraphqlDemoState() when $default != null:
return $default(_that.status,_that.countries,_that.continents,_that.activeContinentCode,_that.errorMessage,_that.errorType);case _:
  return null;

}
}

}

/// @nodoc


class _GraphqlDemoState extends GraphqlDemoState {
  const _GraphqlDemoState({this.status = GraphqlDemoStatus.initial, final  List<GraphqlCountry> countries = const <GraphqlCountry>[], final  List<GraphqlContinent> continents = const <GraphqlContinent>[], this.activeContinentCode, this.errorMessage, this.errorType}): _countries = countries,_continents = continents,super._();
  

@override@JsonKey() final  GraphqlDemoStatus status;
 final  List<GraphqlCountry> _countries;
@override@JsonKey() List<GraphqlCountry> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

 final  List<GraphqlContinent> _continents;
@override@JsonKey() List<GraphqlContinent> get continents {
  if (_continents is EqualUnmodifiableListView) return _continents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_continents);
}

@override final  String? activeContinentCode;
@override final  String? errorMessage;
@override final  GraphqlDemoErrorType? errorType;

/// Create a copy of GraphqlDemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphqlDemoStateCopyWith<_GraphqlDemoState> get copyWith => __$GraphqlDemoStateCopyWithImpl<_GraphqlDemoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphqlDemoState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._countries, _countries)&&const DeepCollectionEquality().equals(other._continents, _continents)&&(identical(other.activeContinentCode, activeContinentCode) || other.activeContinentCode == activeContinentCode)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_countries),const DeepCollectionEquality().hash(_continents),activeContinentCode,errorMessage,errorType);

@override
String toString() {
  return 'GraphqlDemoState(status: $status, countries: $countries, continents: $continents, activeContinentCode: $activeContinentCode, errorMessage: $errorMessage, errorType: $errorType)';
}


}

/// @nodoc
abstract mixin class _$GraphqlDemoStateCopyWith<$Res> implements $GraphqlDemoStateCopyWith<$Res> {
  factory _$GraphqlDemoStateCopyWith(_GraphqlDemoState value, $Res Function(_GraphqlDemoState) _then) = __$GraphqlDemoStateCopyWithImpl;
@override @useResult
$Res call({
 GraphqlDemoStatus status, List<GraphqlCountry> countries, List<GraphqlContinent> continents, String? activeContinentCode, String? errorMessage, GraphqlDemoErrorType? errorType
});




}
/// @nodoc
class __$GraphqlDemoStateCopyWithImpl<$Res>
    implements _$GraphqlDemoStateCopyWith<$Res> {
  __$GraphqlDemoStateCopyWithImpl(this._self, this._then);

  final _GraphqlDemoState _self;
  final $Res Function(_GraphqlDemoState) _then;

/// Create a copy of GraphqlDemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? countries = null,Object? continents = null,Object? activeContinentCode = freezed,Object? errorMessage = freezed,Object? errorType = freezed,}) {
  return _then(_GraphqlDemoState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GraphqlDemoStatus,countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<GraphqlCountry>,continents: null == continents ? _self._continents : continents // ignore: cast_nullable_to_non_nullable
as List<GraphqlContinent>,activeContinentCode: freezed == activeContinentCode ? _self.activeContinentCode : activeContinentCode // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as GraphqlDemoErrorType?,
  ));
}


}

// dart format on
