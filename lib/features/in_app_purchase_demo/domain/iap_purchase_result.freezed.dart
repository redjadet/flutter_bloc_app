// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iap_purchase_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IapPurchaseResult {

 String get productId; String? get message;
/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IapPurchaseResultCopyWith<IapPurchaseResult> get copyWith => _$IapPurchaseResultCopyWithImpl<IapPurchaseResult>(this as IapPurchaseResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IapPurchaseResult&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,productId,message);

@override
String toString() {
  return 'IapPurchaseResult(productId: $productId, message: $message)';
}


}

/// @nodoc
abstract mixin class $IapPurchaseResultCopyWith<$Res>  {
  factory $IapPurchaseResultCopyWith(IapPurchaseResult value, $Res Function(IapPurchaseResult) _then) = _$IapPurchaseResultCopyWithImpl;
@useResult
$Res call({
 String productId, String message
});




}
/// @nodoc
class _$IapPurchaseResultCopyWithImpl<$Res>
    implements $IapPurchaseResultCopyWith<$Res> {
  _$IapPurchaseResultCopyWithImpl(this._self, this._then);

  final IapPurchaseResult _self;
  final $Res Function(IapPurchaseResult) _then;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? message = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message! : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IapPurchaseResult].
extension IapPurchaseResultPatterns on IapPurchaseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _IapPurchaseSuccess value)?  success,TResult Function( _IapPurchaseCancelled value)?  cancelled,TResult Function( _IapPurchasePending value)?  pending,TResult Function( _IapPurchaseFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IapPurchaseSuccess() when success != null:
return success(_that);case _IapPurchaseCancelled() when cancelled != null:
return cancelled(_that);case _IapPurchasePending() when pending != null:
return pending(_that);case _IapPurchaseFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _IapPurchaseSuccess value)  success,required TResult Function( _IapPurchaseCancelled value)  cancelled,required TResult Function( _IapPurchasePending value)  pending,required TResult Function( _IapPurchaseFailure value)  failure,}){
final _that = this;
switch (_that) {
case _IapPurchaseSuccess():
return success(_that);case _IapPurchaseCancelled():
return cancelled(_that);case _IapPurchasePending():
return pending(_that);case _IapPurchaseFailure():
return failure(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _IapPurchaseSuccess value)?  success,TResult? Function( _IapPurchaseCancelled value)?  cancelled,TResult? Function( _IapPurchasePending value)?  pending,TResult? Function( _IapPurchaseFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _IapPurchaseSuccess() when success != null:
return success(_that);case _IapPurchaseCancelled() when cancelled != null:
return cancelled(_that);case _IapPurchasePending() when pending != null:
return pending(_that);case _IapPurchaseFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String productId,  String? message)?  success,TResult Function( String productId,  String? message)?  cancelled,TResult Function( String productId,  String? message)?  pending,TResult Function( String productId,  String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IapPurchaseSuccess() when success != null:
return success(_that.productId,_that.message);case _IapPurchaseCancelled() when cancelled != null:
return cancelled(_that.productId,_that.message);case _IapPurchasePending() when pending != null:
return pending(_that.productId,_that.message);case _IapPurchaseFailure() when failure != null:
return failure(_that.productId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String productId,  String? message)  success,required TResult Function( String productId,  String? message)  cancelled,required TResult Function( String productId,  String? message)  pending,required TResult Function( String productId,  String message)  failure,}) {final _that = this;
switch (_that) {
case _IapPurchaseSuccess():
return success(_that.productId,_that.message);case _IapPurchaseCancelled():
return cancelled(_that.productId,_that.message);case _IapPurchasePending():
return pending(_that.productId,_that.message);case _IapPurchaseFailure():
return failure(_that.productId,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String productId,  String? message)?  success,TResult? Function( String productId,  String? message)?  cancelled,TResult? Function( String productId,  String? message)?  pending,TResult? Function( String productId,  String message)?  failure,}) {final _that = this;
switch (_that) {
case _IapPurchaseSuccess() when success != null:
return success(_that.productId,_that.message);case _IapPurchaseCancelled() when cancelled != null:
return cancelled(_that.productId,_that.message);case _IapPurchasePending() when pending != null:
return pending(_that.productId,_that.message);case _IapPurchaseFailure() when failure != null:
return failure(_that.productId,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _IapPurchaseSuccess implements IapPurchaseResult {
  const _IapPurchaseSuccess({required this.productId, this.message});
  

@override final  String productId;
@override final  String? message;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapPurchaseSuccessCopyWith<_IapPurchaseSuccess> get copyWith => __$IapPurchaseSuccessCopyWithImpl<_IapPurchaseSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapPurchaseSuccess&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,productId,message);

@override
String toString() {
  return 'IapPurchaseResult.success(productId: $productId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$IapPurchaseSuccessCopyWith<$Res> implements $IapPurchaseResultCopyWith<$Res> {
  factory _$IapPurchaseSuccessCopyWith(_IapPurchaseSuccess value, $Res Function(_IapPurchaseSuccess) _then) = __$IapPurchaseSuccessCopyWithImpl;
@override @useResult
$Res call({
 String productId, String? message
});




}
/// @nodoc
class __$IapPurchaseSuccessCopyWithImpl<$Res>
    implements _$IapPurchaseSuccessCopyWith<$Res> {
  __$IapPurchaseSuccessCopyWithImpl(this._self, this._then);

  final _IapPurchaseSuccess _self;
  final $Res Function(_IapPurchaseSuccess) _then;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? message = freezed,}) {
  return _then(_IapPurchaseSuccess(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _IapPurchaseCancelled implements IapPurchaseResult {
  const _IapPurchaseCancelled({required this.productId, this.message});
  

@override final  String productId;
@override final  String? message;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapPurchaseCancelledCopyWith<_IapPurchaseCancelled> get copyWith => __$IapPurchaseCancelledCopyWithImpl<_IapPurchaseCancelled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapPurchaseCancelled&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,productId,message);

@override
String toString() {
  return 'IapPurchaseResult.cancelled(productId: $productId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$IapPurchaseCancelledCopyWith<$Res> implements $IapPurchaseResultCopyWith<$Res> {
  factory _$IapPurchaseCancelledCopyWith(_IapPurchaseCancelled value, $Res Function(_IapPurchaseCancelled) _then) = __$IapPurchaseCancelledCopyWithImpl;
@override @useResult
$Res call({
 String productId, String? message
});




}
/// @nodoc
class __$IapPurchaseCancelledCopyWithImpl<$Res>
    implements _$IapPurchaseCancelledCopyWith<$Res> {
  __$IapPurchaseCancelledCopyWithImpl(this._self, this._then);

  final _IapPurchaseCancelled _self;
  final $Res Function(_IapPurchaseCancelled) _then;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? message = freezed,}) {
  return _then(_IapPurchaseCancelled(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _IapPurchasePending implements IapPurchaseResult {
  const _IapPurchasePending({required this.productId, this.message});
  

@override final  String productId;
@override final  String? message;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapPurchasePendingCopyWith<_IapPurchasePending> get copyWith => __$IapPurchasePendingCopyWithImpl<_IapPurchasePending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapPurchasePending&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,productId,message);

@override
String toString() {
  return 'IapPurchaseResult.pending(productId: $productId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$IapPurchasePendingCopyWith<$Res> implements $IapPurchaseResultCopyWith<$Res> {
  factory _$IapPurchasePendingCopyWith(_IapPurchasePending value, $Res Function(_IapPurchasePending) _then) = __$IapPurchasePendingCopyWithImpl;
@override @useResult
$Res call({
 String productId, String? message
});




}
/// @nodoc
class __$IapPurchasePendingCopyWithImpl<$Res>
    implements _$IapPurchasePendingCopyWith<$Res> {
  __$IapPurchasePendingCopyWithImpl(this._self, this._then);

  final _IapPurchasePending _self;
  final $Res Function(_IapPurchasePending) _then;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? message = freezed,}) {
  return _then(_IapPurchasePending(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _IapPurchaseFailure implements IapPurchaseResult {
  const _IapPurchaseFailure({required this.productId, required this.message});
  

@override final  String productId;
@override final  String message;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IapPurchaseFailureCopyWith<_IapPurchaseFailure> get copyWith => __$IapPurchaseFailureCopyWithImpl<_IapPurchaseFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IapPurchaseFailure&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,productId,message);

@override
String toString() {
  return 'IapPurchaseResult.failure(productId: $productId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$IapPurchaseFailureCopyWith<$Res> implements $IapPurchaseResultCopyWith<$Res> {
  factory _$IapPurchaseFailureCopyWith(_IapPurchaseFailure value, $Res Function(_IapPurchaseFailure) _then) = __$IapPurchaseFailureCopyWithImpl;
@override @useResult
$Res call({
 String productId, String message
});




}
/// @nodoc
class __$IapPurchaseFailureCopyWithImpl<$Res>
    implements _$IapPurchaseFailureCopyWith<$Res> {
  __$IapPurchaseFailureCopyWithImpl(this._self, this._then);

  final _IapPurchaseFailure _self;
  final $Res Function(_IapPurchaseFailure) _then;

/// Create a copy of IapPurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? message = null,}) {
  return _then(_IapPurchaseFailure(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
