// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispersion_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispersionGroup {

 String get id; String get name; DateTime get capturedAt; double get distanceToTargetMeters; String get imagePath; Calibration get calibration; PixelPoint get aimPointPx; List<DispersionPoint> get points;
/// Create a copy of DispersionGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersionGroupCopyWith<DispersionGroup> get copyWith => _$DispersionGroupCopyWithImpl<DispersionGroup>(this as DispersionGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersionGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.distanceToTargetMeters, distanceToTargetMeters) || other.distanceToTargetMeters == distanceToTargetMeters)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.calibration, calibration) || other.calibration == calibration)&&(identical(other.aimPointPx, aimPointPx) || other.aimPointPx == aimPointPx)&&const DeepCollectionEquality().equals(other.points, points));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,capturedAt,distanceToTargetMeters,imagePath,calibration,aimPointPx,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'DispersionGroup(id: $id, name: $name, capturedAt: $capturedAt, distanceToTargetMeters: $distanceToTargetMeters, imagePath: $imagePath, calibration: $calibration, aimPointPx: $aimPointPx, points: $points)';
}


}

/// @nodoc
abstract mixin class $DispersionGroupCopyWith<$Res>  {
  factory $DispersionGroupCopyWith(DispersionGroup value, $Res Function(DispersionGroup) _then) = _$DispersionGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime capturedAt, double distanceToTargetMeters, String imagePath, Calibration calibration, PixelPoint aimPointPx, List<DispersionPoint> points
});




}
/// @nodoc
class _$DispersionGroupCopyWithImpl<$Res>
    implements $DispersionGroupCopyWith<$Res> {
  _$DispersionGroupCopyWithImpl(this._self, this._then);

  final DispersionGroup _self;
  final $Res Function(DispersionGroup) _then;

/// Create a copy of DispersionGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? capturedAt = null,Object? distanceToTargetMeters = null,Object? imagePath = null,Object? calibration = null,Object? aimPointPx = null,Object? points = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceToTargetMeters: null == distanceToTargetMeters ? _self.distanceToTargetMeters : distanceToTargetMeters // ignore: cast_nullable_to_non_nullable
as double,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,calibration: null == calibration ? _self.calibration : calibration // ignore: cast_nullable_to_non_nullable
as Calibration,aimPointPx: null == aimPointPx ? _self.aimPointPx : aimPointPx // ignore: cast_nullable_to_non_nullable
as PixelPoint,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [DispersionGroup].
extension DispersionGroupPatterns on DispersionGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispersionGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispersionGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispersionGroup value)  $default,){
final _that = this;
switch (_that) {
case _DispersionGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispersionGroup value)?  $default,){
final _that = this;
switch (_that) {
case _DispersionGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime capturedAt,  double distanceToTargetMeters,  String imagePath,  Calibration calibration,  PixelPoint aimPointPx,  List<DispersionPoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispersionGroup() when $default != null:
return $default(_that.id,_that.name,_that.capturedAt,_that.distanceToTargetMeters,_that.imagePath,_that.calibration,_that.aimPointPx,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime capturedAt,  double distanceToTargetMeters,  String imagePath,  Calibration calibration,  PixelPoint aimPointPx,  List<DispersionPoint> points)  $default,) {final _that = this;
switch (_that) {
case _DispersionGroup():
return $default(_that.id,_that.name,_that.capturedAt,_that.distanceToTargetMeters,_that.imagePath,_that.calibration,_that.aimPointPx,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime capturedAt,  double distanceToTargetMeters,  String imagePath,  Calibration calibration,  PixelPoint aimPointPx,  List<DispersionPoint> points)?  $default,) {final _that = this;
switch (_that) {
case _DispersionGroup() when $default != null:
return $default(_that.id,_that.name,_that.capturedAt,_that.distanceToTargetMeters,_that.imagePath,_that.calibration,_that.aimPointPx,_that.points);case _:
  return null;

}
}

}

/// @nodoc


class _DispersionGroup extends DispersionGroup {
  const _DispersionGroup({required this.id, required this.name, required this.capturedAt, required this.distanceToTargetMeters, required this.imagePath, required this.calibration, required this.aimPointPx, required final  List<DispersionPoint> points}): _points = points,super._();
  

@override final  String id;
@override final  String name;
@override final  DateTime capturedAt;
@override final  double distanceToTargetMeters;
@override final  String imagePath;
@override final  Calibration calibration;
@override final  PixelPoint aimPointPx;
 final  List<DispersionPoint> _points;
@override List<DispersionPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of DispersionGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispersionGroupCopyWith<_DispersionGroup> get copyWith => __$DispersionGroupCopyWithImpl<_DispersionGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispersionGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.distanceToTargetMeters, distanceToTargetMeters) || other.distanceToTargetMeters == distanceToTargetMeters)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.calibration, calibration) || other.calibration == calibration)&&(identical(other.aimPointPx, aimPointPx) || other.aimPointPx == aimPointPx)&&const DeepCollectionEquality().equals(other._points, _points));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,capturedAt,distanceToTargetMeters,imagePath,calibration,aimPointPx,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'DispersionGroup(id: $id, name: $name, capturedAt: $capturedAt, distanceToTargetMeters: $distanceToTargetMeters, imagePath: $imagePath, calibration: $calibration, aimPointPx: $aimPointPx, points: $points)';
}


}

/// @nodoc
abstract mixin class _$DispersionGroupCopyWith<$Res> implements $DispersionGroupCopyWith<$Res> {
  factory _$DispersionGroupCopyWith(_DispersionGroup value, $Res Function(_DispersionGroup) _then) = __$DispersionGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime capturedAt, double distanceToTargetMeters, String imagePath, Calibration calibration, PixelPoint aimPointPx, List<DispersionPoint> points
});




}
/// @nodoc
class __$DispersionGroupCopyWithImpl<$Res>
    implements _$DispersionGroupCopyWith<$Res> {
  __$DispersionGroupCopyWithImpl(this._self, this._then);

  final _DispersionGroup _self;
  final $Res Function(_DispersionGroup) _then;

/// Create a copy of DispersionGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? capturedAt = null,Object? distanceToTargetMeters = null,Object? imagePath = null,Object? calibration = null,Object? aimPointPx = null,Object? points = null,}) {
  return _then(_DispersionGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceToTargetMeters: null == distanceToTargetMeters ? _self.distanceToTargetMeters : distanceToTargetMeters // ignore: cast_nullable_to_non_nullable
as double,imagePath: null == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String,calibration: null == calibration ? _self.calibration : calibration // ignore: cast_nullable_to_non_nullable
as Calibration,aimPointPx: null == aimPointPx ? _self.aimPointPx : aimPointPx // ignore: cast_nullable_to_non_nullable
as PixelPoint,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<DispersionPoint>,
  ));
}


}

// dart format on
