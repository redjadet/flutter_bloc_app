// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CounterViewData {

 int get count; DateTime? get lastChanged; DateTime? get lastSyncedAt; String? get changeId; int get countdownSeconds; int get pendingSyncCount;
/// Create a copy of CounterViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<CounterViewData> get copyWith => _$CounterViewDataCopyWithImpl<CounterViewData>(this as CounterViewData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterViewData&&(identical(other.count, count) || other.count == count)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.changeId, changeId) || other.changeId == changeId)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.pendingSyncCount, pendingSyncCount) || other.pendingSyncCount == pendingSyncCount));
}


@override
int get hashCode => Object.hash(runtimeType,count,lastChanged,lastSyncedAt,changeId,countdownSeconds,pendingSyncCount);

@override
String toString() {
  return 'CounterViewData(count: $count, lastChanged: $lastChanged, lastSyncedAt: $lastSyncedAt, changeId: $changeId, countdownSeconds: $countdownSeconds, pendingSyncCount: $pendingSyncCount)';
}


}

/// @nodoc
abstract mixin class $CounterViewDataCopyWith<$Res>  {
  factory $CounterViewDataCopyWith(CounterViewData value, $Res Function(CounterViewData) _then) = _$CounterViewDataCopyWithImpl;
@useResult
$Res call({
 int count, DateTime? lastChanged, DateTime? lastSyncedAt, String? changeId, int countdownSeconds, int pendingSyncCount
});




}
/// @nodoc
class _$CounterViewDataCopyWithImpl<$Res>
    implements $CounterViewDataCopyWith<$Res> {
  _$CounterViewDataCopyWithImpl(this._self, this._then);

  final CounterViewData _self;
  final $Res Function(CounterViewData) _then;

/// Create a copy of CounterViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? lastChanged = freezed,Object? lastSyncedAt = freezed,Object? changeId = freezed,Object? countdownSeconds = null,Object? pendingSyncCount = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,changeId: freezed == changeId ? _self.changeId : changeId // ignore: cast_nullable_to_non_nullable
as String?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,pendingSyncCount: null == pendingSyncCount ? _self.pendingSyncCount : pendingSyncCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CounterViewData].
extension CounterViewDataPatterns on CounterViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CounterViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CounterViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CounterViewData value)  $default,){
final _that = this;
switch (_that) {
case _CounterViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CounterViewData value)?  $default,){
final _that = this;
switch (_that) {
case _CounterViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  DateTime? lastChanged,  DateTime? lastSyncedAt,  String? changeId,  int countdownSeconds,  int pendingSyncCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CounterViewData() when $default != null:
return $default(_that.count,_that.lastChanged,_that.lastSyncedAt,_that.changeId,_that.countdownSeconds,_that.pendingSyncCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  DateTime? lastChanged,  DateTime? lastSyncedAt,  String? changeId,  int countdownSeconds,  int pendingSyncCount)  $default,) {final _that = this;
switch (_that) {
case _CounterViewData():
return $default(_that.count,_that.lastChanged,_that.lastSyncedAt,_that.changeId,_that.countdownSeconds,_that.pendingSyncCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  DateTime? lastChanged,  DateTime? lastSyncedAt,  String? changeId,  int countdownSeconds,  int pendingSyncCount)?  $default,) {final _that = this;
switch (_that) {
case _CounterViewData() when $default != null:
return $default(_that.count,_that.lastChanged,_that.lastSyncedAt,_that.changeId,_that.countdownSeconds,_that.pendingSyncCount);case _:
  return null;

}
}

}

/// @nodoc


class _CounterViewData implements CounterViewData {
  const _CounterViewData({this.count = 0, this.lastChanged, this.lastSyncedAt, this.changeId, this.countdownSeconds = CounterState.defaultCountdownSeconds, this.pendingSyncCount = 0});
  

@override@JsonKey() final  int count;
@override final  DateTime? lastChanged;
@override final  DateTime? lastSyncedAt;
@override final  String? changeId;
@override@JsonKey() final  int countdownSeconds;
@override@JsonKey() final  int pendingSyncCount;

/// Create a copy of CounterViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterViewDataCopyWith<_CounterViewData> get copyWith => __$CounterViewDataCopyWithImpl<_CounterViewData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterViewData&&(identical(other.count, count) || other.count == count)&&(identical(other.lastChanged, lastChanged) || other.lastChanged == lastChanged)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.changeId, changeId) || other.changeId == changeId)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.pendingSyncCount, pendingSyncCount) || other.pendingSyncCount == pendingSyncCount));
}


@override
int get hashCode => Object.hash(runtimeType,count,lastChanged,lastSyncedAt,changeId,countdownSeconds,pendingSyncCount);

@override
String toString() {
  return 'CounterViewData(count: $count, lastChanged: $lastChanged, lastSyncedAt: $lastSyncedAt, changeId: $changeId, countdownSeconds: $countdownSeconds, pendingSyncCount: $pendingSyncCount)';
}


}

/// @nodoc
abstract mixin class _$CounterViewDataCopyWith<$Res> implements $CounterViewDataCopyWith<$Res> {
  factory _$CounterViewDataCopyWith(_CounterViewData value, $Res Function(_CounterViewData) _then) = __$CounterViewDataCopyWithImpl;
@override @useResult
$Res call({
 int count, DateTime? lastChanged, DateTime? lastSyncedAt, String? changeId, int countdownSeconds, int pendingSyncCount
});




}
/// @nodoc
class __$CounterViewDataCopyWithImpl<$Res>
    implements _$CounterViewDataCopyWith<$Res> {
  __$CounterViewDataCopyWithImpl(this._self, this._then);

  final _CounterViewData _self;
  final $Res Function(_CounterViewData) _then;

/// Create a copy of CounterViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? lastChanged = freezed,Object? lastSyncedAt = freezed,Object? changeId = freezed,Object? countdownSeconds = null,Object? pendingSyncCount = null,}) {
  return _then(_CounterViewData(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,lastChanged: freezed == lastChanged ? _self.lastChanged : lastChanged // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,changeId: freezed == changeId ? _self.changeId : changeId // ignore: cast_nullable_to_non_nullable
as String?,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,pendingSyncCount: null == pendingSyncCount ? _self.pendingSyncCount : pendingSyncCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CounterState {

 CounterViewData get data;
/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterStateCopyWith<CounterState> get copyWith => _$CounterStateCopyWithImpl<CounterState>(this as CounterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterState&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'CounterState(data: $data)';
}


}

/// @nodoc
abstract mixin class $CounterStateCopyWith<$Res>  {
  factory $CounterStateCopyWith(CounterState value, $Res Function(CounterState) _then) = _$CounterStateCopyWithImpl;
@useResult
$Res call({
 CounterViewData data
});


$CounterViewDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CounterStateCopyWithImpl<$Res>
    implements $CounterStateCopyWith<$Res> {
  _$CounterStateCopyWithImpl(this._self, this._then);

  final CounterState _self;
  final $Res Function(CounterState) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CounterViewData,
  ));
}
/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<$Res> get data {
  
  return $CounterViewDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// Adds pattern-matching-related methods to [CounterState].
extension CounterStatePatterns on CounterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CounterInitial value)?  initial,TResult Function( CounterLoading value)?  loading,TResult Function( CounterReady value)?  ready,TResult Function( CounterFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CounterInitial() when initial != null:
return initial(_that);case CounterLoading() when loading != null:
return loading(_that);case CounterReady() when ready != null:
return ready(_that);case CounterFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CounterInitial value)  initial,required TResult Function( CounterLoading value)  loading,required TResult Function( CounterReady value)  ready,required TResult Function( CounterFailure value)  failure,}){
final _that = this;
switch (_that) {
case CounterInitial():
return initial(_that);case CounterLoading():
return loading(_that);case CounterReady():
return ready(_that);case CounterFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CounterInitial value)?  initial,TResult? Function( CounterLoading value)?  loading,TResult? Function( CounterReady value)?  ready,TResult? Function( CounterFailure value)?  failure,}){
final _that = this;
switch (_that) {
case CounterInitial() when initial != null:
return initial(_that);case CounterLoading() when loading != null:
return loading(_that);case CounterReady() when ready != null:
return ready(_that);case CounterFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( CounterViewData data)?  initial,TResult Function( CounterViewData data)?  loading,TResult Function( CounterViewData data)?  ready,TResult Function( CounterViewData data,  CounterError error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CounterInitial() when initial != null:
return initial(_that.data);case CounterLoading() when loading != null:
return loading(_that.data);case CounterReady() when ready != null:
return ready(_that.data);case CounterFailure() when failure != null:
return failure(_that.data,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( CounterViewData data)  initial,required TResult Function( CounterViewData data)  loading,required TResult Function( CounterViewData data)  ready,required TResult Function( CounterViewData data,  CounterError error)  failure,}) {final _that = this;
switch (_that) {
case CounterInitial():
return initial(_that.data);case CounterLoading():
return loading(_that.data);case CounterReady():
return ready(_that.data);case CounterFailure():
return failure(_that.data,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( CounterViewData data)?  initial,TResult? Function( CounterViewData data)?  loading,TResult? Function( CounterViewData data)?  ready,TResult? Function( CounterViewData data,  CounterError error)?  failure,}) {final _that = this;
switch (_that) {
case CounterInitial() when initial != null:
return initial(_that.data);case CounterLoading() when loading != null:
return loading(_that.data);case CounterReady() when ready != null:
return ready(_that.data);case CounterFailure() when failure != null:
return failure(_that.data,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class CounterInitial extends CounterState {
  const CounterInitial({this.data = const CounterViewData()}): super._();
  

@override@JsonKey() final  CounterViewData data;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterInitialCopyWith<CounterInitial> get copyWith => _$CounterInitialCopyWithImpl<CounterInitial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterInitial&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'CounterState.initial(data: $data)';
}


}

/// @nodoc
abstract mixin class $CounterInitialCopyWith<$Res> implements $CounterStateCopyWith<$Res> {
  factory $CounterInitialCopyWith(CounterInitial value, $Res Function(CounterInitial) _then) = _$CounterInitialCopyWithImpl;
@override @useResult
$Res call({
 CounterViewData data
});


@override $CounterViewDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CounterInitialCopyWithImpl<$Res>
    implements $CounterInitialCopyWith<$Res> {
  _$CounterInitialCopyWithImpl(this._self, this._then);

  final CounterInitial _self;
  final $Res Function(CounterInitial) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(CounterInitial(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CounterViewData,
  ));
}

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<$Res> get data {
  
  return $CounterViewDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class CounterLoading extends CounterState {
  const CounterLoading({required this.data}): super._();
  

@override final  CounterViewData data;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterLoadingCopyWith<CounterLoading> get copyWith => _$CounterLoadingCopyWithImpl<CounterLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterLoading&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'CounterState.loading(data: $data)';
}


}

/// @nodoc
abstract mixin class $CounterLoadingCopyWith<$Res> implements $CounterStateCopyWith<$Res> {
  factory $CounterLoadingCopyWith(CounterLoading value, $Res Function(CounterLoading) _then) = _$CounterLoadingCopyWithImpl;
@override @useResult
$Res call({
 CounterViewData data
});


@override $CounterViewDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CounterLoadingCopyWithImpl<$Res>
    implements $CounterLoadingCopyWith<$Res> {
  _$CounterLoadingCopyWithImpl(this._self, this._then);

  final CounterLoading _self;
  final $Res Function(CounterLoading) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(CounterLoading(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CounterViewData,
  ));
}

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<$Res> get data {
  
  return $CounterViewDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class CounterReady extends CounterState {
  const CounterReady({required this.data}): super._();
  

@override final  CounterViewData data;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterReadyCopyWith<CounterReady> get copyWith => _$CounterReadyCopyWithImpl<CounterReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterReady&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'CounterState.ready(data: $data)';
}


}

/// @nodoc
abstract mixin class $CounterReadyCopyWith<$Res> implements $CounterStateCopyWith<$Res> {
  factory $CounterReadyCopyWith(CounterReady value, $Res Function(CounterReady) _then) = _$CounterReadyCopyWithImpl;
@override @useResult
$Res call({
 CounterViewData data
});


@override $CounterViewDataCopyWith<$Res> get data;

}
/// @nodoc
class _$CounterReadyCopyWithImpl<$Res>
    implements $CounterReadyCopyWith<$Res> {
  _$CounterReadyCopyWithImpl(this._self, this._then);

  final CounterReady _self;
  final $Res Function(CounterReady) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(CounterReady(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CounterViewData,
  ));
}

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<$Res> get data {
  
  return $CounterViewDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class CounterFailure extends CounterState {
  const CounterFailure({required this.data, required this.error}): super._();
  

@override final  CounterViewData data;
 final  CounterError error;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterFailureCopyWith<CounterFailure> get copyWith => _$CounterFailureCopyWithImpl<CounterFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterFailure&&(identical(other.data, data) || other.data == data)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,data,error);

@override
String toString() {
  return 'CounterState.failure(data: $data, error: $error)';
}


}

/// @nodoc
abstract mixin class $CounterFailureCopyWith<$Res> implements $CounterStateCopyWith<$Res> {
  factory $CounterFailureCopyWith(CounterFailure value, $Res Function(CounterFailure) _then) = _$CounterFailureCopyWithImpl;
@override @useResult
$Res call({
 CounterViewData data, CounterError error
});


@override $CounterViewDataCopyWith<$Res> get data;$CounterErrorCopyWith<$Res> get error;

}
/// @nodoc
class _$CounterFailureCopyWithImpl<$Res>
    implements $CounterFailureCopyWith<$Res> {
  _$CounterFailureCopyWithImpl(this._self, this._then);

  final CounterFailure _self;
  final $Res Function(CounterFailure) _then;

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? error = null,}) {
  return _then(CounterFailure(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CounterViewData,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as CounterError,
  ));
}

/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterViewDataCopyWith<$Res> get data {
  
  return $CounterViewDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}/// Create a copy of CounterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CounterErrorCopyWith<$Res> get error {
  
  return $CounterErrorCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on
