// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_sample_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapSampleState {

 bool get isLoading; String? get errorMessage; gmaps.CameraPosition get cameraPosition; Set<gmaps.Marker> get markers; gmaps.MapType get mapType; bool get trafficEnabled; List<MapLocation> get locations; gmaps.MarkerId? get selectedMarkerId;
/// Create a copy of MapSampleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapSampleStateCopyWith<MapSampleState> get copyWith => _$MapSampleStateCopyWithImpl<MapSampleState>(this as MapSampleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapSampleState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.cameraPosition, cameraPosition) || other.cameraPosition == cameraPosition)&&const DeepCollectionEquality().equals(other.markers, markers)&&(identical(other.mapType, mapType) || other.mapType == mapType)&&(identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled)&&const DeepCollectionEquality().equals(other.locations, locations)&&(identical(other.selectedMarkerId, selectedMarkerId) || other.selectedMarkerId == selectedMarkerId));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,cameraPosition,const DeepCollectionEquality().hash(markers),mapType,trafficEnabled,const DeepCollectionEquality().hash(locations),selectedMarkerId);

@override
String toString() {
  return 'MapSampleState(isLoading: $isLoading, errorMessage: $errorMessage, cameraPosition: $cameraPosition, markers: $markers, mapType: $mapType, trafficEnabled: $trafficEnabled, locations: $locations, selectedMarkerId: $selectedMarkerId)';
}


}

/// @nodoc
abstract mixin class $MapSampleStateCopyWith<$Res>  {
  factory $MapSampleStateCopyWith(MapSampleState value, $Res Function(MapSampleState) _then) = _$MapSampleStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, gmaps.CameraPosition cameraPosition, Set<gmaps.Marker> markers, gmaps.MapType mapType, bool trafficEnabled, List<MapLocation> locations, gmaps.MarkerId? selectedMarkerId
});




}
/// @nodoc
class _$MapSampleStateCopyWithImpl<$Res>
    implements $MapSampleStateCopyWith<$Res> {
  _$MapSampleStateCopyWithImpl(this._self, this._then);

  final MapSampleState _self;
  final $Res Function(MapSampleState) _then;

/// Create a copy of MapSampleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? cameraPosition = null,Object? markers = null,Object? mapType = null,Object? trafficEnabled = null,Object? locations = null,Object? selectedMarkerId = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,cameraPosition: null == cameraPosition ? _self.cameraPosition : cameraPosition // ignore: cast_nullable_to_non_nullable
as gmaps.CameraPosition,markers: null == markers ? _self.markers : markers // ignore: cast_nullable_to_non_nullable
as Set<gmaps.Marker>,mapType: null == mapType ? _self.mapType : mapType // ignore: cast_nullable_to_non_nullable
as gmaps.MapType,trafficEnabled: null == trafficEnabled ? _self.trafficEnabled : trafficEnabled // ignore: cast_nullable_to_non_nullable
as bool,locations: null == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedMarkerId: freezed == selectedMarkerId ? _self.selectedMarkerId : selectedMarkerId // ignore: cast_nullable_to_non_nullable
as gmaps.MarkerId?,
  ));
}

}


/// Adds pattern-matching-related methods to [MapSampleState].
extension MapSampleStatePatterns on MapSampleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapSampleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapSampleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapSampleState value)  $default,){
final _that = this;
switch (_that) {
case _MapSampleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapSampleState value)?  $default,){
final _that = this;
switch (_that) {
case _MapSampleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  gmaps.CameraPosition cameraPosition,  Set<gmaps.Marker> markers,  gmaps.MapType mapType,  bool trafficEnabled,  List<MapLocation> locations,  gmaps.MarkerId? selectedMarkerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapSampleState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.cameraPosition,_that.markers,_that.mapType,_that.trafficEnabled,_that.locations,_that.selectedMarkerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  gmaps.CameraPosition cameraPosition,  Set<gmaps.Marker> markers,  gmaps.MapType mapType,  bool trafficEnabled,  List<MapLocation> locations,  gmaps.MarkerId? selectedMarkerId)  $default,) {final _that = this;
switch (_that) {
case _MapSampleState():
return $default(_that.isLoading,_that.errorMessage,_that.cameraPosition,_that.markers,_that.mapType,_that.trafficEnabled,_that.locations,_that.selectedMarkerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  gmaps.CameraPosition cameraPosition,  Set<gmaps.Marker> markers,  gmaps.MapType mapType,  bool trafficEnabled,  List<MapLocation> locations,  gmaps.MarkerId? selectedMarkerId)?  $default,) {final _that = this;
switch (_that) {
case _MapSampleState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.cameraPosition,_that.markers,_that.mapType,_that.trafficEnabled,_that.locations,_that.selectedMarkerId);case _:
  return null;

}
}

}

/// @nodoc


class _MapSampleState extends MapSampleState {
  const _MapSampleState({this.isLoading = true, this.errorMessage, required this.cameraPosition, final  Set<gmaps.Marker> markers = const <gmaps.Marker>{}, this.mapType = gmaps.MapType.normal, this.trafficEnabled = false, final  List<MapLocation> locations = const <MapLocation>[], this.selectedMarkerId}): _markers = markers,_locations = locations,super._();
  

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override final  gmaps.CameraPosition cameraPosition;
 final  Set<gmaps.Marker> _markers;
@override@JsonKey() Set<gmaps.Marker> get markers {
  if (_markers is EqualUnmodifiableSetView) return _markers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_markers);
}

@override@JsonKey() final  gmaps.MapType mapType;
@override@JsonKey() final  bool trafficEnabled;
 final  List<MapLocation> _locations;
@override@JsonKey() List<MapLocation> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}

@override final  gmaps.MarkerId? selectedMarkerId;

/// Create a copy of MapSampleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapSampleStateCopyWith<_MapSampleState> get copyWith => __$MapSampleStateCopyWithImpl<_MapSampleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapSampleState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.cameraPosition, cameraPosition) || other.cameraPosition == cameraPosition)&&const DeepCollectionEquality().equals(other._markers, _markers)&&(identical(other.mapType, mapType) || other.mapType == mapType)&&(identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled)&&const DeepCollectionEquality().equals(other._locations, _locations)&&(identical(other.selectedMarkerId, selectedMarkerId) || other.selectedMarkerId == selectedMarkerId));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,cameraPosition,const DeepCollectionEquality().hash(_markers),mapType,trafficEnabled,const DeepCollectionEquality().hash(_locations),selectedMarkerId);

@override
String toString() {
  return 'MapSampleState(isLoading: $isLoading, errorMessage: $errorMessage, cameraPosition: $cameraPosition, markers: $markers, mapType: $mapType, trafficEnabled: $trafficEnabled, locations: $locations, selectedMarkerId: $selectedMarkerId)';
}


}

/// @nodoc
abstract mixin class _$MapSampleStateCopyWith<$Res> implements $MapSampleStateCopyWith<$Res> {
  factory _$MapSampleStateCopyWith(_MapSampleState value, $Res Function(_MapSampleState) _then) = __$MapSampleStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, gmaps.CameraPosition cameraPosition, Set<gmaps.Marker> markers, gmaps.MapType mapType, bool trafficEnabled, List<MapLocation> locations, gmaps.MarkerId? selectedMarkerId
});




}
/// @nodoc
class __$MapSampleStateCopyWithImpl<$Res>
    implements _$MapSampleStateCopyWith<$Res> {
  __$MapSampleStateCopyWithImpl(this._self, this._then);

  final _MapSampleState _self;
  final $Res Function(_MapSampleState) _then;

/// Create a copy of MapSampleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? cameraPosition = null,Object? markers = null,Object? mapType = null,Object? trafficEnabled = null,Object? locations = null,Object? selectedMarkerId = freezed,}) {
  return _then(_MapSampleState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,cameraPosition: null == cameraPosition ? _self.cameraPosition : cameraPosition // ignore: cast_nullable_to_non_nullable
as gmaps.CameraPosition,markers: null == markers ? _self._markers : markers // ignore: cast_nullable_to_non_nullable
as Set<gmaps.Marker>,mapType: null == mapType ? _self.mapType : mapType // ignore: cast_nullable_to_non_nullable
as gmaps.MapType,trafficEnabled: null == trafficEnabled ? _self.trafficEnabled : trafficEnabled // ignore: cast_nullable_to_non_nullable
as bool,locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<MapLocation>,selectedMarkerId: freezed == selectedMarkerId ? _self.selectedMarkerId : selectedMarkerId // ignore: cast_nullable_to_non_nullable
as gmaps.MarkerId?,
  ));
}


}

// dart format on
