// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CounterError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CounterError()';
}


}

/// @nodoc
class $CounterErrorCopyWith<$Res>  {
$CounterErrorCopyWith(CounterError _, $Res Function(CounterError) __);
}


/// Adds pattern-matching-related methods to [CounterError].
extension CounterErrorPatterns on CounterError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CannotGoBelowZero value)?  cannotGoBelowZero,TResult Function( _LoadCounterError value)?  load,TResult Function( _SaveCounterError value)?  save,TResult Function( _UnknownCounterError value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CannotGoBelowZero() when cannotGoBelowZero != null:
return cannotGoBelowZero(_that);case _LoadCounterError() when load != null:
return load(_that);case _SaveCounterError() when save != null:
return save(_that);case _UnknownCounterError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CannotGoBelowZero value)  cannotGoBelowZero,required TResult Function( _LoadCounterError value)  load,required TResult Function( _SaveCounterError value)  save,required TResult Function( _UnknownCounterError value)  unknown,}){
final _that = this;
switch (_that) {
case _CannotGoBelowZero():
return cannotGoBelowZero(_that);case _LoadCounterError():
return load(_that);case _SaveCounterError():
return save(_that);case _UnknownCounterError():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CannotGoBelowZero value)?  cannotGoBelowZero,TResult? Function( _LoadCounterError value)?  load,TResult? Function( _SaveCounterError value)?  save,TResult? Function( _UnknownCounterError value)?  unknown,}){
final _that = this;
switch (_that) {
case _CannotGoBelowZero() when cannotGoBelowZero != null:
return cannotGoBelowZero(_that);case _LoadCounterError() when load != null:
return load(_that);case _SaveCounterError() when save != null:
return save(_that);case _UnknownCounterError() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  cannotGoBelowZero,TResult Function( Object? originalError,  String? message)?  load,TResult Function( Object? originalError,  String? message)?  save,TResult Function( Object? originalError,  String? message)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CannotGoBelowZero() when cannotGoBelowZero != null:
return cannotGoBelowZero();case _LoadCounterError() when load != null:
return load(_that.originalError,_that.message);case _SaveCounterError() when save != null:
return save(_that.originalError,_that.message);case _UnknownCounterError() when unknown != null:
return unknown(_that.originalError,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  cannotGoBelowZero,required TResult Function( Object? originalError,  String? message)  load,required TResult Function( Object? originalError,  String? message)  save,required TResult Function( Object? originalError,  String? message)  unknown,}) {final _that = this;
switch (_that) {
case _CannotGoBelowZero():
return cannotGoBelowZero();case _LoadCounterError():
return load(_that.originalError,_that.message);case _SaveCounterError():
return save(_that.originalError,_that.message);case _UnknownCounterError():
return unknown(_that.originalError,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  cannotGoBelowZero,TResult? Function( Object? originalError,  String? message)?  load,TResult? Function( Object? originalError,  String? message)?  save,TResult? Function( Object? originalError,  String? message)?  unknown,}) {final _that = this;
switch (_that) {
case _CannotGoBelowZero() when cannotGoBelowZero != null:
return cannotGoBelowZero();case _LoadCounterError() when load != null:
return load(_that.originalError,_that.message);case _SaveCounterError() when save != null:
return save(_that.originalError,_that.message);case _UnknownCounterError() when unknown != null:
return unknown(_that.originalError,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CannotGoBelowZero extends CounterError {
  const _CannotGoBelowZero(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CannotGoBelowZero);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CounterError.cannotGoBelowZero()';
}


}




/// @nodoc


class _LoadCounterError extends CounterError {
  const _LoadCounterError({this.originalError, this.message}): super._();
  

 final  Object? originalError;
 final  String? message;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadCounterErrorCopyWith<_LoadCounterError> get copyWith => __$LoadCounterErrorCopyWithImpl<_LoadCounterError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadCounterError&&const DeepCollectionEquality().equals(other.originalError, originalError)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(originalError),message);

@override
String toString() {
  return 'CounterError.load(originalError: $originalError, message: $message)';
}


}

/// @nodoc
abstract mixin class _$LoadCounterErrorCopyWith<$Res> implements $CounterErrorCopyWith<$Res> {
  factory _$LoadCounterErrorCopyWith(_LoadCounterError value, $Res Function(_LoadCounterError) _then) = __$LoadCounterErrorCopyWithImpl;
@useResult
$Res call({
 Object? originalError, String? message
});




}
/// @nodoc
class __$LoadCounterErrorCopyWithImpl<$Res>
    implements _$LoadCounterErrorCopyWith<$Res> {
  __$LoadCounterErrorCopyWithImpl(this._self, this._then);

  final _LoadCounterError _self;
  final $Res Function(_LoadCounterError) _then;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? originalError = freezed,Object? message = freezed,}) {
  return _then(_LoadCounterError(
originalError: freezed == originalError ? _self.originalError : originalError ,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _SaveCounterError extends CounterError {
  const _SaveCounterError({this.originalError, this.message}): super._();
  

 final  Object? originalError;
 final  String? message;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveCounterErrorCopyWith<_SaveCounterError> get copyWith => __$SaveCounterErrorCopyWithImpl<_SaveCounterError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveCounterError&&const DeepCollectionEquality().equals(other.originalError, originalError)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(originalError),message);

@override
String toString() {
  return 'CounterError.save(originalError: $originalError, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SaveCounterErrorCopyWith<$Res> implements $CounterErrorCopyWith<$Res> {
  factory _$SaveCounterErrorCopyWith(_SaveCounterError value, $Res Function(_SaveCounterError) _then) = __$SaveCounterErrorCopyWithImpl;
@useResult
$Res call({
 Object? originalError, String? message
});




}
/// @nodoc
class __$SaveCounterErrorCopyWithImpl<$Res>
    implements _$SaveCounterErrorCopyWith<$Res> {
  __$SaveCounterErrorCopyWithImpl(this._self, this._then);

  final _SaveCounterError _self;
  final $Res Function(_SaveCounterError) _then;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? originalError = freezed,Object? message = freezed,}) {
  return _then(_SaveCounterError(
originalError: freezed == originalError ? _self.originalError : originalError ,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _UnknownCounterError extends CounterError {
  const _UnknownCounterError({this.originalError, this.message}): super._();
  

 final  Object? originalError;
 final  String? message;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnknownCounterErrorCopyWith<_UnknownCounterError> get copyWith => __$UnknownCounterErrorCopyWithImpl<_UnknownCounterError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnknownCounterError&&const DeepCollectionEquality().equals(other.originalError, originalError)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(originalError),message);

@override
String toString() {
  return 'CounterError.unknown(originalError: $originalError, message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnknownCounterErrorCopyWith<$Res> implements $CounterErrorCopyWith<$Res> {
  factory _$UnknownCounterErrorCopyWith(_UnknownCounterError value, $Res Function(_UnknownCounterError) _then) = __$UnknownCounterErrorCopyWithImpl;
@useResult
$Res call({
 Object? originalError, String? message
});




}
/// @nodoc
class __$UnknownCounterErrorCopyWithImpl<$Res>
    implements _$UnknownCounterErrorCopyWith<$Res> {
  __$UnknownCounterErrorCopyWithImpl(this._self, this._then);

  final _UnknownCounterError _self;
  final $Res Function(_UnknownCounterError) _then;

/// Create a copy of CounterError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? originalError = freezed,Object? message = freezed,}) {
  return _then(_UnknownCounterError(
originalError: freezed == originalError ? _self.originalError : originalError ,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
