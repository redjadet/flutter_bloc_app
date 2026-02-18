// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapLocation {

 String get id; String get title; String get description; MapCoordinate get coordinate;
/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapLocationCopyWith<MapLocation> get copyWith => _$MapLocationCopyWithImpl<MapLocation>(this as MapLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,coordinate);

@override
String toString() {
  return 'MapLocation(id: $id, title: $title, description: $description, coordinate: $coordinate)';
}


}

/// @nodoc
abstract mixin class $MapLocationCopyWith<$Res>  {
  factory $MapLocationCopyWith(MapLocation value, $Res Function(MapLocation) _then) = _$MapLocationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, MapCoordinate coordinate
});


$MapCoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class _$MapLocationCopyWithImpl<$Res>
    implements $MapLocationCopyWith<$Res> {
  _$MapLocationCopyWithImpl(this._self, this._then);

  final MapLocation _self;
  final $Res Function(MapLocation) _then;

/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? coordinate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as MapCoordinate,
  ));
}
/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get coordinate {
  
  return $MapCoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapLocation].
extension MapLocationPatterns on MapLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapLocation value)  $default,){
final _that = this;
switch (_that) {
case _MapLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapLocation value)?  $default,){
final _that = this;
switch (_that) {
case _MapLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  MapCoordinate coordinate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapLocation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.coordinate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  MapCoordinate coordinate)  $default,) {final _that = this;
switch (_that) {
case _MapLocation():
return $default(_that.id,_that.title,_that.description,_that.coordinate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  MapCoordinate coordinate)?  $default,) {final _that = this;
switch (_that) {
case _MapLocation() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.coordinate);case _:
  return null;

}
}

}

/// @nodoc


class _MapLocation implements MapLocation {
  const _MapLocation({required this.id, required this.title, required this.description, required this.coordinate});
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  MapCoordinate coordinate;

/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapLocationCopyWith<_MapLocation> get copyWith => __$MapLocationCopyWithImpl<_MapLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapLocation&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,coordinate);

@override
String toString() {
  return 'MapLocation(id: $id, title: $title, description: $description, coordinate: $coordinate)';
}


}

/// @nodoc
abstract mixin class _$MapLocationCopyWith<$Res> implements $MapLocationCopyWith<$Res> {
  factory _$MapLocationCopyWith(_MapLocation value, $Res Function(_MapLocation) _then) = __$MapLocationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, MapCoordinate coordinate
});


@override $MapCoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class __$MapLocationCopyWithImpl<$Res>
    implements _$MapLocationCopyWith<$Res> {
  __$MapLocationCopyWithImpl(this._self, this._then);

  final _MapLocation _self;
  final $Res Function(_MapLocation) _then;

/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? coordinate = null,}) {
  return _then(_MapLocation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as MapCoordinate,
  ));
}

/// Create a copy of MapLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get coordinate {
  
  return $MapCoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}

// dart format on
