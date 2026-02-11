// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispersion_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispersionPoint {

 String get id; double get xMm; double get yMm; double get radialMm; double get holeDiameterMm; bool get isOutlierAuto; bool get isOutlierManual;
/// Create a copy of DispersionPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersionPointCopyWith<DispersionPoint> get copyWith => _$DispersionPointCopyWithImpl<DispersionPoint>(this as DispersionPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersionPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.xMm, xMm) || other.xMm == xMm)&&(identical(other.yMm, yMm) || other.yMm == yMm)&&(identical(other.radialMm, radialMm) || other.radialMm == radialMm)&&(identical(other.holeDiameterMm, holeDiameterMm) || other.holeDiameterMm == holeDiameterMm)&&(identical(other.isOutlierAuto, isOutlierAuto) || other.isOutlierAuto == isOutlierAuto)&&(identical(other.isOutlierManual, isOutlierManual) || other.isOutlierManual == isOutlierManual));
}


@override
int get hashCode => Object.hash(runtimeType,id,xMm,yMm,radialMm,holeDiameterMm,isOutlierAuto,isOutlierManual);

@override
String toString() {
  return 'DispersionPoint(id: $id, xMm: $xMm, yMm: $yMm, radialMm: $radialMm, holeDiameterMm: $holeDiameterMm, isOutlierAuto: $isOutlierAuto, isOutlierManual: $isOutlierManual)';
}


}

/// @nodoc
abstract mixin class $DispersionPointCopyWith<$Res>  {
  factory $DispersionPointCopyWith(DispersionPoint value, $Res Function(DispersionPoint) _then) = _$DispersionPointCopyWithImpl;
@useResult
$Res call({
 String id, double xMm, double yMm, double radialMm, double holeDiameterMm, bool isOutlierAuto, bool isOutlierManual
});




}
/// @nodoc
class _$DispersionPointCopyWithImpl<$Res>
    implements $DispersionPointCopyWith<$Res> {
  _$DispersionPointCopyWithImpl(this._self, this._then);

  final DispersionPoint _self;
  final $Res Function(DispersionPoint) _then;

/// Create a copy of DispersionPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? xMm = null,Object? yMm = null,Object? radialMm = null,Object? holeDiameterMm = null,Object? isOutlierAuto = null,Object? isOutlierManual = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,xMm: null == xMm ? _self.xMm : xMm // ignore: cast_nullable_to_non_nullable
as double,yMm: null == yMm ? _self.yMm : yMm // ignore: cast_nullable_to_non_nullable
as double,radialMm: null == radialMm ? _self.radialMm : radialMm // ignore: cast_nullable_to_non_nullable
as double,holeDiameterMm: null == holeDiameterMm ? _self.holeDiameterMm : holeDiameterMm // ignore: cast_nullable_to_non_nullable
as double,isOutlierAuto: null == isOutlierAuto ? _self.isOutlierAuto : isOutlierAuto // ignore: cast_nullable_to_non_nullable
as bool,isOutlierManual: null == isOutlierManual ? _self.isOutlierManual : isOutlierManual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DispersionPoint].
extension DispersionPointPatterns on DispersionPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispersionPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispersionPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispersionPoint value)  $default,){
final _that = this;
switch (_that) {
case _DispersionPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispersionPoint value)?  $default,){
final _that = this;
switch (_that) {
case _DispersionPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double xMm,  double yMm,  double radialMm,  double holeDiameterMm,  bool isOutlierAuto,  bool isOutlierManual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispersionPoint() when $default != null:
return $default(_that.id,_that.xMm,_that.yMm,_that.radialMm,_that.holeDiameterMm,_that.isOutlierAuto,_that.isOutlierManual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double xMm,  double yMm,  double radialMm,  double holeDiameterMm,  bool isOutlierAuto,  bool isOutlierManual)  $default,) {final _that = this;
switch (_that) {
case _DispersionPoint():
return $default(_that.id,_that.xMm,_that.yMm,_that.radialMm,_that.holeDiameterMm,_that.isOutlierAuto,_that.isOutlierManual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double xMm,  double yMm,  double radialMm,  double holeDiameterMm,  bool isOutlierAuto,  bool isOutlierManual)?  $default,) {final _that = this;
switch (_that) {
case _DispersionPoint() when $default != null:
return $default(_that.id,_that.xMm,_that.yMm,_that.radialMm,_that.holeDiameterMm,_that.isOutlierAuto,_that.isOutlierManual);case _:
  return null;

}
}

}

/// @nodoc


class _DispersionPoint extends DispersionPoint {
  const _DispersionPoint({required this.id, required this.xMm, required this.yMm, required this.radialMm, required this.holeDiameterMm, this.isOutlierAuto = false, this.isOutlierManual = false}): super._();
  

@override final  String id;
@override final  double xMm;
@override final  double yMm;
@override final  double radialMm;
@override final  double holeDiameterMm;
@override@JsonKey() final  bool isOutlierAuto;
@override@JsonKey() final  bool isOutlierManual;

/// Create a copy of DispersionPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispersionPointCopyWith<_DispersionPoint> get copyWith => __$DispersionPointCopyWithImpl<_DispersionPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispersionPoint&&(identical(other.id, id) || other.id == id)&&(identical(other.xMm, xMm) || other.xMm == xMm)&&(identical(other.yMm, yMm) || other.yMm == yMm)&&(identical(other.radialMm, radialMm) || other.radialMm == radialMm)&&(identical(other.holeDiameterMm, holeDiameterMm) || other.holeDiameterMm == holeDiameterMm)&&(identical(other.isOutlierAuto, isOutlierAuto) || other.isOutlierAuto == isOutlierAuto)&&(identical(other.isOutlierManual, isOutlierManual) || other.isOutlierManual == isOutlierManual));
}


@override
int get hashCode => Object.hash(runtimeType,id,xMm,yMm,radialMm,holeDiameterMm,isOutlierAuto,isOutlierManual);

@override
String toString() {
  return 'DispersionPoint(id: $id, xMm: $xMm, yMm: $yMm, radialMm: $radialMm, holeDiameterMm: $holeDiameterMm, isOutlierAuto: $isOutlierAuto, isOutlierManual: $isOutlierManual)';
}


}

/// @nodoc
abstract mixin class _$DispersionPointCopyWith<$Res> implements $DispersionPointCopyWith<$Res> {
  factory _$DispersionPointCopyWith(_DispersionPoint value, $Res Function(_DispersionPoint) _then) = __$DispersionPointCopyWithImpl;
@override @useResult
$Res call({
 String id, double xMm, double yMm, double radialMm, double holeDiameterMm, bool isOutlierAuto, bool isOutlierManual
});




}
/// @nodoc
class __$DispersionPointCopyWithImpl<$Res>
    implements _$DispersionPointCopyWith<$Res> {
  __$DispersionPointCopyWithImpl(this._self, this._then);

  final _DispersionPoint _self;
  final $Res Function(_DispersionPoint) _then;

/// Create a copy of DispersionPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? xMm = null,Object? yMm = null,Object? radialMm = null,Object? holeDiameterMm = null,Object? isOutlierAuto = null,Object? isOutlierManual = null,}) {
  return _then(_DispersionPoint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,xMm: null == xMm ? _self.xMm : xMm // ignore: cast_nullable_to_non_nullable
as double,yMm: null == yMm ? _self.yMm : yMm // ignore: cast_nullable_to_non_nullable
as double,radialMm: null == radialMm ? _self.radialMm : radialMm // ignore: cast_nullable_to_non_nullable
as double,holeDiameterMm: null == holeDiameterMm ? _self.holeDiameterMm : holeDiameterMm // ignore: cast_nullable_to_non_nullable
as double,isOutlierAuto: null == isOutlierAuto ? _self.isOutlierAuto : isOutlierAuto // ignore: cast_nullable_to_non_nullable
as bool,isOutlierManual: null == isOutlierManual ? _self.isOutlierManual : isOutlierManual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
