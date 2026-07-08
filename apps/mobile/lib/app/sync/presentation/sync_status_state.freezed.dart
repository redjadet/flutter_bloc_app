// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncStatusState {

 NetworkStatus get networkStatus; SyncStatus get syncStatus; SyncCycleSummary? get lastSummary; List<SyncCycleSummary> get history;
/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStatusStateCopyWith<SyncStatusState> get copyWith => _$SyncStatusStateCopyWithImpl<SyncStatusState>(this as SyncStatusState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatusState&&(identical(other.networkStatus, networkStatus) || other.networkStatus == networkStatus)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSummary, lastSummary) || other.lastSummary == lastSummary)&&const DeepCollectionEquality().equals(other.history, history));
}


@override
int get hashCode => Object.hash(runtimeType,networkStatus,syncStatus,lastSummary,const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'SyncStatusState(networkStatus: $networkStatus, syncStatus: $syncStatus, lastSummary: $lastSummary, history: $history)';
}


}

/// @nodoc
abstract mixin class $SyncStatusStateCopyWith<$Res>  {
  factory $SyncStatusStateCopyWith(SyncStatusState value, $Res Function(SyncStatusState) _then) = _$SyncStatusStateCopyWithImpl;
@useResult
$Res call({
 NetworkStatus networkStatus, SyncStatus syncStatus, SyncCycleSummary? lastSummary, List<SyncCycleSummary> history
});


$SyncCycleSummaryCopyWith<$Res>? get lastSummary;

}
/// @nodoc
class _$SyncStatusStateCopyWithImpl<$Res>
    implements $SyncStatusStateCopyWith<$Res> {
  _$SyncStatusStateCopyWithImpl(this._self, this._then);

  final SyncStatusState _self;
  final $Res Function(SyncStatusState) _then;

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? networkStatus = null,Object? syncStatus = null,Object? lastSummary = freezed,Object? history = null,}) {
  return _then(_self.copyWith(
networkStatus: null == networkStatus ? _self.networkStatus : networkStatus // ignore: cast_nullable_to_non_nullable
as NetworkStatus,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSummary: freezed == lastSummary ? _self.lastSummary : lastSummary // ignore: cast_nullable_to_non_nullable
as SyncCycleSummary?,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<SyncCycleSummary>,
  ));
}
/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncCycleSummaryCopyWith<$Res>? get lastSummary {
    if (_self.lastSummary == null) {
    return null;
  }

  return $SyncCycleSummaryCopyWith<$Res>(_self.lastSummary!, (value) {
    return _then(_self.copyWith(lastSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [SyncStatusState].
extension SyncStatusStatePatterns on SyncStatusState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncStatusState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncStatusState value)  $default,){
final _that = this;
switch (_that) {
case _SyncStatusState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncStatusState value)?  $default,){
final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NetworkStatus networkStatus,  SyncStatus syncStatus,  SyncCycleSummary? lastSummary,  List<SyncCycleSummary> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
return $default(_that.networkStatus,_that.syncStatus,_that.lastSummary,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NetworkStatus networkStatus,  SyncStatus syncStatus,  SyncCycleSummary? lastSummary,  List<SyncCycleSummary> history)  $default,) {final _that = this;
switch (_that) {
case _SyncStatusState():
return $default(_that.networkStatus,_that.syncStatus,_that.lastSummary,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NetworkStatus networkStatus,  SyncStatus syncStatus,  SyncCycleSummary? lastSummary,  List<SyncCycleSummary> history)?  $default,) {final _that = this;
switch (_that) {
case _SyncStatusState() when $default != null:
return $default(_that.networkStatus,_that.syncStatus,_that.lastSummary,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _SyncStatusState extends SyncStatusState {
  const _SyncStatusState({required this.networkStatus, required this.syncStatus, this.lastSummary, final  List<SyncCycleSummary> history = const <SyncCycleSummary>[]}): _history = history,super._();
  

@override final  NetworkStatus networkStatus;
@override final  SyncStatus syncStatus;
@override final  SyncCycleSummary? lastSummary;
 final  List<SyncCycleSummary> _history;
@override@JsonKey() List<SyncCycleSummary> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStatusStateCopyWith<_SyncStatusState> get copyWith => __$SyncStatusStateCopyWithImpl<_SyncStatusState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncStatusState&&(identical(other.networkStatus, networkStatus) || other.networkStatus == networkStatus)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.lastSummary, lastSummary) || other.lastSummary == lastSummary)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,networkStatus,syncStatus,lastSummary,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'SyncStatusState(networkStatus: $networkStatus, syncStatus: $syncStatus, lastSummary: $lastSummary, history: $history)';
}


}

/// @nodoc
abstract mixin class _$SyncStatusStateCopyWith<$Res> implements $SyncStatusStateCopyWith<$Res> {
  factory _$SyncStatusStateCopyWith(_SyncStatusState value, $Res Function(_SyncStatusState) _then) = __$SyncStatusStateCopyWithImpl;
@override @useResult
$Res call({
 NetworkStatus networkStatus, SyncStatus syncStatus, SyncCycleSummary? lastSummary, List<SyncCycleSummary> history
});


@override $SyncCycleSummaryCopyWith<$Res>? get lastSummary;

}
/// @nodoc
class __$SyncStatusStateCopyWithImpl<$Res>
    implements _$SyncStatusStateCopyWith<$Res> {
  __$SyncStatusStateCopyWithImpl(this._self, this._then);

  final _SyncStatusState _self;
  final $Res Function(_SyncStatusState) _then;

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? networkStatus = null,Object? syncStatus = null,Object? lastSummary = freezed,Object? history = null,}) {
  return _then(_SyncStatusState(
networkStatus: null == networkStatus ? _self.networkStatus : networkStatus // ignore: cast_nullable_to_non_nullable
as NetworkStatus,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSummary: freezed == lastSummary ? _self.lastSummary : lastSummary // ignore: cast_nullable_to_non_nullable
as SyncCycleSummary?,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<SyncCycleSummary>,
  ));
}

/// Create a copy of SyncStatusState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SyncCycleSummaryCopyWith<$Res>? get lastSummary {
    if (_self.lastSummary == null) {
    return null;
  }

  return $SyncCycleSummaryCopyWith<$Res>(_self.lastSummary!, (value) {
    return _then(_self.copyWith(lastSummary: value));
  });
}
}

// dart format on
