// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whiteboard_painter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WhiteboardStroke implements DiagnosticableTreeMixin {

 List<Offset> get points; Color get color; double get width;
/// Create a copy of WhiteboardStroke
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhiteboardStrokeCopyWith<WhiteboardStroke> get copyWith => _$WhiteboardStrokeCopyWithImpl<WhiteboardStroke>(this as WhiteboardStroke, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WhiteboardStroke'))
    ..add(DiagnosticsProperty('points', points))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('width', width));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhiteboardStroke&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),color,width);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WhiteboardStroke(points: $points, color: $color, width: $width)';
}


}

/// @nodoc
abstract mixin class $WhiteboardStrokeCopyWith<$Res>  {
  factory $WhiteboardStrokeCopyWith(WhiteboardStroke value, $Res Function(WhiteboardStroke) _then) = _$WhiteboardStrokeCopyWithImpl;
@useResult
$Res call({
 List<Offset> points, Color color, double width
});




}
/// @nodoc
class _$WhiteboardStrokeCopyWithImpl<$Res>
    implements $WhiteboardStrokeCopyWith<$Res> {
  _$WhiteboardStrokeCopyWithImpl(this._self, this._then);

  final WhiteboardStroke _self;
  final $Res Function(WhiteboardStroke) _then;

/// Create a copy of WhiteboardStroke
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? color = null,Object? width = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [WhiteboardStroke].
extension WhiteboardStrokePatterns on WhiteboardStroke {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _WhiteboardStroke value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WhiteboardStroke() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _WhiteboardStroke value)  raw,}){
final _that = this;
switch (_that) {
case _WhiteboardStroke():
return raw(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _WhiteboardStroke value)?  raw,}){
final _that = this;
switch (_that) {
case _WhiteboardStroke() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<Offset> points,  Color color,  double width)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WhiteboardStroke() when raw != null:
return raw(_that.points,_that.color,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<Offset> points,  Color color,  double width)  raw,}) {final _that = this;
switch (_that) {
case _WhiteboardStroke():
return raw(_that.points,_that.color,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<Offset> points,  Color color,  double width)?  raw,}) {final _that = this;
switch (_that) {
case _WhiteboardStroke() when raw != null:
return raw(_that.points,_that.color,_that.width);case _:
  return null;

}
}

}

/// @nodoc


class _WhiteboardStroke with DiagnosticableTreeMixin implements WhiteboardStroke {
  const _WhiteboardStroke({required final  List<Offset> points, required this.color, required this.width}): _points = points;
  

 final  List<Offset> _points;
@override List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  Color color;
@override final  double width;

/// Create a copy of WhiteboardStroke
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WhiteboardStrokeCopyWith<_WhiteboardStroke> get copyWith => __$WhiteboardStrokeCopyWithImpl<_WhiteboardStroke>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WhiteboardStroke.raw'))
    ..add(DiagnosticsProperty('points', points))..add(DiagnosticsProperty('color', color))..add(DiagnosticsProperty('width', width));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WhiteboardStroke&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),color,width);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WhiteboardStroke.raw(points: $points, color: $color, width: $width)';
}


}

/// @nodoc
abstract mixin class _$WhiteboardStrokeCopyWith<$Res> implements $WhiteboardStrokeCopyWith<$Res> {
  factory _$WhiteboardStrokeCopyWith(_WhiteboardStroke value, $Res Function(_WhiteboardStroke) _then) = __$WhiteboardStrokeCopyWithImpl;
@override @useResult
$Res call({
 List<Offset> points, Color color, double width
});




}
/// @nodoc
class __$WhiteboardStrokeCopyWithImpl<$Res>
    implements _$WhiteboardStrokeCopyWith<$Res> {
  __$WhiteboardStrokeCopyWithImpl(this._self, this._then);

  final _WhiteboardStroke _self;
  final $Res Function(_WhiteboardStroke) _then;

/// Create a copy of WhiteboardStroke
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? color = null,Object? width = null,}) {
  return _then(_WhiteboardStroke(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
