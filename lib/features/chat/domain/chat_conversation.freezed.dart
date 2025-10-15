// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatConversation implements DiagnosticableTreeMixin {

 String get id; List<ChatMessage> get messages; List<String> get pastUserInputs; List<String> get generatedResponses; DateTime get createdAt; DateTime get updatedAt; String? get model;
/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatConversationCopyWith<ChatConversation> get copyWith => _$ChatConversationCopyWithImpl<ChatConversation>(this as ChatConversation, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ChatConversation'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('messages', messages))..add(DiagnosticsProperty('pastUserInputs', pastUserInputs))..add(DiagnosticsProperty('generatedResponses', generatedResponses))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('model', model));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatConversation&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.pastUserInputs, pastUserInputs)&&const DeepCollectionEquality().equals(other.generatedResponses, generatedResponses)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(pastUserInputs),const DeepCollectionEquality().hash(generatedResponses),createdAt,updatedAt,model);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ChatConversation(id: $id, messages: $messages, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, createdAt: $createdAt, updatedAt: $updatedAt, model: $model)';
}


}

/// @nodoc
abstract mixin class $ChatConversationCopyWith<$Res>  {
  factory $ChatConversationCopyWith(ChatConversation value, $Res Function(ChatConversation) _then) = _$ChatConversationCopyWithImpl;
@useResult
$Res call({
 String id, List<ChatMessage> messages, List<String> pastUserInputs, List<String> generatedResponses, DateTime createdAt, DateTime updatedAt, String? model
});




}
/// @nodoc
class _$ChatConversationCopyWithImpl<$Res>
    implements $ChatConversationCopyWith<$Res> {
  _$ChatConversationCopyWithImpl(this._self, this._then);

  final ChatConversation _self;
  final $Res Function(ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messages = null,Object? pastUserInputs = null,Object? generatedResponses = null,Object? createdAt = null,Object? updatedAt = null,Object? model = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,pastUserInputs: null == pastUserInputs ? _self.pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self.generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatConversation].
extension ChatConversationPatterns on ChatConversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatConversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatConversation value)  $default,){
final _that = this;
switch (_that) {
case _ChatConversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatConversation value)?  $default,){
final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<ChatMessage> messages,  List<String> pastUserInputs,  List<String> generatedResponses,  DateTime createdAt,  DateTime updatedAt,  String? model)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.id,_that.messages,_that.pastUserInputs,_that.generatedResponses,_that.createdAt,_that.updatedAt,_that.model);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<ChatMessage> messages,  List<String> pastUserInputs,  List<String> generatedResponses,  DateTime createdAt,  DateTime updatedAt,  String? model)  $default,) {final _that = this;
switch (_that) {
case _ChatConversation():
return $default(_that.id,_that.messages,_that.pastUserInputs,_that.generatedResponses,_that.createdAt,_that.updatedAt,_that.model);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<ChatMessage> messages,  List<String> pastUserInputs,  List<String> generatedResponses,  DateTime createdAt,  DateTime updatedAt,  String? model)?  $default,) {final _that = this;
switch (_that) {
case _ChatConversation() when $default != null:
return $default(_that.id,_that.messages,_that.pastUserInputs,_that.generatedResponses,_that.createdAt,_that.updatedAt,_that.model);case _:
  return null;

}
}

}

/// @nodoc


class _ChatConversation extends ChatConversation with DiagnosticableTreeMixin {
  const _ChatConversation({required this.id, final  List<ChatMessage> messages = const <ChatMessage>[], final  List<String> pastUserInputs = const <String>[], final  List<String> generatedResponses = const <String>[], required this.createdAt, required this.updatedAt, this.model}): _messages = messages,_pastUserInputs = pastUserInputs,_generatedResponses = generatedResponses,super._();
  

@override final  String id;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

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

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? model;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatConversationCopyWith<_ChatConversation> get copyWith => __$ChatConversationCopyWithImpl<_ChatConversation>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ChatConversation'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('messages', messages))..add(DiagnosticsProperty('pastUserInputs', pastUserInputs))..add(DiagnosticsProperty('generatedResponses', generatedResponses))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('model', model));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatConversation&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._pastUserInputs, _pastUserInputs)&&const DeepCollectionEquality().equals(other._generatedResponses, _generatedResponses)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.model, model) || other.model == model));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_pastUserInputs),const DeepCollectionEquality().hash(_generatedResponses),createdAt,updatedAt,model);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ChatConversation(id: $id, messages: $messages, pastUserInputs: $pastUserInputs, generatedResponses: $generatedResponses, createdAt: $createdAt, updatedAt: $updatedAt, model: $model)';
}


}

/// @nodoc
abstract mixin class _$ChatConversationCopyWith<$Res> implements $ChatConversationCopyWith<$Res> {
  factory _$ChatConversationCopyWith(_ChatConversation value, $Res Function(_ChatConversation) _then) = __$ChatConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, List<ChatMessage> messages, List<String> pastUserInputs, List<String> generatedResponses, DateTime createdAt, DateTime updatedAt, String? model
});




}
/// @nodoc
class __$ChatConversationCopyWithImpl<$Res>
    implements _$ChatConversationCopyWith<$Res> {
  __$ChatConversationCopyWithImpl(this._self, this._then);

  final _ChatConversation _self;
  final $Res Function(_ChatConversation) _then;

/// Create a copy of ChatConversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messages = null,Object? pastUserInputs = null,Object? generatedResponses = null,Object? createdAt = null,Object? updatedAt = null,Object? model = freezed,}) {
  return _then(_ChatConversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,pastUserInputs: null == pastUserInputs ? _self._pastUserInputs : pastUserInputs // ignore: cast_nullable_to_non_nullable
as List<String>,generatedResponses: null == generatedResponses ? _self._generatedResponses : generatedResponses // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
