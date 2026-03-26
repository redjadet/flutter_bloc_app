// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_app_purchase_demo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InAppPurchaseDemoState {

 InAppPurchaseDemoStatus get status; List<IapProduct> get products; IapEntitlements get entitlements; IapPurchaseResult? get lastResult; String? get errorMessage; bool get useFakeRepository; IapDemoForcedOutcome get forcedOutcome; bool get isBusy;
/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InAppPurchaseDemoStateCopyWith<InAppPurchaseDemoState> get copyWith => _$InAppPurchaseDemoStateCopyWithImpl<InAppPurchaseDemoState>(this as InAppPurchaseDemoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InAppPurchaseDemoState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.entitlements, entitlements) || other.entitlements == entitlements)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.useFakeRepository, useFakeRepository) || other.useFakeRepository == useFakeRepository)&&(identical(other.forcedOutcome, forcedOutcome) || other.forcedOutcome == forcedOutcome)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(products),entitlements,lastResult,errorMessage,useFakeRepository,forcedOutcome,isBusy);

@override
String toString() {
  return 'InAppPurchaseDemoState(status: $status, products: $products, entitlements: $entitlements, lastResult: $lastResult, errorMessage: $errorMessage, useFakeRepository: $useFakeRepository, forcedOutcome: $forcedOutcome, isBusy: $isBusy)';
}


}

/// @nodoc
abstract mixin class $InAppPurchaseDemoStateCopyWith<$Res>  {
  factory $InAppPurchaseDemoStateCopyWith(InAppPurchaseDemoState value, $Res Function(InAppPurchaseDemoState) _then) = _$InAppPurchaseDemoStateCopyWithImpl;
@useResult
$Res call({
 InAppPurchaseDemoStatus status, List<IapProduct> products, IapEntitlements entitlements, IapPurchaseResult? lastResult, String? errorMessage, bool useFakeRepository, IapDemoForcedOutcome forcedOutcome, bool isBusy
});


$IapEntitlementsCopyWith<$Res> get entitlements;$IapPurchaseResultCopyWith<$Res>? get lastResult;

}
/// @nodoc
class _$InAppPurchaseDemoStateCopyWithImpl<$Res>
    implements $InAppPurchaseDemoStateCopyWith<$Res> {
  _$InAppPurchaseDemoStateCopyWithImpl(this._self, this._then);

  final InAppPurchaseDemoState _self;
  final $Res Function(InAppPurchaseDemoState) _then;

/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? products = null,Object? entitlements = null,Object? lastResult = freezed,Object? errorMessage = freezed,Object? useFakeRepository = null,Object? forcedOutcome = null,Object? isBusy = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InAppPurchaseDemoStatus,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<IapProduct>,entitlements: null == entitlements ? _self.entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as IapEntitlements,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as IapPurchaseResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,useFakeRepository: null == useFakeRepository ? _self.useFakeRepository : useFakeRepository // ignore: cast_nullable_to_non_nullable
as bool,forcedOutcome: null == forcedOutcome ? _self.forcedOutcome : forcedOutcome // ignore: cast_nullable_to_non_nullable
as IapDemoForcedOutcome,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IapEntitlementsCopyWith<$Res> get entitlements {
  
  return $IapEntitlementsCopyWith<$Res>(_self.entitlements, (value) {
    return _then(_self.copyWith(entitlements: value));
  });
}/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IapPurchaseResultCopyWith<$Res>? get lastResult {
    if (_self.lastResult == null) {
    return null;
  }

  return $IapPurchaseResultCopyWith<$Res>(_self.lastResult!, (value) {
    return _then(_self.copyWith(lastResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [InAppPurchaseDemoState].
extension InAppPurchaseDemoStatePatterns on InAppPurchaseDemoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InAppPurchaseDemoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InAppPurchaseDemoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InAppPurchaseDemoState value)  $default,){
final _that = this;
switch (_that) {
case _InAppPurchaseDemoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InAppPurchaseDemoState value)?  $default,){
final _that = this;
switch (_that) {
case _InAppPurchaseDemoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InAppPurchaseDemoStatus status,  List<IapProduct> products,  IapEntitlements entitlements,  IapPurchaseResult? lastResult,  String? errorMessage,  bool useFakeRepository,  IapDemoForcedOutcome forcedOutcome,  bool isBusy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InAppPurchaseDemoState() when $default != null:
return $default(_that.status,_that.products,_that.entitlements,_that.lastResult,_that.errorMessage,_that.useFakeRepository,_that.forcedOutcome,_that.isBusy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InAppPurchaseDemoStatus status,  List<IapProduct> products,  IapEntitlements entitlements,  IapPurchaseResult? lastResult,  String? errorMessage,  bool useFakeRepository,  IapDemoForcedOutcome forcedOutcome,  bool isBusy)  $default,) {final _that = this;
switch (_that) {
case _InAppPurchaseDemoState():
return $default(_that.status,_that.products,_that.entitlements,_that.lastResult,_that.errorMessage,_that.useFakeRepository,_that.forcedOutcome,_that.isBusy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InAppPurchaseDemoStatus status,  List<IapProduct> products,  IapEntitlements entitlements,  IapPurchaseResult? lastResult,  String? errorMessage,  bool useFakeRepository,  IapDemoForcedOutcome forcedOutcome,  bool isBusy)?  $default,) {final _that = this;
switch (_that) {
case _InAppPurchaseDemoState() when $default != null:
return $default(_that.status,_that.products,_that.entitlements,_that.lastResult,_that.errorMessage,_that.useFakeRepository,_that.forcedOutcome,_that.isBusy);case _:
  return null;

}
}

}

/// @nodoc


class _InAppPurchaseDemoState implements InAppPurchaseDemoState {
  const _InAppPurchaseDemoState({this.status = InAppPurchaseDemoStatus.initial, final  List<IapProduct> products = const <IapProduct>[], this.entitlements = const IapEntitlements(), this.lastResult, this.errorMessage, this.useFakeRepository = true, this.forcedOutcome = IapDemoForcedOutcome.deterministic, this.isBusy = false}): _products = products;
  

@override@JsonKey() final  InAppPurchaseDemoStatus status;
 final  List<IapProduct> _products;
@override@JsonKey() List<IapProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  IapEntitlements entitlements;
@override final  IapPurchaseResult? lastResult;
@override final  String? errorMessage;
@override@JsonKey() final  bool useFakeRepository;
@override@JsonKey() final  IapDemoForcedOutcome forcedOutcome;
@override@JsonKey() final  bool isBusy;

/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InAppPurchaseDemoStateCopyWith<_InAppPurchaseDemoState> get copyWith => __$InAppPurchaseDemoStateCopyWithImpl<_InAppPurchaseDemoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InAppPurchaseDemoState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.entitlements, entitlements) || other.entitlements == entitlements)&&(identical(other.lastResult, lastResult) || other.lastResult == lastResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.useFakeRepository, useFakeRepository) || other.useFakeRepository == useFakeRepository)&&(identical(other.forcedOutcome, forcedOutcome) || other.forcedOutcome == forcedOutcome)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_products),entitlements,lastResult,errorMessage,useFakeRepository,forcedOutcome,isBusy);

@override
String toString() {
  return 'InAppPurchaseDemoState(status: $status, products: $products, entitlements: $entitlements, lastResult: $lastResult, errorMessage: $errorMessage, useFakeRepository: $useFakeRepository, forcedOutcome: $forcedOutcome, isBusy: $isBusy)';
}


}

/// @nodoc
abstract mixin class _$InAppPurchaseDemoStateCopyWith<$Res> implements $InAppPurchaseDemoStateCopyWith<$Res> {
  factory _$InAppPurchaseDemoStateCopyWith(_InAppPurchaseDemoState value, $Res Function(_InAppPurchaseDemoState) _then) = __$InAppPurchaseDemoStateCopyWithImpl;
@override @useResult
$Res call({
 InAppPurchaseDemoStatus status, List<IapProduct> products, IapEntitlements entitlements, IapPurchaseResult? lastResult, String? errorMessage, bool useFakeRepository, IapDemoForcedOutcome forcedOutcome, bool isBusy
});


@override $IapEntitlementsCopyWith<$Res> get entitlements;@override $IapPurchaseResultCopyWith<$Res>? get lastResult;

}
/// @nodoc
class __$InAppPurchaseDemoStateCopyWithImpl<$Res>
    implements _$InAppPurchaseDemoStateCopyWith<$Res> {
  __$InAppPurchaseDemoStateCopyWithImpl(this._self, this._then);

  final _InAppPurchaseDemoState _self;
  final $Res Function(_InAppPurchaseDemoState) _then;

/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? products = null,Object? entitlements = null,Object? lastResult = freezed,Object? errorMessage = freezed,Object? useFakeRepository = null,Object? forcedOutcome = null,Object? isBusy = null,}) {
  return _then(_InAppPurchaseDemoState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InAppPurchaseDemoStatus,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<IapProduct>,entitlements: null == entitlements ? _self.entitlements : entitlements // ignore: cast_nullable_to_non_nullable
as IapEntitlements,lastResult: freezed == lastResult ? _self.lastResult : lastResult // ignore: cast_nullable_to_non_nullable
as IapPurchaseResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,useFakeRepository: null == useFakeRepository ? _self.useFakeRepository : useFakeRepository // ignore: cast_nullable_to_non_nullable
as bool,forcedOutcome: null == forcedOutcome ? _self.forcedOutcome : forcedOutcome // ignore: cast_nullable_to_non_nullable
as IapDemoForcedOutcome,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IapEntitlementsCopyWith<$Res> get entitlements {
  
  return $IapEntitlementsCopyWith<$Res>(_self.entitlements, (value) {
    return _then(_self.copyWith(entitlements: value));
  });
}/// Create a copy of InAppPurchaseDemoState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IapPurchaseResultCopyWith<$Res>? get lastResult {
    if (_self.lastResult == null) {
    return null;
  }

  return $IapPurchaseResultCopyWith<$Res>(_self.lastResult!, (value) {
    return _then(_self.copyWith(lastResult: value));
  });
}
}

// dart format on
