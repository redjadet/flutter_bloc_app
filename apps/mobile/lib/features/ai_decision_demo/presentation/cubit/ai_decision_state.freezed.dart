// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_decision_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiDecisionState {

 bool get isLoadingQueue; List<AiDecisionCaseSummary> get queue; String? get selectedCaseId; AiDecisionCaseDetail? get caseDetail; AiDecisionDecisionResult? get decision; String? get errorMessage; bool get isRunningDecision; bool get isSavingAction;
/// Create a copy of AiDecisionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiDecisionStateCopyWith<AiDecisionState> get copyWith => _$AiDecisionStateCopyWithImpl<AiDecisionState>(this as AiDecisionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiDecisionState&&(identical(other.isLoadingQueue, isLoadingQueue) || other.isLoadingQueue == isLoadingQueue)&&const DeepCollectionEquality().equals(other.queue, queue)&&(identical(other.selectedCaseId, selectedCaseId) || other.selectedCaseId == selectedCaseId)&&(identical(other.caseDetail, caseDetail) || other.caseDetail == caseDetail)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isRunningDecision, isRunningDecision) || other.isRunningDecision == isRunningDecision)&&(identical(other.isSavingAction, isSavingAction) || other.isSavingAction == isSavingAction));
}


@override
int get hashCode => Object.hash(runtimeType,isLoadingQueue,const DeepCollectionEquality().hash(queue),selectedCaseId,caseDetail,decision,errorMessage,isRunningDecision,isSavingAction);

@override
String toString() {
  return 'AiDecisionState(isLoadingQueue: $isLoadingQueue, queue: $queue, selectedCaseId: $selectedCaseId, caseDetail: $caseDetail, decision: $decision, errorMessage: $errorMessage, isRunningDecision: $isRunningDecision, isSavingAction: $isSavingAction)';
}


}

/// @nodoc
abstract mixin class $AiDecisionStateCopyWith<$Res>  {
  factory $AiDecisionStateCopyWith(AiDecisionState value, $Res Function(AiDecisionState) _then) = _$AiDecisionStateCopyWithImpl;
@useResult
$Res call({
 bool isLoadingQueue, List<AiDecisionCaseSummary> queue, String? selectedCaseId, AiDecisionCaseDetail? caseDetail, AiDecisionDecisionResult? decision, String? errorMessage, bool isRunningDecision, bool isSavingAction
});




}
/// @nodoc
class _$AiDecisionStateCopyWithImpl<$Res>
    implements $AiDecisionStateCopyWith<$Res> {
  _$AiDecisionStateCopyWithImpl(this._self, this._then);

  final AiDecisionState _self;
  final $Res Function(AiDecisionState) _then;

/// Create a copy of AiDecisionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoadingQueue = null,Object? queue = null,Object? selectedCaseId = freezed,Object? caseDetail = freezed,Object? decision = freezed,Object? errorMessage = freezed,Object? isRunningDecision = null,Object? isSavingAction = null,}) {
  return _then(_self.copyWith(
isLoadingQueue: null == isLoadingQueue ? _self.isLoadingQueue : isLoadingQueue // ignore: cast_nullable_to_non_nullable
as bool,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<AiDecisionCaseSummary>,selectedCaseId: freezed == selectedCaseId ? _self.selectedCaseId : selectedCaseId // ignore: cast_nullable_to_non_nullable
as String?,caseDetail: freezed == caseDetail ? _self.caseDetail : caseDetail // ignore: cast_nullable_to_non_nullable
as AiDecisionCaseDetail?,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as AiDecisionDecisionResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isRunningDecision: null == isRunningDecision ? _self.isRunningDecision : isRunningDecision // ignore: cast_nullable_to_non_nullable
as bool,isSavingAction: null == isSavingAction ? _self.isSavingAction : isSavingAction // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AiDecisionState].
extension AiDecisionStatePatterns on AiDecisionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiDecisionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiDecisionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiDecisionState value)  $default,){
final _that = this;
switch (_that) {
case _AiDecisionState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiDecisionState value)?  $default,){
final _that = this;
switch (_that) {
case _AiDecisionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoadingQueue,  List<AiDecisionCaseSummary> queue,  String? selectedCaseId,  AiDecisionCaseDetail? caseDetail,  AiDecisionDecisionResult? decision,  String? errorMessage,  bool isRunningDecision,  bool isSavingAction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiDecisionState() when $default != null:
return $default(_that.isLoadingQueue,_that.queue,_that.selectedCaseId,_that.caseDetail,_that.decision,_that.errorMessage,_that.isRunningDecision,_that.isSavingAction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoadingQueue,  List<AiDecisionCaseSummary> queue,  String? selectedCaseId,  AiDecisionCaseDetail? caseDetail,  AiDecisionDecisionResult? decision,  String? errorMessage,  bool isRunningDecision,  bool isSavingAction)  $default,) {final _that = this;
switch (_that) {
case _AiDecisionState():
return $default(_that.isLoadingQueue,_that.queue,_that.selectedCaseId,_that.caseDetail,_that.decision,_that.errorMessage,_that.isRunningDecision,_that.isSavingAction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoadingQueue,  List<AiDecisionCaseSummary> queue,  String? selectedCaseId,  AiDecisionCaseDetail? caseDetail,  AiDecisionDecisionResult? decision,  String? errorMessage,  bool isRunningDecision,  bool isSavingAction)?  $default,) {final _that = this;
switch (_that) {
case _AiDecisionState() when $default != null:
return $default(_that.isLoadingQueue,_that.queue,_that.selectedCaseId,_that.caseDetail,_that.decision,_that.errorMessage,_that.isRunningDecision,_that.isSavingAction);case _:
  return null;

}
}

}

/// @nodoc


class _AiDecisionState implements AiDecisionState {
  const _AiDecisionState({this.isLoadingQueue = true, final  List<AiDecisionCaseSummary> queue = const <AiDecisionCaseSummary>[], this.selectedCaseId, this.caseDetail, this.decision, this.errorMessage, this.isRunningDecision = false, this.isSavingAction = false}): _queue = queue;
  

@override@JsonKey() final  bool isLoadingQueue;
 final  List<AiDecisionCaseSummary> _queue;
@override@JsonKey() List<AiDecisionCaseSummary> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override final  String? selectedCaseId;
@override final  AiDecisionCaseDetail? caseDetail;
@override final  AiDecisionDecisionResult? decision;
@override final  String? errorMessage;
@override@JsonKey() final  bool isRunningDecision;
@override@JsonKey() final  bool isSavingAction;

/// Create a copy of AiDecisionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiDecisionStateCopyWith<_AiDecisionState> get copyWith => __$AiDecisionStateCopyWithImpl<_AiDecisionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiDecisionState&&(identical(other.isLoadingQueue, isLoadingQueue) || other.isLoadingQueue == isLoadingQueue)&&const DeepCollectionEquality().equals(other._queue, _queue)&&(identical(other.selectedCaseId, selectedCaseId) || other.selectedCaseId == selectedCaseId)&&(identical(other.caseDetail, caseDetail) || other.caseDetail == caseDetail)&&(identical(other.decision, decision) || other.decision == decision)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isRunningDecision, isRunningDecision) || other.isRunningDecision == isRunningDecision)&&(identical(other.isSavingAction, isSavingAction) || other.isSavingAction == isSavingAction));
}


@override
int get hashCode => Object.hash(runtimeType,isLoadingQueue,const DeepCollectionEquality().hash(_queue),selectedCaseId,caseDetail,decision,errorMessage,isRunningDecision,isSavingAction);

@override
String toString() {
  return 'AiDecisionState(isLoadingQueue: $isLoadingQueue, queue: $queue, selectedCaseId: $selectedCaseId, caseDetail: $caseDetail, decision: $decision, errorMessage: $errorMessage, isRunningDecision: $isRunningDecision, isSavingAction: $isSavingAction)';
}


}

/// @nodoc
abstract mixin class _$AiDecisionStateCopyWith<$Res> implements $AiDecisionStateCopyWith<$Res> {
  factory _$AiDecisionStateCopyWith(_AiDecisionState value, $Res Function(_AiDecisionState) _then) = __$AiDecisionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoadingQueue, List<AiDecisionCaseSummary> queue, String? selectedCaseId, AiDecisionCaseDetail? caseDetail, AiDecisionDecisionResult? decision, String? errorMessage, bool isRunningDecision, bool isSavingAction
});




}
/// @nodoc
class __$AiDecisionStateCopyWithImpl<$Res>
    implements _$AiDecisionStateCopyWith<$Res> {
  __$AiDecisionStateCopyWithImpl(this._self, this._then);

  final _AiDecisionState _self;
  final $Res Function(_AiDecisionState) _then;

/// Create a copy of AiDecisionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoadingQueue = null,Object? queue = null,Object? selectedCaseId = freezed,Object? caseDetail = freezed,Object? decision = freezed,Object? errorMessage = freezed,Object? isRunningDecision = null,Object? isSavingAction = null,}) {
  return _then(_AiDecisionState(
isLoadingQueue: null == isLoadingQueue ? _self.isLoadingQueue : isLoadingQueue // ignore: cast_nullable_to_non_nullable
as bool,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<AiDecisionCaseSummary>,selectedCaseId: freezed == selectedCaseId ? _self.selectedCaseId : selectedCaseId // ignore: cast_nullable_to_non_nullable
as String?,caseDetail: freezed == caseDetail ? _self.caseDetail : caseDetail // ignore: cast_nullable_to_non_nullable
as AiDecisionCaseDetail?,decision: freezed == decision ? _self.decision : decision // ignore: cast_nullable_to_non_nullable
as AiDecisionDecisionResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isRunningDecision: null == isRunningDecision ? _self.isRunningDecision : isRunningDecision // ignore: cast_nullable_to_non_nullable
as bool,isSavingAction: null == isSavingAction ? _self.isSavingAction : isSavingAction // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
