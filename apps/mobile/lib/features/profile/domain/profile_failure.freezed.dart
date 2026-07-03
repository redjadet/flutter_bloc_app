// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFailure {

 String? get message; Object? get cause;
/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFailureCopyWith<ProfileFailure> get copyWith => _$ProfileFailureCopyWithImpl<ProfileFailure>(this as ProfileFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'ProfileFailure(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ProfileFailureCopyWith<$Res>  {
  factory $ProfileFailureCopyWith(ProfileFailure value, $Res Function(ProfileFailure) _then) = _$ProfileFailureCopyWithImpl;
@useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$ProfileFailureCopyWithImpl<$Res>
    implements $ProfileFailureCopyWith<$Res> {
  _$ProfileFailureCopyWithImpl(this._self, this._then);

  final ProfileFailure _self;
  final $Res Function(ProfileFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileFailure].
extension ProfileFailurePatterns on ProfileFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileLoadFailure value)?  load,TResult Function( ProfileUnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileLoadFailure() when load != null:
return load(_that);case ProfileUnknownFailure() when unknown != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileLoadFailure value)  load,required TResult Function( ProfileUnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case ProfileLoadFailure():
return load(_that);case ProfileUnknownFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileLoadFailure value)?  load,TResult? Function( ProfileUnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case ProfileLoadFailure() when load != null:
return load(_that);case ProfileUnknownFailure() when unknown != null:
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
case ProfileLoadFailure() when load != null:
return load(_that.message,_that.cause);case ProfileUnknownFailure() when unknown != null:
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
case ProfileLoadFailure():
return load(_that.message,_that.cause);case ProfileUnknownFailure():
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
case ProfileLoadFailure() when load != null:
return load(_that.message,_that.cause);case ProfileUnknownFailure() when unknown != null:
return unknown(_that.message,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class ProfileLoadFailure extends ProfileFailure {
  const ProfileLoadFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLoadFailureCopyWith<ProfileLoadFailure> get copyWith => _$ProfileLoadFailureCopyWithImpl<ProfileLoadFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoadFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'ProfileFailure.load(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ProfileLoadFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $ProfileLoadFailureCopyWith(ProfileLoadFailure value, $Res Function(ProfileLoadFailure) _then) = _$ProfileLoadFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$ProfileLoadFailureCopyWithImpl<$Res>
    implements $ProfileLoadFailureCopyWith<$Res> {
  _$ProfileLoadFailureCopyWithImpl(this._self, this._then);

  final ProfileLoadFailure _self;
  final $Res Function(ProfileLoadFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(ProfileLoadFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

/// @nodoc


class ProfileUnknownFailure extends ProfileFailure {
  const ProfileUnknownFailure({this.message, this.cause}): super._();
  

@override final  String? message;
@override final  Object? cause;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileUnknownFailureCopyWith<ProfileUnknownFailure> get copyWith => _$ProfileUnknownFailureCopyWithImpl<ProfileUnknownFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileUnknownFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'ProfileFailure.unknown(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ProfileUnknownFailureCopyWith<$Res> implements $ProfileFailureCopyWith<$Res> {
  factory $ProfileUnknownFailureCopyWith(ProfileUnknownFailure value, $Res Function(ProfileUnknownFailure) _then) = _$ProfileUnknownFailureCopyWithImpl;
@override @useResult
$Res call({
 String? message, Object? cause
});




}
/// @nodoc
class _$ProfileUnknownFailureCopyWithImpl<$Res>
    implements $ProfileUnknownFailureCopyWith<$Res> {
  _$ProfileUnknownFailureCopyWithImpl(this._self, this._then);

  final ProfileUnknownFailure _self;
  final $Res Function(ProfileUnknownFailure) _then;

/// Create a copy of ProfileFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? cause = freezed,}) {
  return _then(ProfileUnknownFailure(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on
