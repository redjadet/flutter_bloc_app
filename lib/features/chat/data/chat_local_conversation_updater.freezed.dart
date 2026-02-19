// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_local_conversation_updater.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatLocalConversationState {

 ChatConversation get conversation; List<ChatMessage> get messages; List<ChatConversation> get existing; int get index; DateTime get now;
/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatLocalConversationStateCopyWith<ChatLocalConversationState> get copyWith => _$ChatLocalConversationStateCopyWithImpl<ChatLocalConversationState>(this as ChatLocalConversationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatLocalConversationState&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.existing, existing)&&(identical(other.index, index) || other.index == index)&&(identical(other.now, now) || other.now == now));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(existing),index,now);

@override
String toString() {
  return 'ChatLocalConversationState(conversation: $conversation, messages: $messages, existing: $existing, index: $index, now: $now)';
}


}

/// @nodoc
abstract mixin class $ChatLocalConversationStateCopyWith<$Res>  {
  factory $ChatLocalConversationStateCopyWith(ChatLocalConversationState value, $Res Function(ChatLocalConversationState) _then) = _$ChatLocalConversationStateCopyWithImpl;
@useResult
$Res call({
 ChatConversation conversation, List<ChatMessage> messages, List<ChatConversation> existing, int index, DateTime now
});


$ChatConversationCopyWith<$Res> get conversation;

}
/// @nodoc
class _$ChatLocalConversationStateCopyWithImpl<$Res>
    implements $ChatLocalConversationStateCopyWith<$Res> {
  _$ChatLocalConversationStateCopyWithImpl(this._self, this._then);

  final ChatLocalConversationState _self;
  final $Res Function(ChatLocalConversationState) _then;

/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversation = null,Object? messages = null,Object? existing = null,Object? index = null,Object? now = null,}) {
  return _then(_self.copyWith(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ChatConversation,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,existing: null == existing ? _self.existing : existing // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<$Res> get conversation {
  
  return $ChatConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatLocalConversationState].
extension ChatLocalConversationStatePatterns on ChatLocalConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatLocalConversationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatLocalConversationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatLocalConversationState value)  $default,){
final _that = this;
switch (_that) {
case _ChatLocalConversationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatLocalConversationState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatLocalConversationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatConversation conversation,  List<ChatMessage> messages,  List<ChatConversation> existing,  int index,  DateTime now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatLocalConversationState() when $default != null:
return $default(_that.conversation,_that.messages,_that.existing,_that.index,_that.now);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatConversation conversation,  List<ChatMessage> messages,  List<ChatConversation> existing,  int index,  DateTime now)  $default,) {final _that = this;
switch (_that) {
case _ChatLocalConversationState():
return $default(_that.conversation,_that.messages,_that.existing,_that.index,_that.now);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatConversation conversation,  List<ChatMessage> messages,  List<ChatConversation> existing,  int index,  DateTime now)?  $default,) {final _that = this;
switch (_that) {
case _ChatLocalConversationState() when $default != null:
return $default(_that.conversation,_that.messages,_that.existing,_that.index,_that.now);case _:
  return null;

}
}

}

/// @nodoc


class _ChatLocalConversationState implements ChatLocalConversationState {
  const _ChatLocalConversationState({required this.conversation, required final  List<ChatMessage> messages, required final  List<ChatConversation> existing, required this.index, required this.now}): _messages = messages,_existing = existing;
  

@override final  ChatConversation conversation;
 final  List<ChatMessage> _messages;
@override List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<ChatConversation> _existing;
@override List<ChatConversation> get existing {
  if (_existing is EqualUnmodifiableListView) return _existing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_existing);
}

@override final  int index;
@override final  DateTime now;

/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatLocalConversationStateCopyWith<_ChatLocalConversationState> get copyWith => __$ChatLocalConversationStateCopyWithImpl<_ChatLocalConversationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatLocalConversationState&&(identical(other.conversation, conversation) || other.conversation == conversation)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._existing, _existing)&&(identical(other.index, index) || other.index == index)&&(identical(other.now, now) || other.now == now));
}


@override
int get hashCode => Object.hash(runtimeType,conversation,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_existing),index,now);

@override
String toString() {
  return 'ChatLocalConversationState(conversation: $conversation, messages: $messages, existing: $existing, index: $index, now: $now)';
}


}

/// @nodoc
abstract mixin class _$ChatLocalConversationStateCopyWith<$Res> implements $ChatLocalConversationStateCopyWith<$Res> {
  factory _$ChatLocalConversationStateCopyWith(_ChatLocalConversationState value, $Res Function(_ChatLocalConversationState) _then) = __$ChatLocalConversationStateCopyWithImpl;
@override @useResult
$Res call({
 ChatConversation conversation, List<ChatMessage> messages, List<ChatConversation> existing, int index, DateTime now
});


@override $ChatConversationCopyWith<$Res> get conversation;

}
/// @nodoc
class __$ChatLocalConversationStateCopyWithImpl<$Res>
    implements _$ChatLocalConversationStateCopyWith<$Res> {
  __$ChatLocalConversationStateCopyWithImpl(this._self, this._then);

  final _ChatLocalConversationState _self;
  final $Res Function(_ChatLocalConversationState) _then;

/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversation = null,Object? messages = null,Object? existing = null,Object? index = null,Object? now = null,}) {
  return _then(_ChatLocalConversationState(
conversation: null == conversation ? _self.conversation : conversation // ignore: cast_nullable_to_non_nullable
as ChatConversation,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,existing: null == existing ? _self._existing : existing // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ChatLocalConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<$Res> get conversation {
  
  return $ChatConversationCopyWith<$Res>(_self.conversation, (value) {
    return _then(_self.copyWith(conversation: value));
  });
}
}

// dart format on
