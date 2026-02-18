// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartViewData {

 bool get showLoading; bool get showError; bool get showEmpty; List<ChartPoint> get points; bool get zoomEnabled;
/// Create a copy of _ChartViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartViewDataCopyWith<_ChartViewData> get copyWith => __$ChartViewDataCopyWithImpl<_ChartViewData>(this as _ChartViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartViewData&&(identical(other.showLoading, showLoading) || other.showLoading == showLoading)&&(identical(other.showError, showError) || other.showError == showError)&&(identical(other.showEmpty, showEmpty) || other.showEmpty == showEmpty)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.zoomEnabled, zoomEnabled) || other.zoomEnabled == zoomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,showLoading,showError,showEmpty,const DeepCollectionEquality().hash(points),zoomEnabled);

@override
String toString() {
  return '_ChartViewData(showLoading: $showLoading, showError: $showError, showEmpty: $showEmpty, points: $points, zoomEnabled: $zoomEnabled)';
}


}

/// @nodoc
abstract mixin class _$ChartViewDataCopyWith<$Res>  {
  factory _$ChartViewDataCopyWith(_ChartViewData value, $Res Function(_ChartViewData) _then) = __$ChartViewDataCopyWithImpl;
@useResult
$Res call({
 bool showLoading, bool showError, bool showEmpty, List<ChartPoint> points, bool zoomEnabled
});




}
/// @nodoc
class __$ChartViewDataCopyWithImpl<$Res>
    implements _$ChartViewDataCopyWith<$Res> {
  __$ChartViewDataCopyWithImpl(this._self, this._then);

  final _ChartViewData _self;
  final $Res Function(_ChartViewData) _then;

/// Create a copy of _ChartViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showLoading = null,Object? showError = null,Object? showEmpty = null,Object? points = null,Object? zoomEnabled = null,}) {
  return _then(_self.copyWith(
showLoading: null == showLoading ? _self.showLoading : showLoading // ignore: cast_nullable_to_non_nullable
as bool,showError: null == showError ? _self.showError : showError // ignore: cast_nullable_to_non_nullable
as bool,showEmpty: null == showEmpty ? _self.showEmpty : showEmpty // ignore: cast_nullable_to_non_nullable
as bool,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<ChartPoint>,zoomEnabled: null == zoomEnabled ? _self.zoomEnabled : zoomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_ChartViewData].
extension _ChartViewDataPatterns on _ChartViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __ChartViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __ChartViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __ChartViewData value)  $default,){
final _that = this;
switch (_that) {
case __ChartViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __ChartViewData value)?  $default,){
final _that = this;
switch (_that) {
case __ChartViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showLoading,  bool showError,  bool showEmpty,  List<ChartPoint> points,  bool zoomEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __ChartViewData() when $default != null:
return $default(_that.showLoading,_that.showError,_that.showEmpty,_that.points,_that.zoomEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showLoading,  bool showError,  bool showEmpty,  List<ChartPoint> points,  bool zoomEnabled)  $default,) {final _that = this;
switch (_that) {
case __ChartViewData():
return $default(_that.showLoading,_that.showError,_that.showEmpty,_that.points,_that.zoomEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showLoading,  bool showError,  bool showEmpty,  List<ChartPoint> points,  bool zoomEnabled)?  $default,) {final _that = this;
switch (_that) {
case __ChartViewData() when $default != null:
return $default(_that.showLoading,_that.showError,_that.showEmpty,_that.points,_that.zoomEnabled);case _:
  return null;

}
}

}

/// @nodoc


class __ChartViewData implements _ChartViewData {
  const __ChartViewData({required this.showLoading, required this.showError, required this.showEmpty, required final  List<ChartPoint> points, required this.zoomEnabled}): _points = points;
  

@override final  bool showLoading;
@override final  bool showError;
@override final  bool showEmpty;
 final  List<ChartPoint> _points;
@override List<ChartPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  bool zoomEnabled;

/// Create a copy of _ChartViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_ChartViewDataCopyWith<__ChartViewData> get copyWith => __$_ChartViewDataCopyWithImpl<__ChartViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __ChartViewData&&(identical(other.showLoading, showLoading) || other.showLoading == showLoading)&&(identical(other.showError, showError) || other.showError == showError)&&(identical(other.showEmpty, showEmpty) || other.showEmpty == showEmpty)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.zoomEnabled, zoomEnabled) || other.zoomEnabled == zoomEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,showLoading,showError,showEmpty,const DeepCollectionEquality().hash(_points),zoomEnabled);

@override
String toString() {
  return '_ChartViewData(showLoading: $showLoading, showError: $showError, showEmpty: $showEmpty, points: $points, zoomEnabled: $zoomEnabled)';
}


}

/// @nodoc
abstract mixin class _$_ChartViewDataCopyWith<$Res> implements _$ChartViewDataCopyWith<$Res> {
  factory _$_ChartViewDataCopyWith(__ChartViewData value, $Res Function(__ChartViewData) _then) = __$_ChartViewDataCopyWithImpl;
@override @useResult
$Res call({
 bool showLoading, bool showError, bool showEmpty, List<ChartPoint> points, bool zoomEnabled
});




}
/// @nodoc
class __$_ChartViewDataCopyWithImpl<$Res>
    implements _$_ChartViewDataCopyWith<$Res> {
  __$_ChartViewDataCopyWithImpl(this._self, this._then);

  final __ChartViewData _self;
  final $Res Function(__ChartViewData) _then;

/// Create a copy of _ChartViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showLoading = null,Object? showError = null,Object? showEmpty = null,Object? points = null,Object? zoomEnabled = null,}) {
  return _then(__ChartViewData(
showLoading: null == showLoading ? _self.showLoading : showLoading // ignore: cast_nullable_to_non_nullable
as bool,showError: null == showError ? _self.showError : showError // ignore: cast_nullable_to_non_nullable
as bool,showEmpty: null == showEmpty ? _self.showEmpty : showEmpty // ignore: cast_nullable_to_non_nullable
as bool,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<ChartPoint>,zoomEnabled: null == zoomEnabled ? _self.zoomEnabled : zoomEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
