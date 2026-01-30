// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'walletconnect_auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletConnectAuthState {

 ViewStatus get status; WalletAddress? get walletAddress; WalletAddress? get linkedWalletAddress; String? get errorMessage;
/// Create a copy of WalletConnectAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletConnectAuthStateCopyWith<WalletConnectAuthState> get copyWith => _$WalletConnectAuthStateCopyWithImpl<WalletConnectAuthState>(this as WalletConnectAuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletConnectAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.linkedWalletAddress, linkedWalletAddress) || other.linkedWalletAddress == linkedWalletAddress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,walletAddress,linkedWalletAddress,errorMessage);

@override
String toString() {
  return 'WalletConnectAuthState(status: $status, walletAddress: $walletAddress, linkedWalletAddress: $linkedWalletAddress, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WalletConnectAuthStateCopyWith<$Res>  {
  factory $WalletConnectAuthStateCopyWith(WalletConnectAuthState value, $Res Function(WalletConnectAuthState) _then) = _$WalletConnectAuthStateCopyWithImpl;
@useResult
$Res call({
 ViewStatus status, WalletAddress? walletAddress, WalletAddress? linkedWalletAddress, String? errorMessage
});




}
/// @nodoc
class _$WalletConnectAuthStateCopyWithImpl<$Res>
    implements $WalletConnectAuthStateCopyWith<$Res> {
  _$WalletConnectAuthStateCopyWithImpl(this._self, this._then);

  final WalletConnectAuthState _self;
  final $Res Function(WalletConnectAuthState) _then;

/// Create a copy of WalletConnectAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? walletAddress = freezed,Object? linkedWalletAddress = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,walletAddress: freezed == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as WalletAddress?,linkedWalletAddress: freezed == linkedWalletAddress ? _self.linkedWalletAddress : linkedWalletAddress // ignore: cast_nullable_to_non_nullable
as WalletAddress?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletConnectAuthState].
extension WalletConnectAuthStatePatterns on WalletConnectAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletConnectAuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletConnectAuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletConnectAuthState value)  $default,){
final _that = this;
switch (_that) {
case _WalletConnectAuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletConnectAuthState value)?  $default,){
final _that = this;
switch (_that) {
case _WalletConnectAuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ViewStatus status,  WalletAddress? walletAddress,  WalletAddress? linkedWalletAddress,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletConnectAuthState() when $default != null:
return $default(_that.status,_that.walletAddress,_that.linkedWalletAddress,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ViewStatus status,  WalletAddress? walletAddress,  WalletAddress? linkedWalletAddress,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WalletConnectAuthState():
return $default(_that.status,_that.walletAddress,_that.linkedWalletAddress,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ViewStatus status,  WalletAddress? walletAddress,  WalletAddress? linkedWalletAddress,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WalletConnectAuthState() when $default != null:
return $default(_that.status,_that.walletAddress,_that.linkedWalletAddress,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WalletConnectAuthState extends WalletConnectAuthState {
  const _WalletConnectAuthState({this.status = ViewStatus.initial, this.walletAddress, this.linkedWalletAddress, this.errorMessage}): super._();
  

@override@JsonKey() final  ViewStatus status;
@override final  WalletAddress? walletAddress;
@override final  WalletAddress? linkedWalletAddress;
@override final  String? errorMessage;

/// Create a copy of WalletConnectAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletConnectAuthStateCopyWith<_WalletConnectAuthState> get copyWith => __$WalletConnectAuthStateCopyWithImpl<_WalletConnectAuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletConnectAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.linkedWalletAddress, linkedWalletAddress) || other.linkedWalletAddress == linkedWalletAddress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,walletAddress,linkedWalletAddress,errorMessage);

@override
String toString() {
  return 'WalletConnectAuthState(status: $status, walletAddress: $walletAddress, linkedWalletAddress: $linkedWalletAddress, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WalletConnectAuthStateCopyWith<$Res> implements $WalletConnectAuthStateCopyWith<$Res> {
  factory _$WalletConnectAuthStateCopyWith(_WalletConnectAuthState value, $Res Function(_WalletConnectAuthState) _then) = __$WalletConnectAuthStateCopyWithImpl;
@override @useResult
$Res call({
 ViewStatus status, WalletAddress? walletAddress, WalletAddress? linkedWalletAddress, String? errorMessage
});




}
/// @nodoc
class __$WalletConnectAuthStateCopyWithImpl<$Res>
    implements _$WalletConnectAuthStateCopyWith<$Res> {
  __$WalletConnectAuthStateCopyWithImpl(this._self, this._then);

  final _WalletConnectAuthState _self;
  final $Res Function(_WalletConnectAuthState) _then;

/// Create a copy of WalletConnectAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? walletAddress = freezed,Object? linkedWalletAddress = freezed,Object? errorMessage = freezed,}) {
  return _then(_WalletConnectAuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ViewStatus,walletAddress: freezed == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as WalletAddress?,linkedWalletAddress: freezed == linkedWalletAddress ? _self.linkedWalletAddress : linkedWalletAddress // ignore: cast_nullable_to_non_nullable
as WalletAddress?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
