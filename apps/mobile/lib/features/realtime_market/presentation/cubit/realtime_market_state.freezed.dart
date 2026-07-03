// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realtime_market_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RealtimeMarketState {

 String get pairId; MarketFeedSnapshot? get snapshot; bool get bootstrapComplete; String? get loadErrorMessage; RealtimeMarketSideTab get sideTab;
/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealtimeMarketStateCopyWith<RealtimeMarketState> get copyWith => _$RealtimeMarketStateCopyWithImpl<RealtimeMarketState>(this as RealtimeMarketState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealtimeMarketState&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.bootstrapComplete, bootstrapComplete) || other.bootstrapComplete == bootstrapComplete)&&(identical(other.loadErrorMessage, loadErrorMessage) || other.loadErrorMessage == loadErrorMessage)&&(identical(other.sideTab, sideTab) || other.sideTab == sideTab));
}


@override
int get hashCode => Object.hash(runtimeType,pairId,snapshot,bootstrapComplete,loadErrorMessage,sideTab);

@override
String toString() {
  return 'RealtimeMarketState(pairId: $pairId, snapshot: $snapshot, bootstrapComplete: $bootstrapComplete, loadErrorMessage: $loadErrorMessage, sideTab: $sideTab)';
}


}

/// @nodoc
abstract mixin class $RealtimeMarketStateCopyWith<$Res>  {
  factory $RealtimeMarketStateCopyWith(RealtimeMarketState value, $Res Function(RealtimeMarketState) _then) = _$RealtimeMarketStateCopyWithImpl;
@useResult
$Res call({
 String pairId, MarketFeedSnapshot? snapshot, bool bootstrapComplete, String? loadErrorMessage, RealtimeMarketSideTab sideTab
});


$MarketFeedSnapshotCopyWith<$Res>? get snapshot;

}
/// @nodoc
class _$RealtimeMarketStateCopyWithImpl<$Res>
    implements $RealtimeMarketStateCopyWith<$Res> {
  _$RealtimeMarketStateCopyWithImpl(this._self, this._then);

  final RealtimeMarketState _self;
  final $Res Function(RealtimeMarketState) _then;

/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pairId = null,Object? snapshot = freezed,Object? bootstrapComplete = null,Object? loadErrorMessage = freezed,Object? sideTab = null,}) {
  return _then(_self.copyWith(
pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,snapshot: freezed == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as MarketFeedSnapshot?,bootstrapComplete: null == bootstrapComplete ? _self.bootstrapComplete : bootstrapComplete // ignore: cast_nullable_to_non_nullable
as bool,loadErrorMessage: freezed == loadErrorMessage ? _self.loadErrorMessage : loadErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,sideTab: null == sideTab ? _self.sideTab : sideTab // ignore: cast_nullable_to_non_nullable
as RealtimeMarketSideTab,
  ));
}
/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketFeedSnapshotCopyWith<$Res>? get snapshot {
    if (_self.snapshot == null) {
    return null;
  }

  return $MarketFeedSnapshotCopyWith<$Res>(_self.snapshot!, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [RealtimeMarketState].
extension RealtimeMarketStatePatterns on RealtimeMarketState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealtimeMarketState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealtimeMarketState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealtimeMarketState value)  $default,){
final _that = this;
switch (_that) {
case _RealtimeMarketState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealtimeMarketState value)?  $default,){
final _that = this;
switch (_that) {
case _RealtimeMarketState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pairId,  MarketFeedSnapshot? snapshot,  bool bootstrapComplete,  String? loadErrorMessage,  RealtimeMarketSideTab sideTab)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealtimeMarketState() when $default != null:
return $default(_that.pairId,_that.snapshot,_that.bootstrapComplete,_that.loadErrorMessage,_that.sideTab);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pairId,  MarketFeedSnapshot? snapshot,  bool bootstrapComplete,  String? loadErrorMessage,  RealtimeMarketSideTab sideTab)  $default,) {final _that = this;
switch (_that) {
case _RealtimeMarketState():
return $default(_that.pairId,_that.snapshot,_that.bootstrapComplete,_that.loadErrorMessage,_that.sideTab);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pairId,  MarketFeedSnapshot? snapshot,  bool bootstrapComplete,  String? loadErrorMessage,  RealtimeMarketSideTab sideTab)?  $default,) {final _that = this;
switch (_that) {
case _RealtimeMarketState() when $default != null:
return $default(_that.pairId,_that.snapshot,_that.bootstrapComplete,_that.loadErrorMessage,_that.sideTab);case _:
  return null;

}
}

}

/// @nodoc


class _RealtimeMarketState implements RealtimeMarketState {
  const _RealtimeMarketState({required this.pairId, this.snapshot, this.bootstrapComplete = false, this.loadErrorMessage, this.sideTab = RealtimeMarketSideTab.bids});
  

@override final  String pairId;
@override final  MarketFeedSnapshot? snapshot;
@override@JsonKey() final  bool bootstrapComplete;
@override final  String? loadErrorMessage;
@override@JsonKey() final  RealtimeMarketSideTab sideTab;

/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealtimeMarketStateCopyWith<_RealtimeMarketState> get copyWith => __$RealtimeMarketStateCopyWithImpl<_RealtimeMarketState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealtimeMarketState&&(identical(other.pairId, pairId) || other.pairId == pairId)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot)&&(identical(other.bootstrapComplete, bootstrapComplete) || other.bootstrapComplete == bootstrapComplete)&&(identical(other.loadErrorMessage, loadErrorMessage) || other.loadErrorMessage == loadErrorMessage)&&(identical(other.sideTab, sideTab) || other.sideTab == sideTab));
}


@override
int get hashCode => Object.hash(runtimeType,pairId,snapshot,bootstrapComplete,loadErrorMessage,sideTab);

@override
String toString() {
  return 'RealtimeMarketState(pairId: $pairId, snapshot: $snapshot, bootstrapComplete: $bootstrapComplete, loadErrorMessage: $loadErrorMessage, sideTab: $sideTab)';
}


}

/// @nodoc
abstract mixin class _$RealtimeMarketStateCopyWith<$Res> implements $RealtimeMarketStateCopyWith<$Res> {
  factory _$RealtimeMarketStateCopyWith(_RealtimeMarketState value, $Res Function(_RealtimeMarketState) _then) = __$RealtimeMarketStateCopyWithImpl;
@override @useResult
$Res call({
 String pairId, MarketFeedSnapshot? snapshot, bool bootstrapComplete, String? loadErrorMessage, RealtimeMarketSideTab sideTab
});


@override $MarketFeedSnapshotCopyWith<$Res>? get snapshot;

}
/// @nodoc
class __$RealtimeMarketStateCopyWithImpl<$Res>
    implements _$RealtimeMarketStateCopyWith<$Res> {
  __$RealtimeMarketStateCopyWithImpl(this._self, this._then);

  final _RealtimeMarketState _self;
  final $Res Function(_RealtimeMarketState) _then;

/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pairId = null,Object? snapshot = freezed,Object? bootstrapComplete = null,Object? loadErrorMessage = freezed,Object? sideTab = null,}) {
  return _then(_RealtimeMarketState(
pairId: null == pairId ? _self.pairId : pairId // ignore: cast_nullable_to_non_nullable
as String,snapshot: freezed == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as MarketFeedSnapshot?,bootstrapComplete: null == bootstrapComplete ? _self.bootstrapComplete : bootstrapComplete // ignore: cast_nullable_to_non_nullable
as bool,loadErrorMessage: freezed == loadErrorMessage ? _self.loadErrorMessage : loadErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,sideTab: null == sideTab ? _self.sideTab : sideTab // ignore: cast_nullable_to_non_nullable
as RealtimeMarketSideTab,
  ));
}

/// Create a copy of RealtimeMarketState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarketFeedSnapshotCopyWith<$Res>? get snapshot {
    if (_self.snapshot == null) {
    return null;
  }

  return $MarketFeedSnapshotCopyWith<$Res>(_self.snapshot!, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}

// dart format on
