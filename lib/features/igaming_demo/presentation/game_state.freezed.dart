// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameState()';
}


}

/// @nodoc
class $GameStateCopyWith<$Res>  {
$GameStateCopyWith(GameState _, $Res Function(GameState) __);
}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GameIdle value)?  idle,TResult Function( _GamePlacingBet value)?  placingBet,TResult Function( _GameSpinning value)?  spinning,TResult Function( _GameResult value)?  result,TResult Function( _GameError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameIdle() when idle != null:
return idle(_that);case _GamePlacingBet() when placingBet != null:
return placingBet(_that);case _GameSpinning() when spinning != null:
return spinning(_that);case _GameResult() when result != null:
return result(_that);case _GameError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GameIdle value)  idle,required TResult Function( _GamePlacingBet value)  placingBet,required TResult Function( _GameSpinning value)  spinning,required TResult Function( _GameResult value)  result,required TResult Function( _GameError value)  error,}){
final _that = this;
switch (_that) {
case _GameIdle():
return idle(_that);case _GamePlacingBet():
return placingBet(_that);case _GameSpinning():
return spinning(_that);case _GameResult():
return result(_that);case _GameError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GameIdle value)?  idle,TResult? Function( _GamePlacingBet value)?  placingBet,TResult? Function( _GameSpinning value)?  spinning,TResult? Function( _GameResult value)?  result,TResult? Function( _GameError value)?  error,}){
final _that = this;
switch (_that) {
case _GameIdle() when idle != null:
return idle(_that);case _GamePlacingBet() when placingBet != null:
return placingBet(_that);case _GameSpinning() when spinning != null:
return spinning(_that);case _GameResult() when result != null:
return result(_that);case _GameError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DemoBalance balance,  int selectedStake)?  idle,TResult Function( DemoBalance balance,  int selectedStake)?  placingBet,TResult Function( DemoBalance balance,  int bet,  List<int> targetReelSymbolIndices)?  spinning,TResult Function( GameRoundResult roundResult,  DemoBalance newBalance,  int selectedStake,  List<int> targetReelSymbolIndices)?  result,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameIdle() when idle != null:
return idle(_that.balance,_that.selectedStake);case _GamePlacingBet() when placingBet != null:
return placingBet(_that.balance,_that.selectedStake);case _GameSpinning() when spinning != null:
return spinning(_that.balance,_that.bet,_that.targetReelSymbolIndices);case _GameResult() when result != null:
return result(_that.roundResult,_that.newBalance,_that.selectedStake,_that.targetReelSymbolIndices);case _GameError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DemoBalance balance,  int selectedStake)  idle,required TResult Function( DemoBalance balance,  int selectedStake)  placingBet,required TResult Function( DemoBalance balance,  int bet,  List<int> targetReelSymbolIndices)  spinning,required TResult Function( GameRoundResult roundResult,  DemoBalance newBalance,  int selectedStake,  List<int> targetReelSymbolIndices)  result,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _GameIdle():
return idle(_that.balance,_that.selectedStake);case _GamePlacingBet():
return placingBet(_that.balance,_that.selectedStake);case _GameSpinning():
return spinning(_that.balance,_that.bet,_that.targetReelSymbolIndices);case _GameResult():
return result(_that.roundResult,_that.newBalance,_that.selectedStake,_that.targetReelSymbolIndices);case _GameError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DemoBalance balance,  int selectedStake)?  idle,TResult? Function( DemoBalance balance,  int selectedStake)?  placingBet,TResult? Function( DemoBalance balance,  int bet,  List<int> targetReelSymbolIndices)?  spinning,TResult? Function( GameRoundResult roundResult,  DemoBalance newBalance,  int selectedStake,  List<int> targetReelSymbolIndices)?  result,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _GameIdle() when idle != null:
return idle(_that.balance,_that.selectedStake);case _GamePlacingBet() when placingBet != null:
return placingBet(_that.balance,_that.selectedStake);case _GameSpinning() when spinning != null:
return spinning(_that.balance,_that.bet,_that.targetReelSymbolIndices);case _GameResult() when result != null:
return result(_that.roundResult,_that.newBalance,_that.selectedStake,_that.targetReelSymbolIndices);case _GameError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GameIdle extends GameState {
  const _GameIdle(this.balance, this.selectedStake): super._();
  

 final  DemoBalance balance;
 final  int selectedStake;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameIdleCopyWith<_GameIdle> get copyWith => __$GameIdleCopyWithImpl<_GameIdle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameIdle&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.selectedStake, selectedStake) || other.selectedStake == selectedStake));
}


@override
int get hashCode => Object.hash(runtimeType,balance,selectedStake);

@override
String toString() {
  return 'GameState.idle(balance: $balance, selectedStake: $selectedStake)';
}


}

/// @nodoc
abstract mixin class _$GameIdleCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameIdleCopyWith(_GameIdle value, $Res Function(_GameIdle) _then) = __$GameIdleCopyWithImpl;
@useResult
$Res call({
 DemoBalance balance, int selectedStake
});


$DemoBalanceCopyWith<$Res> get balance;

}
/// @nodoc
class __$GameIdleCopyWithImpl<$Res>
    implements _$GameIdleCopyWith<$Res> {
  __$GameIdleCopyWithImpl(this._self, this._then);

  final _GameIdle _self;
  final $Res Function(_GameIdle) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? selectedStake = null,}) {
  return _then(_GameIdle(
null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as DemoBalance,null == selectedStake ? _self.selectedStake : selectedStake // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GameState
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


class _GamePlacingBet extends GameState {
  const _GamePlacingBet(this.balance, this.selectedStake): super._();
  

 final  DemoBalance balance;
 final  int selectedStake;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlacingBetCopyWith<_GamePlacingBet> get copyWith => __$GamePlacingBetCopyWithImpl<_GamePlacingBet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlacingBet&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.selectedStake, selectedStake) || other.selectedStake == selectedStake));
}


@override
int get hashCode => Object.hash(runtimeType,balance,selectedStake);

@override
String toString() {
  return 'GameState.placingBet(balance: $balance, selectedStake: $selectedStake)';
}


}

/// @nodoc
abstract mixin class _$GamePlacingBetCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GamePlacingBetCopyWith(_GamePlacingBet value, $Res Function(_GamePlacingBet) _then) = __$GamePlacingBetCopyWithImpl;
@useResult
$Res call({
 DemoBalance balance, int selectedStake
});


$DemoBalanceCopyWith<$Res> get balance;

}
/// @nodoc
class __$GamePlacingBetCopyWithImpl<$Res>
    implements _$GamePlacingBetCopyWith<$Res> {
  __$GamePlacingBetCopyWithImpl(this._self, this._then);

  final _GamePlacingBet _self;
  final $Res Function(_GamePlacingBet) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? selectedStake = null,}) {
  return _then(_GamePlacingBet(
null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as DemoBalance,null == selectedStake ? _self.selectedStake : selectedStake // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GameState
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


class _GameSpinning extends GameState {
  const _GameSpinning(this.balance, this.bet, final  List<int> targetReelSymbolIndices): _targetReelSymbolIndices = targetReelSymbolIndices,super._();
  

 final  DemoBalance balance;
 final  int bet;
 final  List<int> _targetReelSymbolIndices;
 List<int> get targetReelSymbolIndices {
  if (_targetReelSymbolIndices is EqualUnmodifiableListView) return _targetReelSymbolIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetReelSymbolIndices);
}


/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSpinningCopyWith<_GameSpinning> get copyWith => __$GameSpinningCopyWithImpl<_GameSpinning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSpinning&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.bet, bet) || other.bet == bet)&&const DeepCollectionEquality().equals(other._targetReelSymbolIndices, _targetReelSymbolIndices));
}


@override
int get hashCode => Object.hash(runtimeType,balance,bet,const DeepCollectionEquality().hash(_targetReelSymbolIndices));

@override
String toString() {
  return 'GameState.spinning(balance: $balance, bet: $bet, targetReelSymbolIndices: $targetReelSymbolIndices)';
}


}

/// @nodoc
abstract mixin class _$GameSpinningCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameSpinningCopyWith(_GameSpinning value, $Res Function(_GameSpinning) _then) = __$GameSpinningCopyWithImpl;
@useResult
$Res call({
 DemoBalance balance, int bet, List<int> targetReelSymbolIndices
});


$DemoBalanceCopyWith<$Res> get balance;

}
/// @nodoc
class __$GameSpinningCopyWithImpl<$Res>
    implements _$GameSpinningCopyWith<$Res> {
  __$GameSpinningCopyWithImpl(this._self, this._then);

  final _GameSpinning _self;
  final $Res Function(_GameSpinning) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? balance = null,Object? bet = null,Object? targetReelSymbolIndices = null,}) {
  return _then(_GameSpinning(
null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as DemoBalance,null == bet ? _self.bet : bet // ignore: cast_nullable_to_non_nullable
as int,null == targetReelSymbolIndices ? _self._targetReelSymbolIndices : targetReelSymbolIndices // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of GameState
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


class _GameResult extends GameState {
  const _GameResult(this.roundResult, this.newBalance, this.selectedStake, final  List<int> targetReelSymbolIndices): _targetReelSymbolIndices = targetReelSymbolIndices,super._();
  

 final  GameRoundResult roundResult;
 final  DemoBalance newBalance;
 final  int selectedStake;
 final  List<int> _targetReelSymbolIndices;
 List<int> get targetReelSymbolIndices {
  if (_targetReelSymbolIndices is EqualUnmodifiableListView) return _targetReelSymbolIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targetReelSymbolIndices);
}


/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameResultCopyWith<_GameResult> get copyWith => __$GameResultCopyWithImpl<_GameResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameResult&&(identical(other.roundResult, roundResult) || other.roundResult == roundResult)&&(identical(other.newBalance, newBalance) || other.newBalance == newBalance)&&(identical(other.selectedStake, selectedStake) || other.selectedStake == selectedStake)&&const DeepCollectionEquality().equals(other._targetReelSymbolIndices, _targetReelSymbolIndices));
}


@override
int get hashCode => Object.hash(runtimeType,roundResult,newBalance,selectedStake,const DeepCollectionEquality().hash(_targetReelSymbolIndices));

@override
String toString() {
  return 'GameState.result(roundResult: $roundResult, newBalance: $newBalance, selectedStake: $selectedStake, targetReelSymbolIndices: $targetReelSymbolIndices)';
}


}

/// @nodoc
abstract mixin class _$GameResultCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameResultCopyWith(_GameResult value, $Res Function(_GameResult) _then) = __$GameResultCopyWithImpl;
@useResult
$Res call({
 GameRoundResult roundResult, DemoBalance newBalance, int selectedStake, List<int> targetReelSymbolIndices
});


$GameRoundResultCopyWith<$Res> get roundResult;$DemoBalanceCopyWith<$Res> get newBalance;

}
/// @nodoc
class __$GameResultCopyWithImpl<$Res>
    implements _$GameResultCopyWith<$Res> {
  __$GameResultCopyWithImpl(this._self, this._then);

  final _GameResult _self;
  final $Res Function(_GameResult) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? roundResult = null,Object? newBalance = null,Object? selectedStake = null,Object? targetReelSymbolIndices = null,}) {
  return _then(_GameResult(
null == roundResult ? _self.roundResult : roundResult // ignore: cast_nullable_to_non_nullable
as GameRoundResult,null == newBalance ? _self.newBalance : newBalance // ignore: cast_nullable_to_non_nullable
as DemoBalance,null == selectedStake ? _self.selectedStake : selectedStake // ignore: cast_nullable_to_non_nullable
as int,null == targetReelSymbolIndices ? _self._targetReelSymbolIndices : targetReelSymbolIndices // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameRoundResultCopyWith<$Res> get roundResult {
  
  return $GameRoundResultCopyWith<$Res>(_self.roundResult, (value) {
    return _then(_self.copyWith(roundResult: value));
  });
}/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DemoBalanceCopyWith<$Res> get newBalance {
  
  return $DemoBalanceCopyWith<$Res>(_self.newBalance, (value) {
    return _then(_self.copyWith(newBalance: value));
  });
}
}

/// @nodoc


class _GameError extends GameState {
  const _GameError(this.message): super._();
  

 final  String message;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameErrorCopyWith<_GameError> get copyWith => __$GameErrorCopyWithImpl<_GameError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GameState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$GameErrorCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameErrorCopyWith(_GameError value, $Res Function(_GameError) _then) = __$GameErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$GameErrorCopyWithImpl<$Res>
    implements _$GameErrorCopyWith<$Res> {
  __$GameErrorCopyWithImpl(this._self, this._then);

  final _GameError _self;
  final $Res Function(_GameError) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_GameError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
