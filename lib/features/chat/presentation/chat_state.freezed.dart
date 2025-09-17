// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatState {

 List<ChatMessage> get messages; bool get isLoading; String? get error; List<String> get pastUserInputs; List<String> get generatedResponses; String? get currentModel; List<ChatConversation> get history; String? get activeConversationId;
/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatStateCopyWith<ChatState> get copyWith => _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatState&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.pastUserInputs, pastUserInputs)&&const DeepCollectionEquality().equals(other.generatedResponses, generatedResponses)&&(identical(other.currentModel, currentModel) || other.currentModel == currentModel)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.activeConversationId, activeConversationId) || other.activeConversationId == activeConversationId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),isLoading,error,const DeepCollectionEquality().hash(pastUserInputs),const DeepCollectionEquality().hash(generatedResponses),currentModel,const DeepCollectionEquality().hash(history),activeConversationId);

@override
String toString() {
  return 'ChatState(messages: $messages, isLoading: $isLoading, error: $error, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, currentModel: $currentModel, history: $history, activeConversationId: $activeConversationId)';
}


}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res>  {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) = _$ChatStateCopyWithImpl;
@useResult
$Res call({
 List<ChatMessage> messages, bool isLoading, String? error, List<String> pastUserInputs, List<String> generatedResponses, String? currentModel, List<ChatConversation> history, String? activeConversationId
});




}
/// @nodoc
class _$ChatStateCopyWithImpl<$Res>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? isLoading = null,Object? error = freezed,Object? pastUserInputs = null,Object? generatedResponses = null,Object? currentModel = freezed,Object? history = null,Object? activeConversationId = freezed,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,pastUserInputs: null == pastUserInputs ? _self.pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self.generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,currentModel: freezed == currentModel ? _self.currentModel : currentModel // ignore: cast_nullable_to_non_nullable
as String?,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,activeConversationId: freezed == activeConversationId ? _self.activeConversationId : activeConversationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatState value)  $default,){
final _that = this;
switch (_that) {
case _ChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatMessage> messages,  bool isLoading,  String? error,  List<String> pastUserInputs,  List<String> generatedResponses,  String? currentModel,  List<ChatConversation> history,  String? activeConversationId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.messages,_that.isLoading,_that.error,_that.pastUserInputs,_that.generatedResponses,_that.currentModel,_that.history,_that.activeConversationId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatMessage> messages,  bool isLoading,  String? error,  List<String> pastUserInputs,  List<String> generatedResponses,  String? currentModel,  List<ChatConversation> history,  String? activeConversationId)  $default,) {final _that = this;
switch (_that) {
case _ChatState():
return $default(_that.messages,_that.isLoading,_that.error,_that.pastUserInputs,_that.generatedResponses,_that.currentModel,_that.history,_that.activeConversationId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatMessage> messages,  bool isLoading,  String? error,  List<String> pastUserInputs,  List<String> generatedResponses,  String? currentModel,  List<ChatConversation> history,  String? activeConversationId)?  $default,) {final _that = this;
switch (_that) {
case _ChatState() when $default != null:
return $default(_that.messages,_that.isLoading,_that.error,_that.pastUserInputs,_that.generatedResponses,_that.currentModel,_that.history,_that.activeConversationId);case _:
  return null;

}
}

}

/// @nodoc


class _ChatState extends ChatState {
  const _ChatState({final  List<ChatMessage> messages = const <ChatMessage>[], this.isLoading = false, this.error, final  List<String> pastUserInputs = const <String>[], final  List<String> generatedResponses = const <String>[], this.currentModel, final  List<ChatConversation> history = const <ChatConversation>[], this.activeConversationId}): _messages = messages,_pastUserInputs = pastUserInputs,_generatedResponses = generatedResponses,_history = history,super._();
  

 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;
 final  List<String> _pastUserInputs;
@override@JsonKey() List<String> get pastUserInputs {
  if (_pastUserInputs is EqualUnmodifiableListView) return _pastUserInputs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pastUserInputs);
}

 final  List<String> _generatedResponses;
@override@JsonKey() List<String> get generatedResponses {
  if (_generatedResponses is EqualUnmodifiableListView) return _generatedResponses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_generatedResponses);
}

@override final  String? currentModel;
 final  List<ChatConversation> _history;
@override@JsonKey() List<ChatConversation> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  String? activeConversationId;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatStateCopyWith<_ChatState> get copyWith => __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatState&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._pastUserInputs, _pastUserInputs)&&const DeepCollectionEquality().equals(other._generatedResponses, _generatedResponses)&&(identical(other.currentModel, currentModel) || other.currentModel == currentModel)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.activeConversationId, activeConversationId) || other.activeConversationId == activeConversationId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),isLoading,error,const DeepCollectionEquality().hash(_pastUserInputs),const DeepCollectionEquality().hash(_generatedResponses),currentModel,const DeepCollectionEquality().hash(_history),activeConversationId);

@override
String toString() {
  return 'ChatState(messages: $messages, isLoading: $isLoading, error: $error, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, currentModel: $currentModel, history: $history, activeConversationId: $activeConversationId)';
}


}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res> implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(_ChatState value, $Res Function(_ChatState) _then) = __$ChatStateCopyWithImpl;
@override @useResult
$Res call({
 List<ChatMessage> messages, bool isLoading, String? error, List<String> pastUserInputs, List<String> generatedResponses, String? currentModel, List<ChatConversation> history, String? activeConversationId
});




}
/// @nodoc
class __$ChatStateCopyWithImpl<$Res>
    implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

/// Create a copy of ChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? isLoading = null,Object? error = freezed,Object? pastUserInputs = null,Object? generatedResponses = null,Object? currentModel = freezed,Object? history = null,Object? activeConversationId = freezed,}) {
  return _then(_ChatState(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,pastUserInputs: null == pastUserInputs ? _self._pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self._generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,currentModel: freezed == currentModel ? _self.currentModel : currentModel // ignore: cast_nullable_to_non_nullable
as String?,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<ChatConversation>,activeConversationId: freezed == activeConversationId ? _self.activeConversationId : activeConversationId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
