// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState()';
}


}

/// @nodoc
class $ProfileStateCopyWith<$Res>  {
$ProfileStateCopyWith(ProfileState _, $Res Function(ProfileState) __);
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileInitial value)?  initial,TResult Function( ProfileLoading value)?  loading,TResult Function( ProfileReady value)?  ready,TResult Function( ProfileError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial(_that);case ProfileLoading() when loading != null:
return loading(_that);case ProfileReady() when ready != null:
return ready(_that);case ProfileError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileInitial value)  initial,required TResult Function( ProfileLoading value)  loading,required TResult Function( ProfileReady value)  ready,required TResult Function( ProfileError value)  error,}){
final _that = this;
switch (_that) {
case ProfileInitial():
return initial(_that);case ProfileLoading():
return loading(_that);case ProfileReady():
return ready(_that);case ProfileError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileInitial value)?  initial,TResult? Function( ProfileLoading value)?  loading,TResult? Function( ProfileReady value)?  ready,TResult? Function( ProfileError value)?  error,}){
final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial(_that);case ProfileLoading() when loading != null:
return loading(_that);case ProfileReady() when ready != null:
return ready(_that);case ProfileError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ProfileUser user)?  ready,TResult Function( ProfileFailure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial();case ProfileLoading() when loading != null:
return loading();case ProfileReady() when ready != null:
return ready(_that.user);case ProfileError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ProfileUser user)  ready,required TResult Function( ProfileFailure failure)  error,}) {final _that = this;
switch (_that) {
case ProfileInitial():
return initial();case ProfileLoading():
return loading();case ProfileReady():
return ready(_that.user);case ProfileError():
return error(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ProfileUser user)?  ready,TResult? Function( ProfileFailure failure)?  error,}) {final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial();case ProfileLoading() when loading != null:
return loading();case ProfileReady() when ready != null:
return ready(_that.user);case ProfileError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ProfileInitial extends ProfileState {
  const ProfileInitial(): super._();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState.initial()';
}


}




/// @nodoc


class ProfileLoading extends ProfileState {
  const ProfileLoading(): super._();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState.loading()';
}


}




/// @nodoc


class ProfileReady extends ProfileState {
  const ProfileReady(this.user): super._();


 final  ProfileUser user;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileReadyCopyWith<ProfileReady> get copyWith => _$ProfileReadyCopyWithImpl<ProfileReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileReady&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'ProfileState.ready(user: $user)';
}


}

/// @nodoc
abstract mixin class $ProfileReadyCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileReadyCopyWith(ProfileReady value, $Res Function(ProfileReady) _then) = _$ProfileReadyCopyWithImpl;
@useResult
$Res call({
 ProfileUser user
});


$ProfileUserCopyWith<$Res> get user;

}
/// @nodoc
class _$ProfileReadyCopyWithImpl<$Res>
    implements $ProfileReadyCopyWith<$Res> {
  _$ProfileReadyCopyWithImpl(this._self, this._then);

  final ProfileReady _self;
  final $Res Function(ProfileReady) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(ProfileReady(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileUser,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileUserCopyWith<$Res> get user {

  return $ProfileUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc


class ProfileError extends ProfileState {
  const ProfileError(this.failure): super._();


 final  ProfileFailure failure;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileErrorCopyWith<ProfileError> get copyWith => _$ProfileErrorCopyWithImpl<ProfileError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'ProfileState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ProfileErrorCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileErrorCopyWith(ProfileError value, $Res Function(ProfileError) _then) = _$ProfileErrorCopyWithImpl;
@useResult
$Res call({
 ProfileFailure failure
});


$ProfileFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$ProfileErrorCopyWithImpl<$Res>
    implements $ProfileErrorCopyWith<$Res> {
  _$ProfileErrorCopyWithImpl(this._self, this._then);

  final ProfileError _self;
  final $Res Function(ProfileError) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ProfileError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as ProfileFailure,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileFailureCopyWith<$Res> get failure {

  return $ProfileFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
