// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletUserProfile {

 double get balanceOffChain; double get balanceOnChain; double get rewards; DateTime? get lastClaim; List<NftMetadata> get nfts;
/// Create a copy of WalletUserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletUserProfileCopyWith<WalletUserProfile> get copyWith => _$WalletUserProfileCopyWithImpl<WalletUserProfile>(this as WalletUserProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletUserProfile&&(identical(other.balanceOffChain, balanceOffChain) || other.balanceOffChain == balanceOffChain)&&(identical(other.balanceOnChain, balanceOnChain) || other.balanceOnChain == balanceOnChain)&&(identical(other.rewards, rewards) || other.rewards == rewards)&&(identical(other.lastClaim, lastClaim) || other.lastClaim == lastClaim)&&const DeepCollectionEquality().equals(other.nfts, nfts));
}


@override
int get hashCode => Object.hash(runtimeType,balanceOffChain,balanceOnChain,rewards,lastClaim,const DeepCollectionEquality().hash(nfts));

@override
String toString() {
  return 'WalletUserProfile(balanceOffChain: $balanceOffChain, balanceOnChain: $balanceOnChain, rewards: $rewards, lastClaim: $lastClaim, nfts: $nfts)';
}


}

/// @nodoc
abstract mixin class $WalletUserProfileCopyWith<$Res>  {
  factory $WalletUserProfileCopyWith(WalletUserProfile value, $Res Function(WalletUserProfile) _then) = _$WalletUserProfileCopyWithImpl;
@useResult
$Res call({
 double balanceOffChain, double balanceOnChain, double rewards, DateTime? lastClaim, List<NftMetadata> nfts
});




}
/// @nodoc
class _$WalletUserProfileCopyWithImpl<$Res>
    implements $WalletUserProfileCopyWith<$Res> {
  _$WalletUserProfileCopyWithImpl(this._self, this._then);

  final WalletUserProfile _self;
  final $Res Function(WalletUserProfile) _then;

/// Create a copy of WalletUserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? balanceOffChain = null,Object? balanceOnChain = null,Object? rewards = null,Object? lastClaim = freezed,Object? nfts = null,}) {
  return _then(_self.copyWith(
balanceOffChain: null == balanceOffChain ? _self.balanceOffChain : balanceOffChain // ignore: cast_nullable_to_non_nullable
as double,balanceOnChain: null == balanceOnChain ? _self.balanceOnChain : balanceOnChain // ignore: cast_nullable_to_non_nullable
as double,rewards: null == rewards ? _self.rewards : rewards // ignore: cast_nullable_to_non_nullable
as double,lastClaim: freezed == lastClaim ? _self.lastClaim : lastClaim // ignore: cast_nullable_to_non_nullable
as DateTime?,nfts: null == nfts ? _self.nfts : nfts // ignore: cast_nullable_to_non_nullable
as List<NftMetadata>,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletUserProfile].
extension WalletUserProfilePatterns on WalletUserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletUserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletUserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletUserProfile value)  $default,){
final _that = this;
switch (_that) {
case _WalletUserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletUserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _WalletUserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double balanceOffChain,  double balanceOnChain,  double rewards,  DateTime? lastClaim,  List<NftMetadata> nfts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletUserProfile() when $default != null:
return $default(_that.balanceOffChain,_that.balanceOnChain,_that.rewards,_that.lastClaim,_that.nfts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double balanceOffChain,  double balanceOnChain,  double rewards,  DateTime? lastClaim,  List<NftMetadata> nfts)  $default,) {final _that = this;
switch (_that) {
case _WalletUserProfile():
return $default(_that.balanceOffChain,_that.balanceOnChain,_that.rewards,_that.lastClaim,_that.nfts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double balanceOffChain,  double balanceOnChain,  double rewards,  DateTime? lastClaim,  List<NftMetadata> nfts)?  $default,) {final _that = this;
switch (_that) {
case _WalletUserProfile() when $default != null:
return $default(_that.balanceOffChain,_that.balanceOnChain,_that.rewards,_that.lastClaim,_that.nfts);case _:
  return null;

}
}

}

/// @nodoc


class _WalletUserProfile implements WalletUserProfile {
  const _WalletUserProfile({this.balanceOffChain = 0.0, this.balanceOnChain = 0.0, this.rewards = 0.0, this.lastClaim, final  List<NftMetadata> nfts = const <NftMetadata>[]}): _nfts = nfts;
  

@override@JsonKey() final  double balanceOffChain;
@override@JsonKey() final  double balanceOnChain;
@override@JsonKey() final  double rewards;
@override final  DateTime? lastClaim;
 final  List<NftMetadata> _nfts;
@override@JsonKey() List<NftMetadata> get nfts {
  if (_nfts is EqualUnmodifiableListView) return _nfts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nfts);
}


/// Create a copy of WalletUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletUserProfileCopyWith<_WalletUserProfile> get copyWith => __$WalletUserProfileCopyWithImpl<_WalletUserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletUserProfile&&(identical(other.balanceOffChain, balanceOffChain) || other.balanceOffChain == balanceOffChain)&&(identical(other.balanceOnChain, balanceOnChain) || other.balanceOnChain == balanceOnChain)&&(identical(other.rewards, rewards) || other.rewards == rewards)&&(identical(other.lastClaim, lastClaim) || other.lastClaim == lastClaim)&&const DeepCollectionEquality().equals(other._nfts, _nfts));
}


@override
int get hashCode => Object.hash(runtimeType,balanceOffChain,balanceOnChain,rewards,lastClaim,const DeepCollectionEquality().hash(_nfts));

@override
String toString() {
  return 'WalletUserProfile(balanceOffChain: $balanceOffChain, balanceOnChain: $balanceOnChain, rewards: $rewards, lastClaim: $lastClaim, nfts: $nfts)';
}


}

/// @nodoc
abstract mixin class _$WalletUserProfileCopyWith<$Res> implements $WalletUserProfileCopyWith<$Res> {
  factory _$WalletUserProfileCopyWith(_WalletUserProfile value, $Res Function(_WalletUserProfile) _then) = __$WalletUserProfileCopyWithImpl;
@override @useResult
$Res call({
 double balanceOffChain, double balanceOnChain, double rewards, DateTime? lastClaim, List<NftMetadata> nfts
});




}
/// @nodoc
class __$WalletUserProfileCopyWithImpl<$Res>
    implements _$WalletUserProfileCopyWith<$Res> {
  __$WalletUserProfileCopyWithImpl(this._self, this._then);

  final _WalletUserProfile _self;
  final $Res Function(_WalletUserProfile) _then;

/// Create a copy of WalletUserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? balanceOffChain = null,Object? balanceOnChain = null,Object? rewards = null,Object? lastClaim = freezed,Object? nfts = null,}) {
  return _then(_WalletUserProfile(
balanceOffChain: null == balanceOffChain ? _self.balanceOffChain : balanceOffChain // ignore: cast_nullable_to_non_nullable
as double,balanceOnChain: null == balanceOnChain ? _self.balanceOnChain : balanceOnChain // ignore: cast_nullable_to_non_nullable
as double,rewards: null == rewards ? _self.rewards : rewards // ignore: cast_nullable_to_non_nullable
as double,lastClaim: freezed == lastClaim ? _self.lastClaim : lastClaim // ignore: cast_nullable_to_non_nullable
as DateTime?,nfts: null == nfts ? _self._nfts : nfts // ignore: cast_nullable_to_non_nullable
as List<NftMetadata>,
  ));
}


}

// dart format on
