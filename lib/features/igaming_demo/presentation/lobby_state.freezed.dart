// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LobbyState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LobbyState()';
}


}

/// @nodoc
class $LobbyStateCopyWith<$Res>  {
$LobbyStateCopyWith(LobbyState _, $Res Function(LobbyState) __);
}


/// Adds pattern-matching-related methods to [LobbyState].
extension LobbyStatePatterns on LobbyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LobbyInitial value)?  initial,TResult Function( _LobbyLoading value)?  loading,TResult Function( _LobbyReady value)?  ready,TResult Function( _LobbyError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyInitial() when initial != null:
return initial(_that);case _LobbyLoading() when loading != null:
return loading(_that);case _LobbyReady() when ready != null:
return ready(_that);case _LobbyError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LobbyInitial value)  initial,required TResult Function( _LobbyLoading value)  loading,required TResult Function( _LobbyReady value)  ready,required TResult Function( _LobbyError value)  error,}){
final _that = this;
switch (_that) {
case _LobbyInitial():
return initial(_that);case _LobbyLoading():
return loading(_that);case _LobbyReady():
return ready(_that);case _LobbyError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LobbyInitial value)?  initial,TResult? Function( _LobbyLoading value)?  loading,TResult? Function( _LobbyReady value)?  ready,TResult? Function( _LobbyError value)?  error,}){
final _that = this;
switch (_that) {
case _LobbyInitial() when initial != null:
return initial(_that);case _LobbyLoading() when loading != null:
return loading(_that);case _LobbyReady() when ready != null:
return ready(_that);case _LobbyError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( DemoBalance balance)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyInitial() when initial != null:
return initial();case _LobbyLoading() when loading != null:
return loading();case _LobbyReady() when ready != null:
return ready(_that.balance);case _LobbyError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( DemoBalance balance)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _LobbyInitial():
return initial();case _LobbyLoading():
return loading();case _LobbyReady():
return ready(_that.balance);case _LobbyError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( DemoBalance balance)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _LobbyInitial() when initial != null:
return initial();case _LobbyLoading() when loading != null:
return loading();case _LobbyReady() when ready != null:
return ready(_that.balance);case _LobbyError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _LobbyInitial implements LobbyState {
  const _LobbyInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LobbyState.initial()';
}


}




/// @nodoc


class _LobbyLoading implements LobbyState {
  const _LobbyLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LobbyState.loading()';
}


}




/// @nodoc


class _LobbyReady implements LobbyState {
  const _LobbyReady(this.balance);
  

 final  DemoBalance balance;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyReadyCopyWith<_LobbyReady> get copyWith => __$LobbyReadyCopyWithImpl<_LobbyReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyReady&&(identical(other.balance, balance) || other.balance == balance));
}


@override
int get hashCode => Object.hash(runtimeType,balance);

@override
String toString() {
  return 'LobbyState.ready(balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$LobbyReadyCopyWith<$Res> implements $LobbyStateCopyWith<$Res> {
  factory _$LobbyReadyCopyWith(_LobbyReady value, $Res Function(_LobbyReady) _then) = __$LobbyReadyCopyWithImpl;
@useResult
$Res call({
 DemoBalance balance
});


$DemoBalanceCopyWith<$Res> get balance;

}
/// @nodoc
class __$LobbyReadyCopyWithImpl<$Res>
    implements _$LobbyReadyCopyWith<$Res> {
  __$LobbyReadyCopyWithImpl(this._self, this._then);

  final _LobbyReady _self;
  final $Res Function(_LobbyReady) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? balance = null,}) {
  return _then(_LobbyReady(
null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as DemoBalance,
  ));
}

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DemoBalanceCopyWith<$Res> get balance {
  
  return $DemoBalanceCopyWith<$Res>(_self.balance, (value) {
    return _then(_self.copyWith(balance: value));
  });
}
}

/// @nodoc


class _LobbyError implements LobbyState {
  const _LobbyError(this.message);
  

 final  String message;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyErrorCopyWith<_LobbyError> get copyWith => __$LobbyErrorCopyWithImpl<_LobbyError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LobbyState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$LobbyErrorCopyWith<$Res> implements $LobbyStateCopyWith<$Res> {
  factory _$LobbyErrorCopyWith(_LobbyError value, $Res Function(_LobbyError) _then) = __$LobbyErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$LobbyErrorCopyWithImpl<$Res>
    implements _$LobbyErrorCopyWith<$Res> {
  __$LobbyErrorCopyWithImpl(this._self, this._then);

  final _LobbyError _self;
  final $Res Function(_LobbyError) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_LobbyError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
