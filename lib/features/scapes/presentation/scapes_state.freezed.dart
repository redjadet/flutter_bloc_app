// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scapes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScapesState {

 List<Scape> get scapes; ScapesViewMode get viewMode; bool get isLoading; String? get errorMessage;
/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScapesStateCopyWith<ScapesState> get copyWith => _$ScapesStateCopyWithImpl<ScapesState>(this as ScapesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesState&&const DeepCollectionEquality().equals(other.scapes, scapes)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(scapes),viewMode,isLoading,errorMessage);

@override
String toString() {
  return 'ScapesState(scapes: $scapes, viewMode: $viewMode, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ScapesStateCopyWith<$Res>  {
  factory $ScapesStateCopyWith(ScapesState value, $Res Function(ScapesState) _then) = _$ScapesStateCopyWithImpl;
@useResult
$Res call({
 List<Scape> scapes, ScapesViewMode viewMode, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$ScapesStateCopyWithImpl<$Res>
    implements $ScapesStateCopyWith<$Res> {
  _$ScapesStateCopyWithImpl(this._self, this._then);

  final ScapesState _self;
  final $Res Function(ScapesState) _then;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scapes = null,Object? viewMode = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
scapes: null == scapes ? _self.scapes : scapes // ignore: cast_nullable_to_non_nullable
as List<Scape>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ScapesViewMode,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScapesState].
extension ScapesStatePatterns on ScapesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScapesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScapesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScapesState value)  $default,){
final _that = this;
switch (_that) {
case _ScapesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScapesState value)?  $default,){
final _that = this;
switch (_that) {
case _ScapesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Scape> scapes,  ScapesViewMode viewMode,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScapesState() when $default != null:
return $default(_that.scapes,_that.viewMode,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Scape> scapes,  ScapesViewMode viewMode,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ScapesState():
return $default(_that.scapes,_that.viewMode,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Scape> scapes,  ScapesViewMode viewMode,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ScapesState() when $default != null:
return $default(_that.scapes,_that.viewMode,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ScapesState extends ScapesState {
  const _ScapesState({final  List<Scape> scapes = const <Scape>[], this.viewMode = ScapesViewMode.grid, this.isLoading = false, this.errorMessage}): _scapes = scapes,super._();
  

 final  List<Scape> _scapes;
@override@JsonKey() List<Scape> get scapes {
  if (_scapes is EqualUnmodifiableListView) return _scapes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scapes);
}

@override@JsonKey() final  ScapesViewMode viewMode;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScapesStateCopyWith<_ScapesState> get copyWith => __$ScapesStateCopyWithImpl<_ScapesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScapesState&&const DeepCollectionEquality().equals(other._scapes, _scapes)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scapes),viewMode,isLoading,errorMessage);

@override
String toString() {
  return 'ScapesState(scapes: $scapes, viewMode: $viewMode, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ScapesStateCopyWith<$Res> implements $ScapesStateCopyWith<$Res> {
  factory _$ScapesStateCopyWith(_ScapesState value, $Res Function(_ScapesState) _then) = __$ScapesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Scape> scapes, ScapesViewMode viewMode, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$ScapesStateCopyWithImpl<$Res>
    implements _$ScapesStateCopyWith<$Res> {
  __$ScapesStateCopyWithImpl(this._self, this._then);

  final _ScapesState _self;
  final $Res Function(_ScapesState) _then;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scapes = null,Object? viewMode = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_ScapesState(
scapes: null == scapes ? _self._scapes : scapes // ignore: cast_nullable_to_non_nullable
as List<Scape>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ScapesViewMode,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
