// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartState {

 ViewStatus get status; List<ChartPoint> get points; String? get errorMessage; bool get zoomEnabled;
/// Create a copy of ChartState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartStateCopyWith<ChartState> get copyWith => _$ChartStateCopyWithImpl<ChartState>(this as ChartState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.zoomEnabled, zoomEnabled) || other.zoomEnabled == zoomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(points),errorMessage,zoomEnabled);

@override
String toString() {
  return 'ChartState(status: $status, points: $points, errorMessage: $errorMessage, zoomEnabled: $zoomEnabled)';
}


}

/// @nodoc
abstract mixin class $ChartStateCopyWith<$Res>  {
  factory $ChartStateCopyWith(ChartState value, $Res Function(ChartState) _then) = _$ChartStateCopyWithImpl;
@useResult
$Res call({
 ViewStatus status, List<ChartPoint> points, String? errorMessage, bool zoomEnabled
});




}
/// @nodoc
class _$ChartStateCopyWithImpl<$Res>
    implements $ChartStateCopyWith<$Res> {
  _$ChartStateCopyWithImpl(this._self, this._then);

  final ChartState _self;
  final $Res Function(ChartState) _then;

/// Create a copy of ChartState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? points = null,Object? errorMessage = freezed,Object? zoomEnabled = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<ChartPoint>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,zoomEnabled: null == zoomEnabled ? _self.zoomEnabled : zoomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartState].
extension ChartStatePatterns on ChartState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartState value)  $default,){
final _that = this;
switch (_that) {
case _ChartState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartState value)?  $default,){
final _that = this;
switch (_that) {
case _ChartState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ViewStatus status,  List<ChartPoint> points,  String? errorMessage,  bool zoomEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartState() when $default != null:
return $default(_that.status,_that.points,_that.errorMessage,_that.zoomEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ViewStatus status,  List<ChartPoint> points,  String? errorMessage,  bool zoomEnabled)  $default,) {final _that = this;
switch (_that) {
case _ChartState():
return $default(_that.status,_that.points,_that.errorMessage,_that.zoomEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ViewStatus status,  List<ChartPoint> points,  String? errorMessage,  bool zoomEnabled)?  $default,) {final _that = this;
switch (_that) {
case _ChartState() when $default != null:
return $default(_that.status,_that.points,_that.errorMessage,_that.zoomEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _ChartState extends ChartState {
  const _ChartState({this.status = ViewStatus.initial, final  List<ChartPoint> points = const <ChartPoint>[], this.errorMessage, this.zoomEnabled = false}): _points = points,super._();
  

@override@JsonKey() final  ViewStatus status;
 final  List<ChartPoint> _points;
@override@JsonKey() List<ChartPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  String? errorMessage;
@override@JsonKey() final  bool zoomEnabled;

/// Create a copy of ChartState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartStateCopyWith<_ChartState> get copyWith => __$ChartStateCopyWithImpl<_ChartState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.zoomEnabled, zoomEnabled) || other.zoomEnabled == zoomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_points),errorMessage,zoomEnabled);

@override
String toString() {
  return 'ChartState(status: $status, points: $points, errorMessage: $errorMessage, zoomEnabled: $zoomEnabled)';
}


}

/// @nodoc
abstract mixin class _$ChartStateCopyWith<$Res> implements $ChartStateCopyWith<$Res> {
  factory _$ChartStateCopyWith(_ChartState value, $Res Function(_ChartState) _then) = __$ChartStateCopyWithImpl;
@override @useResult
$Res call({
 ViewStatus status, List<ChartPoint> points, String? errorMessage, bool zoomEnabled
});




}
/// @nodoc
class __$ChartStateCopyWithImpl<$Res>
    implements _$ChartStateCopyWith<$Res> {
  __$ChartStateCopyWithImpl(this._self, this._then);

  final _ChartState _self;
  final $Res Function(_ChartState) _then;

/// Create a copy of ChartState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? points = null,Object? errorMessage = freezed,Object? zoomEnabled = null,}) {
  return _then(_ChartState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<ChartPoint>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,zoomEnabled: null == zoomEnabled ? _self.zoomEnabled : zoomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
