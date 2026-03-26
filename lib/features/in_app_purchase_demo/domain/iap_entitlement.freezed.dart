// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iap_entitlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IapEntitlements {

 int get credits; bool get isPremiumOwned; bool get isSubscriptionActive; DateTime? get subscriptionExpiry;
/// Create a copy of IapEntitlements
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IapEntitlementsCopyWith<IapEntitlements> get copyWith => _$IapEntitlementsCopyWithImpl<IapEntitlements>(this as IapEntitlements, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IapEntitlements&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.isPremiumOwned, isPremiumOwned) || other.isPremiumOwned == isPremiumOwned)&&(identical(other.isSubscriptionActive, isSubscriptionActive) || other.isSubscriptionActive == isSubscriptionActive)&&(identical(other.subscriptionExpiry, subscriptionExpiry) || other.subscriptionExpiry == subscriptionExpiry));
}


@override
int get hashCode => Object.hash(runtimeType,credits,isPremiumOwned,isSubscriptionActive,subscriptionExpiry);

@override
String toString() {
  return 'IapEntitlements(credits: $credits, isPremiumOwned: $isPremiumOwned, isSubscriptionActive: $isSubscriptionActive, subscriptionExpiry: $subscriptionExpiry)';
}


}

/// @nodoc
abstract mixin class $IapEntitlementsCopyWith<$Res>  {
  factory $IapEntitlementsCopyWith(IapEntitlements value, $Res Function(IapEntitlements) _then) = _$IapEntitlementsCopyWithImpl;
@useResult
$Res call({
 int credits, bool isPremiumOwned, bool isSubscriptionActive, DateTime? subscriptionExpiry
});




}
/// @nodoc
class _$IapEntitlementsCopyWithImpl<$Res>
    implements $IapEntitlementsCopyWith<$Res> {
  _$IapEntitlementsCopyWithImpl(this._self, this._then);

  final IapEntitlements _self;
  final $Res Function(IapEntitlements) _then;

/// Create a copy of IapEntitlements
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? credits = null,Object? isPremiumOwned = null,Object? isSubscriptionActive = null,Object? subscriptionExpiry = freezed,}) {
  return _then(_self.copyWith(
credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,isPremiumOwned: null == isPremiumOwned ? _self.isPremiumOwned : isPremiumOwned // ignore: cast_nullable_to_non_nullable
as bool,isSubscriptionActive: null == isSubscriptionActive ? _self.isSubscriptionActive : isSubscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionExpiry: freezed == subscriptionExpiry ? _self.subscriptionExpiry : subscriptionExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [IapEntitlements].
extension IapEntitlementsPatterns on IapEntitlements {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IapEntitlements value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IapEntitlements() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IapEntitlements value)  $default,){
final _that = this;
switch (_that) {
case _IapEntitlements():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IapEntitlements value)?  $default,){
final _that = this;
switch (_that) {
case _IapEntitlements() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int credits,  bool isPremiumOwned,  bool isSubscriptionActive,  DateTime? subscriptionExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IapEntitlements() when $default != null:
return $default(_that.credits,_that.isPremiumOwned,_that.isSubscriptionActive,_that.subscriptionExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int credits,  bool isPremiumOwned,  bool isSubscriptionActive,  DateTime? subscriptionExpiry)  $default,) {final _that = this;
switch (_that) {
case _IapEntitlements():
return $default(_that.credits,_that.isPremiumOwned,_that.isSubscriptionActive,_that.subscriptionExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int credits,  bool isPremiumOwned,  bool isSubscriptionActive,  DateTime? subscriptionExpiry)?  $default,) {final _that = this;
switch (_that) {
case _IapEntitlements() when $default != null:
return $default(_that.credits,_that.isPremiumOwned,_that.isSubscriptionActive,_that.subscriptionExpiry);case _:
  return null;

}
}

}

/// @nodoc


class _IapEntitlements implements IapEntitlements {
  const _IapEntitlements({this.credits = 0, this.isPremiumOwned = false, this.isSubscriptionActive = false, this.subscriptionExpiry});
  

@override@JsonKey() final  int credits;
@override@JsonKey() final  bool isPremiumOwned;
@override@JsonKey() final  bool isSubscriptionActive;
@override final  DateTime? subscriptionExpiry;

/// Create a copy of IapEntitlements
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapEntitlementsCopyWith<_IapEntitlements> get copyWith => __$IapEntitlementsCopyWithImpl<_IapEntitlements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapEntitlements&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.isPremiumOwned, isPremiumOwned) || other.isPremiumOwned == isPremiumOwned)&&(identical(other.isSubscriptionActive, isSubscriptionActive) || other.isSubscriptionActive == isSubscriptionActive)&&(identical(other.subscriptionExpiry, subscriptionExpiry) || other.subscriptionExpiry == subscriptionExpiry));
}


@override
int get hashCode => Object.hash(runtimeType,credits,isPremiumOwned,isSubscriptionActive,subscriptionExpiry);

@override
String toString() {
  return 'IapEntitlements(credits: $credits, isPremiumOwned: $isPremiumOwned, isSubscriptionActive: $isSubscriptionActive, subscriptionExpiry: $subscriptionExpiry)';
}


}

/// @nodoc
abstract mixin class _$IapEntitlementsCopyWith<$Res> implements $IapEntitlementsCopyWith<$Res> {
  factory _$IapEntitlementsCopyWith(_IapEntitlements value, $Res Function(_IapEntitlements) _then) = __$IapEntitlementsCopyWithImpl;
@override @useResult
$Res call({
 int credits, bool isPremiumOwned, bool isSubscriptionActive, DateTime? subscriptionExpiry
});




}
/// @nodoc
class __$IapEntitlementsCopyWithImpl<$Res>
    implements _$IapEntitlementsCopyWith<$Res> {
  __$IapEntitlementsCopyWithImpl(this._self, this._then);

  final _IapEntitlements _self;
  final $Res Function(_IapEntitlements) _then;

/// Create a copy of IapEntitlements
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? credits = null,Object? isPremiumOwned = null,Object? isSubscriptionActive = null,Object? subscriptionExpiry = freezed,}) {
  return _then(_IapEntitlements(
credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,isPremiumOwned: null == isPremiumOwned ? _self.isPremiumOwned : isPremiumOwned // ignore: cast_nullable_to_non_nullable
as bool,isSubscriptionActive: null == isSubscriptionActive ? _self.isSubscriptionActive : isSubscriptionActive // ignore: cast_nullable_to_non_nullable
as bool,subscriptionExpiry: freezed == subscriptionExpiry ? _self.subscriptionExpiry : subscriptionExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
