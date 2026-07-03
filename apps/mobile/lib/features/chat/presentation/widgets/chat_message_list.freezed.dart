// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatListData {

 bool get hasMessages; bool get isLoading; List<ChatMessage> get messages;
/// Create a copy of _ChatListData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatListDataCopyWith<_ChatListData> get copyWith => __$ChatListDataCopyWithImpl<_ChatListData>(this as _ChatListData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatListData&&(identical(other.hasMessages, hasMessages) || other.hasMessages == hasMessages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.messages, messages));
}


@override
int get hashCode => Object.hash(runtimeType,hasMessages,isLoading,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return '_ChatListData(hasMessages: $hasMessages, isLoading: $isLoading, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ChatListDataCopyWith<$Res>  {
  factory _$ChatListDataCopyWith(_ChatListData value, $Res Function(_ChatListData) _then) = __$ChatListDataCopyWithImpl;
@useResult
$Res call({
 bool hasMessages, bool isLoading, List<ChatMessage> messages
});




}
/// @nodoc
class __$ChatListDataCopyWithImpl<$Res>
    implements _$ChatListDataCopyWith<$Res> {
  __$ChatListDataCopyWithImpl(this._self, this._then);

  final _ChatListData _self;
  final $Res Function(_ChatListData) _then;

/// Create a copy of _ChatListData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasMessages = null,Object? isLoading = null,Object? messages = null,}) {
  return _then(_self.copyWith(
hasMessages: null == hasMessages ? _self.hasMessages : hasMessages // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [_ChatListData].
extension _ChatListDataPatterns on _ChatListData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( __ChatListData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case __ChatListData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( __ChatListData value)  $default,){
final _that = this;
switch (_that) {
case __ChatListData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( __ChatListData value)?  $default,){
final _that = this;
switch (_that) {
case __ChatListData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasMessages,  bool isLoading,  List<ChatMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case __ChatListData() when $default != null:
return $default(_that.hasMessages,_that.isLoading,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasMessages,  bool isLoading,  List<ChatMessage> messages)  $default,) {final _that = this;
switch (_that) {
case __ChatListData():
return $default(_that.hasMessages,_that.isLoading,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasMessages,  bool isLoading,  List<ChatMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case __ChatListData() when $default != null:
return $default(_that.hasMessages,_that.isLoading,_that.messages);case _:
  return null;

}
}

}

/// @nodoc


class __ChatListData implements _ChatListData {
  const __ChatListData({required this.hasMessages, required this.isLoading, required final  List<ChatMessage> messages}): _messages = messages;
  

@override final  bool hasMessages;
@override final  bool isLoading;
 final  List<ChatMessage> _messages;
@override List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of _ChatListData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$_ChatListDataCopyWith<__ChatListData> get copyWith => __$_ChatListDataCopyWithImpl<__ChatListData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is __ChatListData&&(identical(other.hasMessages, hasMessages) || other.hasMessages == hasMessages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._messages, _messages));
}


@override
int get hashCode => Object.hash(runtimeType,hasMessages,isLoading,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return '_ChatListData(hasMessages: $hasMessages, isLoading: $isLoading, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$_ChatListDataCopyWith<$Res> implements _$ChatListDataCopyWith<$Res> {
  factory _$_ChatListDataCopyWith(__ChatListData value, $Res Function(__ChatListData) _then) = __$_ChatListDataCopyWithImpl;
@override @useResult
$Res call({
 bool hasMessages, bool isLoading, List<ChatMessage> messages
});




}
/// @nodoc
class __$_ChatListDataCopyWithImpl<$Res>
    implements _$_ChatListDataCopyWith<$Res> {
  __$_ChatListDataCopyWithImpl(this._self, this._then);

  final __ChatListData _self;
  final $Res Function(__ChatListData) _then;

/// Create a copy of _ChatListData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasMessages = null,Object? isLoading = null,Object? messages = null,}) {
  return _then(__ChatListData(
hasMessages: null == hasMessages ? _self.hasMessages : hasMessages // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}


}

// dart format on
