// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_decision_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiDecisionFailure {

 String? get message; Object? get cause;
/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDecisionFailureCopyWith<AiDecisionFailure> get copyWith => _$AiDecisionFailureCopyWithImpl<AiDecisionFailure>(this as AiDecisionFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDecisionFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AiDecisionFailure(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AiDecisionFailureCopyWith<$Res>  {
  factory $AiDecisionFailureCopyWith(AiDecisionFailure value, $Res Function(AiDecisionFailure) _then) = _$AiDecisionFailureCopyWithImpl;
@useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$AiDecisionFailureCopyWithImpl<$Res>
    implements $AiDecisionFailureCopyWith<$Res> {
  _$AiDecisionFailureCopyWithImpl(this._self, this._then);

  final AiDecisionFailure _self;
  final $Res Function(AiDecisionFailure) _then;

/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}

}


/// Adds pattern-matching-related methods to [AiDecisionFailure].
extension AiDecisionFailurePatterns on AiDecisionFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AiDecisionLoadFailure value)?  load,TResult Function( AiDecisionUnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AiDecisionLoadFailure() when load != null:
return load(_that);case AiDecisionUnknownFailure() when unknown != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AiDecisionLoadFailure value)  load,required TResult Function( AiDecisionUnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case AiDecisionLoadFailure():
return load(_that);case AiDecisionUnknownFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AiDecisionLoadFailure value)?  load,TResult? Function( AiDecisionUnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case AiDecisionLoadFailure() when load != null:
return load(_that);case AiDecisionUnknownFailure() when unknown != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message,  Object? cause)?  load,TResult Function( String? message,  Object? cause)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AiDecisionLoadFailure() when load != null:
return load(_that.message,_that.cause);case AiDecisionUnknownFailure() when unknown != null:
return unknown(_that.message,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message,  Object? cause)  load,required TResult Function( String? message,  Object? cause)  unknown,}) {final _that = this;
switch (_that) {
case AiDecisionLoadFailure():
return load(_that.message,_that.cause);case AiDecisionUnknownFailure():
return unknown(_that.message,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message,  Object? cause)?  load,TResult? Function( String? message,  Object? cause)?  unknown,}) {final _that = this;
switch (_that) {
case AiDecisionLoadFailure() when load != null:
return load(_that.message,_that.cause);case AiDecisionUnknownFailure() when unknown != null:
return unknown(_that.message,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class AiDecisionLoadFailure extends AiDecisionFailure {
  const AiDecisionLoadFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDecisionLoadFailureCopyWith<AiDecisionLoadFailure> get copyWith => _$AiDecisionLoadFailureCopyWithImpl<AiDecisionLoadFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDecisionLoadFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AiDecisionFailure.load(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AiDecisionLoadFailureCopyWith<$Res> implements $AiDecisionFailureCopyWith<$Res> {
  factory $AiDecisionLoadFailureCopyWith(AiDecisionLoadFailure value, $Res Function(AiDecisionLoadFailure) _then) = _$AiDecisionLoadFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$AiDecisionLoadFailureCopyWithImpl<$Res>
    implements $AiDecisionLoadFailureCopyWith<$Res> {
  _$AiDecisionLoadFailureCopyWithImpl(this._self, this._then);

  final AiDecisionLoadFailure _self;
  final $Res Function(AiDecisionLoadFailure) _then;

/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(AiDecisionLoadFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

/// @nodoc


class AiDecisionUnknownFailure extends AiDecisionFailure {
  const AiDecisionUnknownFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDecisionUnknownFailureCopyWith<AiDecisionUnknownFailure> get copyWith => _$AiDecisionUnknownFailureCopyWithImpl<AiDecisionUnknownFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDecisionUnknownFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AiDecisionFailure.unknown(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AiDecisionUnknownFailureCopyWith<$Res> implements $AiDecisionFailureCopyWith<$Res> {
  factory $AiDecisionUnknownFailureCopyWith(AiDecisionUnknownFailure value, $Res Function(AiDecisionUnknownFailure) _then) = _$AiDecisionUnknownFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$AiDecisionUnknownFailureCopyWithImpl<$Res>
    implements $AiDecisionUnknownFailureCopyWith<$Res> {
  _$AiDecisionUnknownFailureCopyWithImpl(this._self, this._then);

  final AiDecisionUnknownFailure _self;
  final $Res Function(AiDecisionUnknownFailure) _then;

/// Create a copy of AiDecisionFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(AiDecisionUnknownFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on
