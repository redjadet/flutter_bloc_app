// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SocialFeedRefreshStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedRefreshStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedRefreshStatus()';
}


}

/// @nodoc
class $SocialFeedRefreshStatusCopyWith<$Res>  {
$SocialFeedRefreshStatusCopyWith(SocialFeedRefreshStatus _, $Res Function(SocialFeedRefreshStatus) __);
}


/// Adds pattern-matching-related methods to [SocialFeedRefreshStatus].
extension SocialFeedRefreshStatusPatterns on SocialFeedRefreshStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocialFeedRefreshIdle value)?  idle,TResult Function( SocialFeedRefreshLoading value)?  loading,TResult Function( SocialFeedRefreshFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocialFeedRefreshIdle() when idle != null:
return idle(_that);case SocialFeedRefreshLoading() when loading != null:
return loading(_that);case SocialFeedRefreshFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocialFeedRefreshIdle value)  idle,required TResult Function( SocialFeedRefreshLoading value)  loading,required TResult Function( SocialFeedRefreshFailure value)  failure,}){
final _that = this;
switch (_that) {
case SocialFeedRefreshIdle():
return idle(_that);case SocialFeedRefreshLoading():
return loading(_that);case SocialFeedRefreshFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocialFeedRefreshIdle value)?  idle,TResult? Function( SocialFeedRefreshLoading value)?  loading,TResult? Function( SocialFeedRefreshFailure value)?  failure,}){
final _that = this;
switch (_that) {
case SocialFeedRefreshIdle() when idle != null:
return idle(_that);case SocialFeedRefreshLoading() when loading != null:
return loading(_that);case SocialFeedRefreshFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( SocialFeedFailure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocialFeedRefreshIdle() when idle != null:
return idle();case SocialFeedRefreshLoading() when loading != null:
return loading();case SocialFeedRefreshFailure() when failure != null:
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( SocialFeedFailure failure)  failure,}) {final _that = this;
switch (_that) {
case SocialFeedRefreshIdle():
return idle();case SocialFeedRefreshLoading():
return loading();case SocialFeedRefreshFailure():
return failure(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( SocialFeedFailure failure)?  failure,}) {final _that = this;
switch (_that) {
case SocialFeedRefreshIdle() when idle != null:
return idle();case SocialFeedRefreshLoading() when loading != null:
return loading();case SocialFeedRefreshFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SocialFeedRefreshIdle implements SocialFeedRefreshStatus {
  const SocialFeedRefreshIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedRefreshIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedRefreshStatus.idle()';
}


}




/// @nodoc


class SocialFeedRefreshLoading implements SocialFeedRefreshStatus {
  const SocialFeedRefreshLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedRefreshLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedRefreshStatus.loading()';
}


}




/// @nodoc


class SocialFeedRefreshFailure implements SocialFeedRefreshStatus {
  const SocialFeedRefreshFailure(this.failure);
  

 final  SocialFeedFailure failure;

/// Create a copy of SocialFeedRefreshStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedRefreshFailureCopyWith<SocialFeedRefreshFailure> get copyWith => _$SocialFeedRefreshFailureCopyWithImpl<SocialFeedRefreshFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedRefreshFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SocialFeedRefreshStatus.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SocialFeedRefreshFailureCopyWith<$Res> implements $SocialFeedRefreshStatusCopyWith<$Res> {
  factory $SocialFeedRefreshFailureCopyWith(SocialFeedRefreshFailure value, $Res Function(SocialFeedRefreshFailure) _then) = _$SocialFeedRefreshFailureCopyWithImpl;
@useResult
$Res call({
 SocialFeedFailure failure
});




}
/// @nodoc
class _$SocialFeedRefreshFailureCopyWithImpl<$Res>
    implements $SocialFeedRefreshFailureCopyWith<$Res> {
  _$SocialFeedRefreshFailureCopyWithImpl(this._self, this._then);

  final SocialFeedRefreshFailure _self;
  final $Res Function(SocialFeedRefreshFailure) _then;

/// Create a copy of SocialFeedRefreshStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SocialFeedRefreshFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SocialFeedFailure,
  ));
}


}

/// @nodoc
mixin _$SocialFeedPageStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedPageStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedPageStatus()';
}


}

/// @nodoc
class $SocialFeedPageStatusCopyWith<$Res>  {
$SocialFeedPageStatusCopyWith(SocialFeedPageStatus _, $Res Function(SocialFeedPageStatus) __);
}


/// Adds pattern-matching-related methods to [SocialFeedPageStatus].
extension SocialFeedPageStatusPatterns on SocialFeedPageStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocialFeedPageIdle value)?  idle,TResult Function( SocialFeedPageLoading value)?  loading,TResult Function( SocialFeedPageFailureStatus value)?  failure,TResult Function( SocialFeedPageExhausted value)?  exhausted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocialFeedPageIdle() when idle != null:
return idle(_that);case SocialFeedPageLoading() when loading != null:
return loading(_that);case SocialFeedPageFailureStatus() when failure != null:
return failure(_that);case SocialFeedPageExhausted() when exhausted != null:
return exhausted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocialFeedPageIdle value)  idle,required TResult Function( SocialFeedPageLoading value)  loading,required TResult Function( SocialFeedPageFailureStatus value)  failure,required TResult Function( SocialFeedPageExhausted value)  exhausted,}){
final _that = this;
switch (_that) {
case SocialFeedPageIdle():
return idle(_that);case SocialFeedPageLoading():
return loading(_that);case SocialFeedPageFailureStatus():
return failure(_that);case SocialFeedPageExhausted():
return exhausted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocialFeedPageIdle value)?  idle,TResult? Function( SocialFeedPageLoading value)?  loading,TResult? Function( SocialFeedPageFailureStatus value)?  failure,TResult? Function( SocialFeedPageExhausted value)?  exhausted,}){
final _that = this;
switch (_that) {
case SocialFeedPageIdle() when idle != null:
return idle(_that);case SocialFeedPageLoading() when loading != null:
return loading(_that);case SocialFeedPageFailureStatus() when failure != null:
return failure(_that);case SocialFeedPageExhausted() when exhausted != null:
return exhausted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( SocialFeedFailure failure)?  failure,TResult Function()?  exhausted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocialFeedPageIdle() when idle != null:
return idle();case SocialFeedPageLoading() when loading != null:
return loading();case SocialFeedPageFailureStatus() when failure != null:
return failure(_that.failure);case SocialFeedPageExhausted() when exhausted != null:
return exhausted();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( SocialFeedFailure failure)  failure,required TResult Function()  exhausted,}) {final _that = this;
switch (_that) {
case SocialFeedPageIdle():
return idle();case SocialFeedPageLoading():
return loading();case SocialFeedPageFailureStatus():
return failure(_that.failure);case SocialFeedPageExhausted():
return exhausted();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( SocialFeedFailure failure)?  failure,TResult? Function()?  exhausted,}) {final _that = this;
switch (_that) {
case SocialFeedPageIdle() when idle != null:
return idle();case SocialFeedPageLoading() when loading != null:
return loading();case SocialFeedPageFailureStatus() when failure != null:
return failure(_that.failure);case SocialFeedPageExhausted() when exhausted != null:
return exhausted();case _:
  return null;

}
}

}

/// @nodoc


class SocialFeedPageIdle implements SocialFeedPageStatus {
  const SocialFeedPageIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedPageIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedPageStatus.idle()';
}


}




/// @nodoc


class SocialFeedPageLoading implements SocialFeedPageStatus {
  const SocialFeedPageLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedPageLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedPageStatus.loading()';
}


}




/// @nodoc


class SocialFeedPageFailureStatus implements SocialFeedPageStatus {
  const SocialFeedPageFailureStatus(this.failure);
  

 final  SocialFeedFailure failure;

/// Create a copy of SocialFeedPageStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedPageFailureStatusCopyWith<SocialFeedPageFailureStatus> get copyWith => _$SocialFeedPageFailureStatusCopyWithImpl<SocialFeedPageFailureStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedPageFailureStatus&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SocialFeedPageStatus.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SocialFeedPageFailureStatusCopyWith<$Res> implements $SocialFeedPageStatusCopyWith<$Res> {
  factory $SocialFeedPageFailureStatusCopyWith(SocialFeedPageFailureStatus value, $Res Function(SocialFeedPageFailureStatus) _then) = _$SocialFeedPageFailureStatusCopyWithImpl;
@useResult
$Res call({
 SocialFeedFailure failure
});




}
/// @nodoc
class _$SocialFeedPageFailureStatusCopyWithImpl<$Res>
    implements $SocialFeedPageFailureStatusCopyWith<$Res> {
  _$SocialFeedPageFailureStatusCopyWithImpl(this._self, this._then);

  final SocialFeedPageFailureStatus _self;
  final $Res Function(SocialFeedPageFailureStatus) _then;

/// Create a copy of SocialFeedPageStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SocialFeedPageFailureStatus(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SocialFeedFailure,
  ));
}


}

/// @nodoc


class SocialFeedPageExhausted implements SocialFeedPageStatus {
  const SocialFeedPageExhausted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedPageExhausted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedPageStatus.exhausted()';
}


}




/// @nodoc
mixin _$SocialFeedEffect {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedEffect);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedEffect()';
}


}

/// @nodoc
class $SocialFeedEffectCopyWith<$Res>  {
$SocialFeedEffectCopyWith(SocialFeedEffect _, $Res Function(SocialFeedEffect) __);
}


/// Adds pattern-matching-related methods to [SocialFeedEffect].
extension SocialFeedEffectPatterns on SocialFeedEffect {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocialFeedMutationRejectedEffect value)?  mutationRejected,TResult Function( SocialFeedAnnouncementEffect value)?  announcement,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect() when mutationRejected != null:
return mutationRejected(_that);case SocialFeedAnnouncementEffect() when announcement != null:
return announcement(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocialFeedMutationRejectedEffect value)  mutationRejected,required TResult Function( SocialFeedAnnouncementEffect value)  announcement,}){
final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect():
return mutationRejected(_that);case SocialFeedAnnouncementEffect():
return announcement(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocialFeedMutationRejectedEffect value)?  mutationRejected,TResult? Function( SocialFeedAnnouncementEffect value)?  announcement,}){
final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect() when mutationRejected != null:
return mutationRejected(_that);case SocialFeedAnnouncementEffect() when announcement != null:
return announcement(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  mutationRejected,TResult Function( String code)?  announcement,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect() when mutationRejected != null:
return mutationRejected();case SocialFeedAnnouncementEffect() when announcement != null:
return announcement(_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  mutationRejected,required TResult Function( String code)  announcement,}) {final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect():
return mutationRejected();case SocialFeedAnnouncementEffect():
return announcement(_that.code);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  mutationRejected,TResult? Function( String code)?  announcement,}) {final _that = this;
switch (_that) {
case SocialFeedMutationRejectedEffect() when mutationRejected != null:
return mutationRejected();case SocialFeedAnnouncementEffect() when announcement != null:
return announcement(_that.code);case _:
  return null;

}
}

}

/// @nodoc


class SocialFeedMutationRejectedEffect implements SocialFeedEffect {
  const SocialFeedMutationRejectedEffect();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedMutationRejectedEffect);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedEffect.mutationRejected()';
}


}




/// @nodoc


class SocialFeedAnnouncementEffect implements SocialFeedEffect {
  const SocialFeedAnnouncementEffect(this.code);
  

 final  String code;

/// Create a copy of SocialFeedEffect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedAnnouncementEffectCopyWith<SocialFeedAnnouncementEffect> get copyWith => _$SocialFeedAnnouncementEffectCopyWithImpl<SocialFeedAnnouncementEffect>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedAnnouncementEffect&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'SocialFeedEffect.announcement(code: $code)';
}


}

/// @nodoc
abstract mixin class $SocialFeedAnnouncementEffectCopyWith<$Res> implements $SocialFeedEffectCopyWith<$Res> {
  factory $SocialFeedAnnouncementEffectCopyWith(SocialFeedAnnouncementEffect value, $Res Function(SocialFeedAnnouncementEffect) _then) = _$SocialFeedAnnouncementEffectCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$SocialFeedAnnouncementEffectCopyWithImpl<$Res>
    implements $SocialFeedAnnouncementEffectCopyWith<$Res> {
  _$SocialFeedAnnouncementEffectCopyWithImpl(this._self, this._then);

  final SocialFeedAnnouncementEffect _self;
  final $Res Function(SocialFeedAnnouncementEffect) _then;

/// Create a copy of SocialFeedEffect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(SocialFeedAnnouncementEffect(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SocialFeedReadyData {

 SocialFeedViewer get viewer; List<SocialFeedPost> get posts; String? get nextCursor; SocialFeedRefreshStatus get refreshStatus; SocialFeedPageStatus get pageStatus; bool get isShowingCachedData; Duration get cacheAge; SocialFeedConnectionStatus get connectionStatus; bool get isSimulatedOffline; List<SocialFeedPost> get bufferedRealtimePosts; int get pendingMutationCount; int get needsAttentionCount; Set<String> get pendingPostIds;/// postId → mutationId for manual retry of dead-lettered ops.
 Map<String, String> get needsAttentionByPostId; Map<String, List<SocialFeedComment>> get pendingCommentsByPostId;/// Shared seed + synced comment threads (survives viewer switch).
 Map<String, List<SocialFeedComment>> get commentsByPostId; SocialFeedEffect? get effect; int get effectId;
/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedReadyDataCopyWith<SocialFeedReadyData> get copyWith => _$SocialFeedReadyDataCopyWithImpl<SocialFeedReadyData>(this as SocialFeedReadyData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedReadyData&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.refreshStatus, refreshStatus) || other.refreshStatus == refreshStatus)&&(identical(other.pageStatus, pageStatus) || other.pageStatus == pageStatus)&&(identical(other.isShowingCachedData, isShowingCachedData) || other.isShowingCachedData == isShowingCachedData)&&(identical(other.cacheAge, cacheAge) || other.cacheAge == cacheAge)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.isSimulatedOffline, isSimulatedOffline) || other.isSimulatedOffline == isSimulatedOffline)&&const DeepCollectionEquality().equals(other.bufferedRealtimePosts, bufferedRealtimePosts)&&(identical(other.pendingMutationCount, pendingMutationCount) || other.pendingMutationCount == pendingMutationCount)&&(identical(other.needsAttentionCount, needsAttentionCount) || other.needsAttentionCount == needsAttentionCount)&&const DeepCollectionEquality().equals(other.pendingPostIds, pendingPostIds)&&const DeepCollectionEquality().equals(other.needsAttentionByPostId, needsAttentionByPostId)&&const DeepCollectionEquality().equals(other.pendingCommentsByPostId, pendingCommentsByPostId)&&const DeepCollectionEquality().equals(other.commentsByPostId, commentsByPostId)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.effectId, effectId) || other.effectId == effectId));
}


@override
int get hashCode => Object.hash(runtimeType,viewer,const DeepCollectionEquality().hash(posts),nextCursor,refreshStatus,pageStatus,isShowingCachedData,cacheAge,connectionStatus,isSimulatedOffline,const DeepCollectionEquality().hash(bufferedRealtimePosts),pendingMutationCount,needsAttentionCount,const DeepCollectionEquality().hash(pendingPostIds),const DeepCollectionEquality().hash(needsAttentionByPostId),const DeepCollectionEquality().hash(pendingCommentsByPostId),const DeepCollectionEquality().hash(commentsByPostId),effect,effectId);

@override
String toString() {
  return 'SocialFeedReadyData(viewer: $viewer, posts: $posts, nextCursor: $nextCursor, refreshStatus: $refreshStatus, pageStatus: $pageStatus, isShowingCachedData: $isShowingCachedData, cacheAge: $cacheAge, connectionStatus: $connectionStatus, isSimulatedOffline: $isSimulatedOffline, bufferedRealtimePosts: $bufferedRealtimePosts, pendingMutationCount: $pendingMutationCount, needsAttentionCount: $needsAttentionCount, pendingPostIds: $pendingPostIds, needsAttentionByPostId: $needsAttentionByPostId, pendingCommentsByPostId: $pendingCommentsByPostId, commentsByPostId: $commentsByPostId, effect: $effect, effectId: $effectId)';
}


}

/// @nodoc
abstract mixin class $SocialFeedReadyDataCopyWith<$Res>  {
  factory $SocialFeedReadyDataCopyWith(SocialFeedReadyData value, $Res Function(SocialFeedReadyData) _then) = _$SocialFeedReadyDataCopyWithImpl;
@useResult
$Res call({
 SocialFeedViewer viewer, List<SocialFeedPost> posts, String? nextCursor, SocialFeedRefreshStatus refreshStatus, SocialFeedPageStatus pageStatus, bool isShowingCachedData, Duration cacheAge, SocialFeedConnectionStatus connectionStatus, bool isSimulatedOffline, List<SocialFeedPost> bufferedRealtimePosts, int pendingMutationCount, int needsAttentionCount, Set<String> pendingPostIds, Map<String, String> needsAttentionByPostId, Map<String, List<SocialFeedComment>> pendingCommentsByPostId, Map<String, List<SocialFeedComment>> commentsByPostId, SocialFeedEffect? effect, int effectId
});


$SocialFeedRefreshStatusCopyWith<$Res> get refreshStatus;$SocialFeedPageStatusCopyWith<$Res> get pageStatus;$SocialFeedEffectCopyWith<$Res>? get effect;

}
/// @nodoc
class _$SocialFeedReadyDataCopyWithImpl<$Res>
    implements $SocialFeedReadyDataCopyWith<$Res> {
  _$SocialFeedReadyDataCopyWithImpl(this._self, this._then);

  final SocialFeedReadyData _self;
  final $Res Function(SocialFeedReadyData) _then;

/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? viewer = null,Object? posts = null,Object? nextCursor = freezed,Object? refreshStatus = null,Object? pageStatus = null,Object? isShowingCachedData = null,Object? cacheAge = null,Object? connectionStatus = null,Object? isSimulatedOffline = null,Object? bufferedRealtimePosts = null,Object? pendingMutationCount = null,Object? needsAttentionCount = null,Object? pendingPostIds = null,Object? needsAttentionByPostId = null,Object? pendingCommentsByPostId = null,Object? commentsByPostId = null,Object? effect = freezed,Object? effectId = null,}) {
  return _then(_self.copyWith(
viewer: null == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as SocialFeedViewer,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<SocialFeedPost>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,refreshStatus: null == refreshStatus ? _self.refreshStatus : refreshStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedRefreshStatus,pageStatus: null == pageStatus ? _self.pageStatus : pageStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedPageStatus,isShowingCachedData: null == isShowingCachedData ? _self.isShowingCachedData : isShowingCachedData // ignore: cast_nullable_to_non_nullable
as bool,cacheAge: null == cacheAge ? _self.cacheAge : cacheAge // ignore: cast_nullable_to_non_nullable
as Duration,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedConnectionStatus,isSimulatedOffline: null == isSimulatedOffline ? _self.isSimulatedOffline : isSimulatedOffline // ignore: cast_nullable_to_non_nullable
as bool,bufferedRealtimePosts: null == bufferedRealtimePosts ? _self.bufferedRealtimePosts : bufferedRealtimePosts // ignore: cast_nullable_to_non_nullable
as List<SocialFeedPost>,pendingMutationCount: null == pendingMutationCount ? _self.pendingMutationCount : pendingMutationCount // ignore: cast_nullable_to_non_nullable
as int,needsAttentionCount: null == needsAttentionCount ? _self.needsAttentionCount : needsAttentionCount // ignore: cast_nullable_to_non_nullable
as int,pendingPostIds: null == pendingPostIds ? _self.pendingPostIds : pendingPostIds // ignore: cast_nullable_to_non_nullable
as Set<String>,needsAttentionByPostId: null == needsAttentionByPostId ? _self.needsAttentionByPostId : needsAttentionByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, String>,pendingCommentsByPostId: null == pendingCommentsByPostId ? _self.pendingCommentsByPostId : pendingCommentsByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, List<SocialFeedComment>>,commentsByPostId: null == commentsByPostId ? _self.commentsByPostId : commentsByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, List<SocialFeedComment>>,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as SocialFeedEffect?,effectId: null == effectId ? _self.effectId : effectId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedRefreshStatusCopyWith<$Res> get refreshStatus {
  
  return $SocialFeedRefreshStatusCopyWith<$Res>(_self.refreshStatus, (value) {
    return _then(_self.copyWith(refreshStatus: value));
  });
}/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedPageStatusCopyWith<$Res> get pageStatus {
  
  return $SocialFeedPageStatusCopyWith<$Res>(_self.pageStatus, (value) {
    return _then(_self.copyWith(pageStatus: value));
  });
}/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedEffectCopyWith<$Res>? get effect {
    if (_self.effect == null) {
    return null;
  }

  return $SocialFeedEffectCopyWith<$Res>(_self.effect!, (value) {
    return _then(_self.copyWith(effect: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialFeedReadyData].
extension SocialFeedReadyDataPatterns on SocialFeedReadyData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialFeedReadyData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialFeedReadyData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialFeedReadyData value)  $default,){
final _that = this;
switch (_that) {
case _SocialFeedReadyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialFeedReadyData value)?  $default,){
final _that = this;
switch (_that) {
case _SocialFeedReadyData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SocialFeedViewer viewer,  List<SocialFeedPost> posts,  String? nextCursor,  SocialFeedRefreshStatus refreshStatus,  SocialFeedPageStatus pageStatus,  bool isShowingCachedData,  Duration cacheAge,  SocialFeedConnectionStatus connectionStatus,  bool isSimulatedOffline,  List<SocialFeedPost> bufferedRealtimePosts,  int pendingMutationCount,  int needsAttentionCount,  Set<String> pendingPostIds,  Map<String, String> needsAttentionByPostId,  Map<String, List<SocialFeedComment>> pendingCommentsByPostId,  Map<String, List<SocialFeedComment>> commentsByPostId,  SocialFeedEffect? effect,  int effectId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialFeedReadyData() when $default != null:
return $default(_that.viewer,_that.posts,_that.nextCursor,_that.refreshStatus,_that.pageStatus,_that.isShowingCachedData,_that.cacheAge,_that.connectionStatus,_that.isSimulatedOffline,_that.bufferedRealtimePosts,_that.pendingMutationCount,_that.needsAttentionCount,_that.pendingPostIds,_that.needsAttentionByPostId,_that.pendingCommentsByPostId,_that.commentsByPostId,_that.effect,_that.effectId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SocialFeedViewer viewer,  List<SocialFeedPost> posts,  String? nextCursor,  SocialFeedRefreshStatus refreshStatus,  SocialFeedPageStatus pageStatus,  bool isShowingCachedData,  Duration cacheAge,  SocialFeedConnectionStatus connectionStatus,  bool isSimulatedOffline,  List<SocialFeedPost> bufferedRealtimePosts,  int pendingMutationCount,  int needsAttentionCount,  Set<String> pendingPostIds,  Map<String, String> needsAttentionByPostId,  Map<String, List<SocialFeedComment>> pendingCommentsByPostId,  Map<String, List<SocialFeedComment>> commentsByPostId,  SocialFeedEffect? effect,  int effectId)  $default,) {final _that = this;
switch (_that) {
case _SocialFeedReadyData():
return $default(_that.viewer,_that.posts,_that.nextCursor,_that.refreshStatus,_that.pageStatus,_that.isShowingCachedData,_that.cacheAge,_that.connectionStatus,_that.isSimulatedOffline,_that.bufferedRealtimePosts,_that.pendingMutationCount,_that.needsAttentionCount,_that.pendingPostIds,_that.needsAttentionByPostId,_that.pendingCommentsByPostId,_that.commentsByPostId,_that.effect,_that.effectId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SocialFeedViewer viewer,  List<SocialFeedPost> posts,  String? nextCursor,  SocialFeedRefreshStatus refreshStatus,  SocialFeedPageStatus pageStatus,  bool isShowingCachedData,  Duration cacheAge,  SocialFeedConnectionStatus connectionStatus,  bool isSimulatedOffline,  List<SocialFeedPost> bufferedRealtimePosts,  int pendingMutationCount,  int needsAttentionCount,  Set<String> pendingPostIds,  Map<String, String> needsAttentionByPostId,  Map<String, List<SocialFeedComment>> pendingCommentsByPostId,  Map<String, List<SocialFeedComment>> commentsByPostId,  SocialFeedEffect? effect,  int effectId)?  $default,) {final _that = this;
switch (_that) {
case _SocialFeedReadyData() when $default != null:
return $default(_that.viewer,_that.posts,_that.nextCursor,_that.refreshStatus,_that.pageStatus,_that.isShowingCachedData,_that.cacheAge,_that.connectionStatus,_that.isSimulatedOffline,_that.bufferedRealtimePosts,_that.pendingMutationCount,_that.needsAttentionCount,_that.pendingPostIds,_that.needsAttentionByPostId,_that.pendingCommentsByPostId,_that.commentsByPostId,_that.effect,_that.effectId);case _:
  return null;

}
}

}

/// @nodoc


class _SocialFeedReadyData extends SocialFeedReadyData {
  const _SocialFeedReadyData({required this.viewer, required List<SocialFeedPost> posts, required this.nextCursor, required this.refreshStatus, required this.pageStatus, required this.isShowingCachedData, required this.cacheAge, required this.connectionStatus, required this.isSimulatedOffline, required List<SocialFeedPost> bufferedRealtimePosts, required this.pendingMutationCount, required this.needsAttentionCount, required Set<String> pendingPostIds, required Map<String, String> needsAttentionByPostId, required Map<String, List<SocialFeedComment>> pendingCommentsByPostId, Map<String, List<SocialFeedComment>> commentsByPostId = const <String, List<SocialFeedComment>>{}, this.effect, this.effectId = 0}): _posts = posts,_bufferedRealtimePosts = bufferedRealtimePosts,_pendingPostIds = pendingPostIds,_needsAttentionByPostId = needsAttentionByPostId,_pendingCommentsByPostId = pendingCommentsByPostId,_commentsByPostId = commentsByPostId,super._();
  

@override final  SocialFeedViewer viewer;
 final  List<SocialFeedPost> _posts;
@override List<SocialFeedPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override final  String? nextCursor;
@override final  SocialFeedRefreshStatus refreshStatus;
@override final  SocialFeedPageStatus pageStatus;
@override final  bool isShowingCachedData;
@override final  Duration cacheAge;
@override final  SocialFeedConnectionStatus connectionStatus;
@override final  bool isSimulatedOffline;
 final  List<SocialFeedPost> _bufferedRealtimePosts;
@override List<SocialFeedPost> get bufferedRealtimePosts {
  if (_bufferedRealtimePosts is EqualUnmodifiableListView) return _bufferedRealtimePosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bufferedRealtimePosts);
}

@override final  int pendingMutationCount;
@override final  int needsAttentionCount;
 final  Set<String> _pendingPostIds;
@override Set<String> get pendingPostIds {
  if (_pendingPostIds is EqualUnmodifiableSetView) return _pendingPostIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_pendingPostIds);
}

/// postId → mutationId for manual retry of dead-lettered ops.
 final  Map<String, String> _needsAttentionByPostId;
/// postId → mutationId for manual retry of dead-lettered ops.
@override Map<String, String> get needsAttentionByPostId {
  if (_needsAttentionByPostId is EqualUnmodifiableMapView) return _needsAttentionByPostId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_needsAttentionByPostId);
}

 final  Map<String, List<SocialFeedComment>> _pendingCommentsByPostId;
@override Map<String, List<SocialFeedComment>> get pendingCommentsByPostId {
  if (_pendingCommentsByPostId is EqualUnmodifiableMapView) return _pendingCommentsByPostId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pendingCommentsByPostId);
}

/// Shared seed + synced comment threads (survives viewer switch).
 final  Map<String, List<SocialFeedComment>> _commentsByPostId;
/// Shared seed + synced comment threads (survives viewer switch).
@override@JsonKey() Map<String, List<SocialFeedComment>> get commentsByPostId {
  if (_commentsByPostId is EqualUnmodifiableMapView) return _commentsByPostId;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_commentsByPostId);
}

@override final  SocialFeedEffect? effect;
@override@JsonKey() final  int effectId;

/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialFeedReadyDataCopyWith<_SocialFeedReadyData> get copyWith => __$SocialFeedReadyDataCopyWithImpl<_SocialFeedReadyData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialFeedReadyData&&(identical(other.viewer, viewer) || other.viewer == viewer)&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.refreshStatus, refreshStatus) || other.refreshStatus == refreshStatus)&&(identical(other.pageStatus, pageStatus) || other.pageStatus == pageStatus)&&(identical(other.isShowingCachedData, isShowingCachedData) || other.isShowingCachedData == isShowingCachedData)&&(identical(other.cacheAge, cacheAge) || other.cacheAge == cacheAge)&&(identical(other.connectionStatus, connectionStatus) || other.connectionStatus == connectionStatus)&&(identical(other.isSimulatedOffline, isSimulatedOffline) || other.isSimulatedOffline == isSimulatedOffline)&&const DeepCollectionEquality().equals(other._bufferedRealtimePosts, _bufferedRealtimePosts)&&(identical(other.pendingMutationCount, pendingMutationCount) || other.pendingMutationCount == pendingMutationCount)&&(identical(other.needsAttentionCount, needsAttentionCount) || other.needsAttentionCount == needsAttentionCount)&&const DeepCollectionEquality().equals(other._pendingPostIds, _pendingPostIds)&&const DeepCollectionEquality().equals(other._needsAttentionByPostId, _needsAttentionByPostId)&&const DeepCollectionEquality().equals(other._pendingCommentsByPostId, _pendingCommentsByPostId)&&const DeepCollectionEquality().equals(other._commentsByPostId, _commentsByPostId)&&(identical(other.effect, effect) || other.effect == effect)&&(identical(other.effectId, effectId) || other.effectId == effectId));
}


@override
int get hashCode => Object.hash(runtimeType,viewer,const DeepCollectionEquality().hash(_posts),nextCursor,refreshStatus,pageStatus,isShowingCachedData,cacheAge,connectionStatus,isSimulatedOffline,const DeepCollectionEquality().hash(_bufferedRealtimePosts),pendingMutationCount,needsAttentionCount,const DeepCollectionEquality().hash(_pendingPostIds),const DeepCollectionEquality().hash(_needsAttentionByPostId),const DeepCollectionEquality().hash(_pendingCommentsByPostId),const DeepCollectionEquality().hash(_commentsByPostId),effect,effectId);

@override
String toString() {
  return 'SocialFeedReadyData(viewer: $viewer, posts: $posts, nextCursor: $nextCursor, refreshStatus: $refreshStatus, pageStatus: $pageStatus, isShowingCachedData: $isShowingCachedData, cacheAge: $cacheAge, connectionStatus: $connectionStatus, isSimulatedOffline: $isSimulatedOffline, bufferedRealtimePosts: $bufferedRealtimePosts, pendingMutationCount: $pendingMutationCount, needsAttentionCount: $needsAttentionCount, pendingPostIds: $pendingPostIds, needsAttentionByPostId: $needsAttentionByPostId, pendingCommentsByPostId: $pendingCommentsByPostId, commentsByPostId: $commentsByPostId, effect: $effect, effectId: $effectId)';
}


}

/// @nodoc
abstract mixin class _$SocialFeedReadyDataCopyWith<$Res> implements $SocialFeedReadyDataCopyWith<$Res> {
  factory _$SocialFeedReadyDataCopyWith(_SocialFeedReadyData value, $Res Function(_SocialFeedReadyData) _then) = __$SocialFeedReadyDataCopyWithImpl;
@override @useResult
$Res call({
 SocialFeedViewer viewer, List<SocialFeedPost> posts, String? nextCursor, SocialFeedRefreshStatus refreshStatus, SocialFeedPageStatus pageStatus, bool isShowingCachedData, Duration cacheAge, SocialFeedConnectionStatus connectionStatus, bool isSimulatedOffline, List<SocialFeedPost> bufferedRealtimePosts, int pendingMutationCount, int needsAttentionCount, Set<String> pendingPostIds, Map<String, String> needsAttentionByPostId, Map<String, List<SocialFeedComment>> pendingCommentsByPostId, Map<String, List<SocialFeedComment>> commentsByPostId, SocialFeedEffect? effect, int effectId
});


@override $SocialFeedRefreshStatusCopyWith<$Res> get refreshStatus;@override $SocialFeedPageStatusCopyWith<$Res> get pageStatus;@override $SocialFeedEffectCopyWith<$Res>? get effect;

}
/// @nodoc
class __$SocialFeedReadyDataCopyWithImpl<$Res>
    implements _$SocialFeedReadyDataCopyWith<$Res> {
  __$SocialFeedReadyDataCopyWithImpl(this._self, this._then);

  final _SocialFeedReadyData _self;
  final $Res Function(_SocialFeedReadyData) _then;

/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? viewer = null,Object? posts = null,Object? nextCursor = freezed,Object? refreshStatus = null,Object? pageStatus = null,Object? isShowingCachedData = null,Object? cacheAge = null,Object? connectionStatus = null,Object? isSimulatedOffline = null,Object? bufferedRealtimePosts = null,Object? pendingMutationCount = null,Object? needsAttentionCount = null,Object? pendingPostIds = null,Object? needsAttentionByPostId = null,Object? pendingCommentsByPostId = null,Object? commentsByPostId = null,Object? effect = freezed,Object? effectId = null,}) {
  return _then(_SocialFeedReadyData(
viewer: null == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as SocialFeedViewer,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<SocialFeedPost>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,refreshStatus: null == refreshStatus ? _self.refreshStatus : refreshStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedRefreshStatus,pageStatus: null == pageStatus ? _self.pageStatus : pageStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedPageStatus,isShowingCachedData: null == isShowingCachedData ? _self.isShowingCachedData : isShowingCachedData // ignore: cast_nullable_to_non_nullable
as bool,cacheAge: null == cacheAge ? _self.cacheAge : cacheAge // ignore: cast_nullable_to_non_nullable
as Duration,connectionStatus: null == connectionStatus ? _self.connectionStatus : connectionStatus // ignore: cast_nullable_to_non_nullable
as SocialFeedConnectionStatus,isSimulatedOffline: null == isSimulatedOffline ? _self.isSimulatedOffline : isSimulatedOffline // ignore: cast_nullable_to_non_nullable
as bool,bufferedRealtimePosts: null == bufferedRealtimePosts ? _self._bufferedRealtimePosts : bufferedRealtimePosts // ignore: cast_nullable_to_non_nullable
as List<SocialFeedPost>,pendingMutationCount: null == pendingMutationCount ? _self.pendingMutationCount : pendingMutationCount // ignore: cast_nullable_to_non_nullable
as int,needsAttentionCount: null == needsAttentionCount ? _self.needsAttentionCount : needsAttentionCount // ignore: cast_nullable_to_non_nullable
as int,pendingPostIds: null == pendingPostIds ? _self._pendingPostIds : pendingPostIds // ignore: cast_nullable_to_non_nullable
as Set<String>,needsAttentionByPostId: null == needsAttentionByPostId ? _self._needsAttentionByPostId : needsAttentionByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, String>,pendingCommentsByPostId: null == pendingCommentsByPostId ? _self._pendingCommentsByPostId : pendingCommentsByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, List<SocialFeedComment>>,commentsByPostId: null == commentsByPostId ? _self._commentsByPostId : commentsByPostId // ignore: cast_nullable_to_non_nullable
as Map<String, List<SocialFeedComment>>,effect: freezed == effect ? _self.effect : effect // ignore: cast_nullable_to_non_nullable
as SocialFeedEffect?,effectId: null == effectId ? _self.effectId : effectId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedRefreshStatusCopyWith<$Res> get refreshStatus {
  
  return $SocialFeedRefreshStatusCopyWith<$Res>(_self.refreshStatus, (value) {
    return _then(_self.copyWith(refreshStatus: value));
  });
}/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedPageStatusCopyWith<$Res> get pageStatus {
  
  return $SocialFeedPageStatusCopyWith<$Res>(_self.pageStatus, (value) {
    return _then(_self.copyWith(pageStatus: value));
  });
}/// Create a copy of SocialFeedReadyData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedEffectCopyWith<$Res>? get effect {
    if (_self.effect == null) {
    return null;
  }

  return $SocialFeedEffectCopyWith<$Res>(_self.effect!, (value) {
    return _then(_self.copyWith(effect: value));
  });
}
}

/// @nodoc
mixin _$SocialFeedState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SocialFeedState()';
}


}

/// @nodoc
class $SocialFeedStateCopyWith<$Res>  {
$SocialFeedStateCopyWith(SocialFeedState _, $Res Function(SocialFeedState) __);
}


/// Adds pattern-matching-related methods to [SocialFeedState].
extension SocialFeedStatePatterns on SocialFeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocialFeedInitial value)?  initial,TResult Function( SocialFeedLoading value)?  loading,TResult Function( SocialFeedFailureState value)?  failure,TResult Function( SocialFeedReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocialFeedInitial() when initial != null:
return initial(_that);case SocialFeedLoading() when loading != null:
return loading(_that);case SocialFeedFailureState() when failure != null:
return failure(_that);case SocialFeedReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocialFeedInitial value)  initial,required TResult Function( SocialFeedLoading value)  loading,required TResult Function( SocialFeedFailureState value)  failure,required TResult Function( SocialFeedReady value)  ready,}){
final _that = this;
switch (_that) {
case SocialFeedInitial():
return initial(_that);case SocialFeedLoading():
return loading(_that);case SocialFeedFailureState():
return failure(_that);case SocialFeedReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocialFeedInitial value)?  initial,TResult? Function( SocialFeedLoading value)?  loading,TResult? Function( SocialFeedFailureState value)?  failure,TResult? Function( SocialFeedReady value)?  ready,}){
final _that = this;
switch (_that) {
case SocialFeedInitial() when initial != null:
return initial(_that);case SocialFeedLoading() when loading != null:
return loading(_that);case SocialFeedFailureState() when failure != null:
return failure(_that);case SocialFeedReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SocialFeedViewer viewer)?  initial,TResult Function( SocialFeedViewer viewer)?  loading,TResult Function( SocialFeedViewer viewer,  SocialFeedFailure failure)?  failure,TResult Function( SocialFeedReadyData data)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocialFeedInitial() when initial != null:
return initial(_that.viewer);case SocialFeedLoading() when loading != null:
return loading(_that.viewer);case SocialFeedFailureState() when failure != null:
return failure(_that.viewer,_that.failure);case SocialFeedReady() when ready != null:
return ready(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SocialFeedViewer viewer)  initial,required TResult Function( SocialFeedViewer viewer)  loading,required TResult Function( SocialFeedViewer viewer,  SocialFeedFailure failure)  failure,required TResult Function( SocialFeedReadyData data)  ready,}) {final _that = this;
switch (_that) {
case SocialFeedInitial():
return initial(_that.viewer);case SocialFeedLoading():
return loading(_that.viewer);case SocialFeedFailureState():
return failure(_that.viewer,_that.failure);case SocialFeedReady():
return ready(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SocialFeedViewer viewer)?  initial,TResult? Function( SocialFeedViewer viewer)?  loading,TResult? Function( SocialFeedViewer viewer,  SocialFeedFailure failure)?  failure,TResult? Function( SocialFeedReadyData data)?  ready,}) {final _that = this;
switch (_that) {
case SocialFeedInitial() when initial != null:
return initial(_that.viewer);case SocialFeedLoading() when loading != null:
return loading(_that.viewer);case SocialFeedFailureState() when failure != null:
return failure(_that.viewer,_that.failure);case SocialFeedReady() when ready != null:
return ready(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class SocialFeedInitial implements SocialFeedState {
  const SocialFeedInitial(this.viewer);
  

 final  SocialFeedViewer viewer;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedInitialCopyWith<SocialFeedInitial> get copyWith => _$SocialFeedInitialCopyWithImpl<SocialFeedInitial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedInitial&&(identical(other.viewer, viewer) || other.viewer == viewer));
}


@override
int get hashCode => Object.hash(runtimeType,viewer);

@override
String toString() {
  return 'SocialFeedState.initial(viewer: $viewer)';
}


}

/// @nodoc
abstract mixin class $SocialFeedInitialCopyWith<$Res> implements $SocialFeedStateCopyWith<$Res> {
  factory $SocialFeedInitialCopyWith(SocialFeedInitial value, $Res Function(SocialFeedInitial) _then) = _$SocialFeedInitialCopyWithImpl;
@useResult
$Res call({
 SocialFeedViewer viewer
});




}
/// @nodoc
class _$SocialFeedInitialCopyWithImpl<$Res>
    implements $SocialFeedInitialCopyWith<$Res> {
  _$SocialFeedInitialCopyWithImpl(this._self, this._then);

  final SocialFeedInitial _self;
  final $Res Function(SocialFeedInitial) _then;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? viewer = null,}) {
  return _then(SocialFeedInitial(
null == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as SocialFeedViewer,
  ));
}


}

/// @nodoc


class SocialFeedLoading implements SocialFeedState {
  const SocialFeedLoading(this.viewer);
  

 final  SocialFeedViewer viewer;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedLoadingCopyWith<SocialFeedLoading> get copyWith => _$SocialFeedLoadingCopyWithImpl<SocialFeedLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedLoading&&(identical(other.viewer, viewer) || other.viewer == viewer));
}


@override
int get hashCode => Object.hash(runtimeType,viewer);

@override
String toString() {
  return 'SocialFeedState.loading(viewer: $viewer)';
}


}

/// @nodoc
abstract mixin class $SocialFeedLoadingCopyWith<$Res> implements $SocialFeedStateCopyWith<$Res> {
  factory $SocialFeedLoadingCopyWith(SocialFeedLoading value, $Res Function(SocialFeedLoading) _then) = _$SocialFeedLoadingCopyWithImpl;
@useResult
$Res call({
 SocialFeedViewer viewer
});




}
/// @nodoc
class _$SocialFeedLoadingCopyWithImpl<$Res>
    implements $SocialFeedLoadingCopyWith<$Res> {
  _$SocialFeedLoadingCopyWithImpl(this._self, this._then);

  final SocialFeedLoading _self;
  final $Res Function(SocialFeedLoading) _then;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? viewer = null,}) {
  return _then(SocialFeedLoading(
null == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as SocialFeedViewer,
  ));
}


}

/// @nodoc


class SocialFeedFailureState implements SocialFeedState {
  const SocialFeedFailureState({required this.viewer, required this.failure});
  

 final  SocialFeedViewer viewer;
 final  SocialFeedFailure failure;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedFailureStateCopyWith<SocialFeedFailureState> get copyWith => _$SocialFeedFailureStateCopyWithImpl<SocialFeedFailureState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedFailureState&&(identical(other.viewer, viewer) || other.viewer == viewer)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,viewer,failure);

@override
String toString() {
  return 'SocialFeedState.failure(viewer: $viewer, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SocialFeedFailureStateCopyWith<$Res> implements $SocialFeedStateCopyWith<$Res> {
  factory $SocialFeedFailureStateCopyWith(SocialFeedFailureState value, $Res Function(SocialFeedFailureState) _then) = _$SocialFeedFailureStateCopyWithImpl;
@useResult
$Res call({
 SocialFeedViewer viewer, SocialFeedFailure failure
});




}
/// @nodoc
class _$SocialFeedFailureStateCopyWithImpl<$Res>
    implements $SocialFeedFailureStateCopyWith<$Res> {
  _$SocialFeedFailureStateCopyWithImpl(this._self, this._then);

  final SocialFeedFailureState _self;
  final $Res Function(SocialFeedFailureState) _then;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? viewer = null,Object? failure = null,}) {
  return _then(SocialFeedFailureState(
viewer: null == viewer ? _self.viewer : viewer // ignore: cast_nullable_to_non_nullable
as SocialFeedViewer,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as SocialFeedFailure,
  ));
}


}

/// @nodoc


class SocialFeedReady implements SocialFeedState {
  const SocialFeedReady(this.data);
  

 final  SocialFeedReadyData data;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialFeedReadyCopyWith<SocialFeedReady> get copyWith => _$SocialFeedReadyCopyWithImpl<SocialFeedReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialFeedReady&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'SocialFeedState.ready(data: $data)';
}


}

/// @nodoc
abstract mixin class $SocialFeedReadyCopyWith<$Res> implements $SocialFeedStateCopyWith<$Res> {
  factory $SocialFeedReadyCopyWith(SocialFeedReady value, $Res Function(SocialFeedReady) _then) = _$SocialFeedReadyCopyWithImpl;
@useResult
$Res call({
 SocialFeedReadyData data
});


$SocialFeedReadyDataCopyWith<$Res> get data;

}
/// @nodoc
class _$SocialFeedReadyCopyWithImpl<$Res>
    implements $SocialFeedReadyCopyWith<$Res> {
  _$SocialFeedReadyCopyWithImpl(this._self, this._then);

  final SocialFeedReady _self;
  final $Res Function(SocialFeedReady) _then;

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(SocialFeedReady(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SocialFeedReadyData,
  ));
}

/// Create a copy of SocialFeedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SocialFeedReadyDataCopyWith<$Res> get data {
  
  return $SocialFeedReadyDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
