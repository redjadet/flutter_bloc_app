// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mapbox_sample_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapboxSampleState {

 MapCoordinate get cameraCenter; double get cameraZoom; bool get isLoading; String? get errorMessage; List<MapLocation> get locations; String? get selectedLocationId;
/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapboxSampleStateCopyWith<MapboxSampleState> get copyWith => _$MapboxSampleStateCopyWithImpl<MapboxSampleState>(this as MapboxSampleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapboxSampleState&&(identical(other.cameraCenter, cameraCenter) || other.cameraCenter == cameraCenter)&&(identical(other.cameraZoom, cameraZoom) || other.cameraZoom == cameraZoom)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.selectedLocationId, selectedLocationId) || other.selectedLocationId == selectedLocationId));
}


@override
int get hashCode => Object.hash(runtimeType,cameraCenter,cameraZoom,isLoading,errorMessage,const DeepCollectionEquality().hash(locations),selectedLocationId);

@override
String toString() {
  return 'MapboxSampleState(cameraCenter: $cameraCenter, cameraZoom: $cameraZoom, isLoading: $isLoading, errorMessage: $errorMessage, locations: $locations, selectedLocationId: $selectedLocationId)';
}


}

/// @nodoc
abstract mixin class $MapboxSampleStateCopyWith<$Res>  {
  factory $MapboxSampleStateCopyWith(MapboxSampleState value, $Res Function(MapboxSampleState) _then) = _$MapboxSampleStateCopyWithImpl;
@useResult
$Res call({
 MapCoordinate cameraCenter, double cameraZoom, bool isLoading, String? errorMessage, List<MapLocation> locations, String? selectedLocationId
});


$MapCoordinateCopyWith<$Res> get cameraCenter;

}
/// @nodoc
class _$MapboxSampleStateCopyWithImpl<$Res>
    implements $MapboxSampleStateCopyWith<$Res> {
  _$MapboxSampleStateCopyWithImpl(this._self, this._then);

  final MapboxSampleState _self;
  final $Res Function(MapboxSampleState) _then;

/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cameraCenter = null,Object? cameraZoom = null,Object? isLoading = null,Object? errorMessage = freezed,Object? locations = null,Object? selectedLocationId = freezed,}) {
  return _then(_self.copyWith(
cameraCenter: null == cameraCenter ? _self.cameraCenter : cameraCenter // ignore: cast_nullable_to_non_nullable
as MapCoordinate,cameraZoom: null == cameraZoom ? _self.cameraZoom : cameraZoom // ignore: cast_nullable_to_non_nullable
as double,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,locations: null == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedLocationId: freezed == selectedLocationId ? _self.selectedLocationId : selectedLocationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get cameraCenter {
  
  return $MapCoordinateCopyWith<$Res>(_self.cameraCenter, (value) {
    return _then(_self.copyWith(cameraCenter: value));
  });
}
}


/// Adds pattern-matching-related methods to [MapboxSampleState].
extension MapboxSampleStatePatterns on MapboxSampleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapboxSampleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapboxSampleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapboxSampleState value)  $default,){
final _that = this;
switch (_that) {
case _MapboxSampleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapboxSampleState value)?  $default,){
final _that = this;
switch (_that) {
case _MapboxSampleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MapCoordinate cameraCenter,  double cameraZoom,  bool isLoading,  String? errorMessage,  List<MapLocation> locations,  String? selectedLocationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapboxSampleState() when $default != null:
return $default(_that.cameraCenter,_that.cameraZoom,_that.isLoading,_that.errorMessage,_that.locations,_that.selectedLocationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MapCoordinate cameraCenter,  double cameraZoom,  bool isLoading,  String? errorMessage,  List<MapLocation> locations,  String? selectedLocationId)  $default,) {final _that = this;
switch (_that) {
case _MapboxSampleState():
return $default(_that.cameraCenter,_that.cameraZoom,_that.isLoading,_that.errorMessage,_that.locations,_that.selectedLocationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MapCoordinate cameraCenter,  double cameraZoom,  bool isLoading,  String? errorMessage,  List<MapLocation> locations,  String? selectedLocationId)?  $default,) {final _that = this;
switch (_that) {
case _MapboxSampleState() when $default != null:
return $default(_that.cameraCenter,_that.cameraZoom,_that.isLoading,_that.errorMessage,_that.locations,_that.selectedLocationId);case _:
  return null;

}
}

}

/// @nodoc


class _MapboxSampleState extends MapboxSampleState {
  const _MapboxSampleState({required this.cameraCenter, required this.cameraZoom, this.isLoading = false, this.errorMessage, final  List<MapLocation> locations = const <MapLocation>[], this.selectedLocationId}): _locations = locations,super._();
  

@override final  MapCoordinate cameraCenter;
@override final  double cameraZoom;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
 final  List<MapLocation> _locations;
@override@JsonKey() List<MapLocation> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

@override final  String? selectedLocationId;

/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapboxSampleStateCopyWith<_MapboxSampleState> get copyWith => __$MapboxSampleStateCopyWithImpl<_MapboxSampleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapboxSampleState&&(identical(other.cameraCenter, cameraCenter) || other.cameraCenter == cameraCenter)&&(identical(other.cameraZoom, cameraZoom) || other.cameraZoom == cameraZoom)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.selectedLocationId, selectedLocationId) || other.selectedLocationId == selectedLocationId));
}


@override
int get hashCode => Object.hash(runtimeType,cameraCenter,cameraZoom,isLoading,errorMessage,const DeepCollectionEquality().hash(_locations),selectedLocationId);

@override
String toString() {
  return 'MapboxSampleState(cameraCenter: $cameraCenter, cameraZoom: $cameraZoom, isLoading: $isLoading, errorMessage: $errorMessage, locations: $locations, selectedLocationId: $selectedLocationId)';
}


}

/// @nodoc
abstract mixin class _$MapboxSampleStateCopyWith<$Res> implements $MapboxSampleStateCopyWith<$Res> {
  factory _$MapboxSampleStateCopyWith(_MapboxSampleState value, $Res Function(_MapboxSampleState) _then) = __$MapboxSampleStateCopyWithImpl;
@override @useResult
$Res call({
 MapCoordinate cameraCenter, double cameraZoom, bool isLoading, String? errorMessage, List<MapLocation> locations, String? selectedLocationId
});


@override $MapCoordinateCopyWith<$Res> get cameraCenter;

}
/// @nodoc
class __$MapboxSampleStateCopyWithImpl<$Res>
    implements _$MapboxSampleStateCopyWith<$Res> {
  __$MapboxSampleStateCopyWithImpl(this._self, this._then);

  final _MapboxSampleState _self;
  final $Res Function(_MapboxSampleState) _then;

/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cameraCenter = null,Object? cameraZoom = null,Object? isLoading = null,Object? errorMessage = freezed,Object? locations = null,Object? selectedLocationId = freezed,}) {
  return _then(_MapboxSampleState(
cameraCenter: null == cameraCenter ? _self.cameraCenter : cameraCenter // ignore: cast_nullable_to_non_nullable
as MapCoordinate,cameraZoom: null == cameraZoom ? _self.cameraZoom : cameraZoom // ignore: cast_nullable_to_non_nullable
as double,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedLocationId: freezed == selectedLocationId ? _self.selectedLocationId : selectedLocationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MapboxSampleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapCoordinateCopyWith<$Res> get cameraCenter {
  
  return $MapCoordinateCopyWith<$Res>(_self.cameraCenter, (value) {
    return _then(_self.copyWith(cameraCenter: value));
  });
}
}

// dart format on
