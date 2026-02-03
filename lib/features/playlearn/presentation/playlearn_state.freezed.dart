// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlearn_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaylearnState {

 List<TopicItem> get topics; String? get selectedTopicId; List<VocabularyItem> get words; bool get isLoading; String? get errorMessage;
/// Create a copy of PlaylearnState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylearnStateCopyWith<PlaylearnState> get copyWith => _$PlaylearnStateCopyWithImpl<PlaylearnState>(this as PlaylearnState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylearnState&&const DeepCollectionEquality().equals(other.topics, topics)&&(identical(other.selectedTopicId, selectedTopicId) || other.selectedTopicId == selectedTopicId)&&const DeepCollectionEquality().equals(other.words, words)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(topics),selectedTopicId,const DeepCollectionEquality().hash(words),isLoading,errorMessage);

@override
String toString() {
  return 'PlaylearnState(topics: $topics, selectedTopicId: $selectedTopicId, words: $words, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PlaylearnStateCopyWith<$Res>  {
  factory $PlaylearnStateCopyWith(PlaylearnState value, $Res Function(PlaylearnState) _then) = _$PlaylearnStateCopyWithImpl;
@useResult
$Res call({
 List<TopicItem> topics, String? selectedTopicId, List<VocabularyItem> words, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$PlaylearnStateCopyWithImpl<$Res>
    implements $PlaylearnStateCopyWith<$Res> {
  _$PlaylearnStateCopyWithImpl(this._self, this._then);

  final PlaylearnState _self;
  final $Res Function(PlaylearnState) _then;

/// Create a copy of PlaylearnState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topics = null,Object? selectedTopicId = freezed,Object? words = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
topics: null == topics ? _self.topics : topics // ignore: cast_nullable_to_non_nullable
as List<TopicItem>,selectedTopicId: freezed == selectedTopicId ? _self.selectedTopicId : selectedTopicId // ignore: cast_nullable_to_non_nullable
as String?,words: null == words ? _self.words : words // ignore: cast_nullable_to_non_nullable
as List<VocabularyItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylearnState].
extension PlaylearnStatePatterns on PlaylearnState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylearnState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylearnState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylearnState value)  $default,){
final _that = this;
switch (_that) {
case _PlaylearnState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylearnState value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylearnState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TopicItem> topics,  String? selectedTopicId,  List<VocabularyItem> words,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylearnState() when $default != null:
return $default(_that.topics,_that.selectedTopicId,_that.words,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TopicItem> topics,  String? selectedTopicId,  List<VocabularyItem> words,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PlaylearnState():
return $default(_that.topics,_that.selectedTopicId,_that.words,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TopicItem> topics,  String? selectedTopicId,  List<VocabularyItem> words,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PlaylearnState() when $default != null:
return $default(_that.topics,_that.selectedTopicId,_that.words,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PlaylearnState extends PlaylearnState {
  const _PlaylearnState({final  List<TopicItem> topics = const <TopicItem>[], this.selectedTopicId, final  List<VocabularyItem> words = const <VocabularyItem>[], this.isLoading = false, this.errorMessage}): _topics = topics,_words = words,super._();
  

 final  List<TopicItem> _topics;
@override@JsonKey() List<TopicItem> get topics {
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topics);
}

@override final  String? selectedTopicId;
 final  List<VocabularyItem> _words;
@override@JsonKey() List<VocabularyItem> get words {
  if (_words is EqualUnmodifiableListView) return _words;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_words);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of PlaylearnState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylearnStateCopyWith<_PlaylearnState> get copyWith => __$PlaylearnStateCopyWithImpl<_PlaylearnState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylearnState&&const DeepCollectionEquality().equals(other._topics, _topics)&&(identical(other.selectedTopicId, selectedTopicId) || other.selectedTopicId == selectedTopicId)&&const DeepCollectionEquality().equals(other._words, _words)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_topics),selectedTopicId,const DeepCollectionEquality().hash(_words),isLoading,errorMessage);

@override
String toString() {
  return 'PlaylearnState(topics: $topics, selectedTopicId: $selectedTopicId, words: $words, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PlaylearnStateCopyWith<$Res> implements $PlaylearnStateCopyWith<$Res> {
  factory _$PlaylearnStateCopyWith(_PlaylearnState value, $Res Function(_PlaylearnState) _then) = __$PlaylearnStateCopyWithImpl;
@override @useResult
$Res call({
 List<TopicItem> topics, String? selectedTopicId, List<VocabularyItem> words, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$PlaylearnStateCopyWithImpl<$Res>
    implements _$PlaylearnStateCopyWith<$Res> {
  __$PlaylearnStateCopyWithImpl(this._self, this._then);

  final _PlaylearnState _self;
  final $Res Function(_PlaylearnState) _then;

/// Create a copy of PlaylearnState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topics = null,Object? selectedTopicId = freezed,Object? words = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_PlaylearnState(
topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<TopicItem>,selectedTopicId: freezed == selectedTopicId ? _self.selectedTopicId : selectedTopicId // ignore: cast_nullable_to_non_nullable
as String?,words: null == words ? _self._words : words // ignore: cast_nullable_to_non_nullable
as List<VocabularyItem>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
