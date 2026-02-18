// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_history_sheet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistorySheetData {

 List<ChatConversation> get history; bool get hasHistory; String? get activeConversationId; bool get hasActiveMessages;
/// Create a copy of _HistorySheetData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistorySheetDataCopyWith<_HistorySheetData> get copyWith => __$HistorySheetDataCopyWithImpl<_HistorySheetData>(this as _HistorySheetData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistorySheetData&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.hasHistory, hasHistory) || other.hasHistory == hasHistory)&&(identical(other.activeConversationId, activeConversationId) || other.activeConversationId == activeConversationId)&&(identical(other.hasActiveMessages, hasActiveMessages) || other.hasActiveMessages == hasActiveMessages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(history),hasHistory,activeConversationId,hasActiveMessages);

@override
String toString() {
  return '_HistorySheetData(history: $history, hasHistory: $hasHistory, activeConversationId: $activeConversationId, hasActiveMessages: $hasActiveMessages)';
}


}

/// @nodoc
abstract mixin class _$HistorySheetDataCopyWith<$Res>  {
  factory _$HistorySheetDataCopyWith(_HistorySheetData value, $Res Function(_HistorySheetData) _then) = __$HistorySheetDataCopyWithImpl;
@useResult
$Res call({
 List<ChatConversation> history, bool hasHistory, String? activeConversationId, bool hasActiveMessages
});




}
/// @nodoc
class __$HistorySheetDataCopyWithImpl<$Res>
    implements _$HistorySheetDataCopyWith<$Res> {
  __$HistorySheetDataCopyWithImpl(this._self, this._then);

  final _HistorySheetData _self;
  final $Res Function(_HistorySheetData) _then;

/// Create a copy of _HistorySheetData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? history = null,Object? hasHistory = null,Object? activeConversationId = freezed,Object? hasActiveMessages = null,}) {
  return _then(_self.copyWith(
history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,hasHistory: null == hasHistory ? _self.hasHistory : hasHistory // ignore: cast_nullable_to_non_nullable
as bool,activeConversationId: freezed == activeConversationId ? _self.activeConversationId : activeConversationId // ignore: cast_nullable_to_non_nullable
as String?,hasActiveMessages: null == hasActiveMessages ? _self.hasActiveMessages : hasActiveMessages // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [_HistorySheetData].
extension _HistorySheetDataPatterns on _HistorySheetData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __HistorySheetData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __HistorySheetData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __HistorySheetData value)  $default,){
final _that = this;
switch (_that) {
case __HistorySheetData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __HistorySheetData value)?  $default,){
final _that = this;
switch (_that) {
case __HistorySheetData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatConversation> history,  bool hasHistory,  String? activeConversationId,  bool hasActiveMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __HistorySheetData() when $default != null:
return $default(_that.history,_that.hasHistory,_that.activeConversationId,_that.hasActiveMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatConversation> history,  bool hasHistory,  String? activeConversationId,  bool hasActiveMessages)  $default,) {final _that = this;
switch (_that) {
case __HistorySheetData():
return $default(_that.history,_that.hasHistory,_that.activeConversationId,_that.hasActiveMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatConversation> history,  bool hasHistory,  String? activeConversationId,  bool hasActiveMessages)?  $default,) {final _that = this;
switch (_that) {
case __HistorySheetData() when $default != null:
return $default(_that.history,_that.hasHistory,_that.activeConversationId,_that.hasActiveMessages);case _:
  return null;

}
}

}

/// @nodoc


class __HistorySheetData implements _HistorySheetData {
  const __HistorySheetData({required final  List<ChatConversation> history, required this.hasHistory, required this.activeConversationId, required this.hasActiveMessages}): _history = history;
  

 final  List<ChatConversation> _history;
@override List<ChatConversation> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  bool hasHistory;
@override final  String? activeConversationId;
@override final  bool hasActiveMessages;

/// Create a copy of _HistorySheetData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_HistorySheetDataCopyWith<__HistorySheetData> get copyWith => __$_HistorySheetDataCopyWithImpl<__HistorySheetData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __HistorySheetData&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.hasHistory, hasHistory) || other.hasHistory == hasHistory)&&(identical(other.activeConversationId, activeConversationId) || other.activeConversationId == activeConversationId)&&(identical(other.hasActiveMessages, hasActiveMessages) || other.hasActiveMessages == hasActiveMessages));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_history),hasHistory,activeConversationId,hasActiveMessages);

@override
String toString() {
  return '_HistorySheetData(history: $history, hasHistory: $hasHistory, activeConversationId: $activeConversationId, hasActiveMessages: $hasActiveMessages)';
}


}

/// @nodoc
abstract mixin class _$_HistorySheetDataCopyWith<$Res> implements _$HistorySheetDataCopyWith<$Res> {
  factory _$_HistorySheetDataCopyWith(__HistorySheetData value, $Res Function(__HistorySheetData) _then) = __$_HistorySheetDataCopyWithImpl;
@override @useResult
$Res call({
 List<ChatConversation> history, bool hasHistory, String? activeConversationId, bool hasActiveMessages
});




}
/// @nodoc
class __$_HistorySheetDataCopyWithImpl<$Res>
    implements _$_HistorySheetDataCopyWith<$Res> {
  __$_HistorySheetDataCopyWithImpl(this._self, this._then);

  final __HistorySheetData _self;
  final $Res Function(__HistorySheetData) _then;

/// Create a copy of _HistorySheetData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? history = null,Object? hasHistory = null,Object? activeConversationId = freezed,Object? hasActiveMessages = null,}) {
  return _then(__HistorySheetData(
history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,hasHistory: null == hasHistory ? _self.hasHistory : hasHistory // ignore: cast_nullable_to_non_nullable
as bool,activeConversationId: freezed == activeConversationId ? _self.activeConversationId : activeConversationId // ignore: cast_nullable_to_non_nullable
as String?,hasActiveMessages: null == hasActiveMessages ? _self.hasActiveMessages : hasActiveMessages // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
