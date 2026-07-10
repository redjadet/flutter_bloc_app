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





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScapesState()';
}


}

/// @nodoc
class $ScapesStateCopyWith<$Res>  {
$ScapesStateCopyWith(ScapesState _, $Res Function(ScapesState) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ScapesInitial value)?  initial,TResult Function( ScapesLoading value)?  loading,TResult Function( ScapesReady value)?  ready,TResult Function( ScapesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ScapesInitial() when initial != null:
return initial(_that);case ScapesLoading() when loading != null:
return loading(_that);case ScapesReady() when ready != null:
return ready(_that);case ScapesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ScapesInitial value)  initial,required TResult Function( ScapesLoading value)  loading,required TResult Function( ScapesReady value)  ready,required TResult Function( ScapesError value)  error,}){
final _that = this;
switch (_that) {
case ScapesInitial():
return initial(_that);case ScapesLoading():
return loading(_that);case ScapesReady():
return ready(_that);case ScapesError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ScapesInitial value)?  initial,TResult? Function( ScapesLoading value)?  loading,TResult? Function( ScapesReady value)?  ready,TResult? Function( ScapesError value)?  error,}){
final _that = this;
switch (_that) {
case ScapesInitial() when initial != null:
return initial(_that);case ScapesLoading() when loading != null:
return loading(_that);case ScapesReady() when ready != null:
return ready(_that);case ScapesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Scape> scapes,  ScapesViewMode viewMode)?  ready,TResult Function( AppError error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ScapesInitial() when initial != null:
return initial();case ScapesLoading() when loading != null:
return loading();case ScapesReady() when ready != null:
return ready(_that.scapes,_that.viewMode);case ScapesError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Scape> scapes,  ScapesViewMode viewMode)  ready,required TResult Function( AppError error)  error,}) {final _that = this;
switch (_that) {
case ScapesInitial():
return initial();case ScapesLoading():
return loading();case ScapesReady():
return ready(_that.scapes,_that.viewMode);case ScapesError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Scape> scapes,  ScapesViewMode viewMode)?  ready,TResult? Function( AppError error)?  error,}) {final _that = this;
switch (_that) {
case ScapesInitial() when initial != null:
return initial();case ScapesLoading() when loading != null:
return loading();case ScapesReady() when ready != null:
return ready(_that.scapes,_that.viewMode);case ScapesError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ScapesInitial extends ScapesState {
  const ScapesInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScapesState.initial()';
}


}




/// @nodoc


class ScapesLoading extends ScapesState {
  const ScapesLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScapesState.loading()';
}


}




/// @nodoc


class ScapesReady extends ScapesState {
  const ScapesReady({required final  List<Scape> scapes, this.viewMode = ScapesViewMode.grid}): _scapes = scapes,super._();
  

 final  List<Scape> _scapes;
 List<Scape> get scapes {
  if (_scapes is EqualUnmodifiableListView) return _scapes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scapes);
}

@JsonKey() final  ScapesViewMode viewMode;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScapesReadyCopyWith<ScapesReady> get copyWith => _$ScapesReadyCopyWithImpl<ScapesReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesReady&&const DeepCollectionEquality().equals(other._scapes, _scapes)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scapes),viewMode);

@override
String toString() {
  return 'ScapesState.ready(scapes: $scapes, viewMode: $viewMode)';
}


}

/// @nodoc
abstract mixin class $ScapesReadyCopyWith<$Res> implements $ScapesStateCopyWith<$Res> {
  factory $ScapesReadyCopyWith(ScapesReady value, $Res Function(ScapesReady) _then) = _$ScapesReadyCopyWithImpl;
@useResult
$Res call({
 List<Scape> scapes, ScapesViewMode viewMode
});




}
/// @nodoc
class _$ScapesReadyCopyWithImpl<$Res>
    implements $ScapesReadyCopyWith<$Res> {
  _$ScapesReadyCopyWithImpl(this._self, this._then);

  final ScapesReady _self;
  final $Res Function(ScapesReady) _then;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scapes = null,Object? viewMode = null,}) {
  return _then(ScapesReady(
scapes: null == scapes ? _self._scapes : scapes // ignore: cast_nullable_to_non_nullable
as List<Scape>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ScapesViewMode,
  ));
}


}

/// @nodoc


class ScapesError extends ScapesState {
  const ScapesError(this.error): super._();
  

 final  AppError error;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScapesErrorCopyWith<ScapesError> get copyWith => _$ScapesErrorCopyWithImpl<ScapesError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScapesError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ScapesState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $ScapesErrorCopyWith<$Res> implements $ScapesStateCopyWith<$Res> {
  factory $ScapesErrorCopyWith(ScapesError value, $Res Function(ScapesError) _then) = _$ScapesErrorCopyWithImpl;
@useResult
$Res call({
 AppError error
});




}
/// @nodoc
class _$ScapesErrorCopyWithImpl<$Res>
    implements $ScapesErrorCopyWith<$Res> {
  _$ScapesErrorCopyWithImpl(this._self, this._then);

  final ScapesError _self;
  final $Res Function(ScapesError) _then;

/// Create a copy of ScapesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ScapesError(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppError,
  ));
}


}

// dart format on
