// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_demo_proof_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffDemoProofState {

 StaffDemoProofStatus get status; List<String> get photoPaths; String? get signaturePath; String? get errorMessage; String? get lastProofId;
/// Create a copy of StaffDemoProofState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffDemoProofStateCopyWith<StaffDemoProofState> get copyWith => _$StaffDemoProofStateCopyWithImpl<StaffDemoProofState>(this as StaffDemoProofState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffDemoProofState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.photoPaths, photoPaths)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastProofId, lastProofId) || other.lastProofId == lastProofId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(photoPaths),signaturePath,errorMessage,lastProofId);

@override
String toString() {
  return 'StaffDemoProofState(status: $status, photoPaths: $photoPaths, signaturePath: $signaturePath, errorMessage: $errorMessage, lastProofId: $lastProofId)';
}


}

/// @nodoc
abstract mixin class $StaffDemoProofStateCopyWith<$Res>  {
  factory $StaffDemoProofStateCopyWith(StaffDemoProofState value, $Res Function(StaffDemoProofState) _then) = _$StaffDemoProofStateCopyWithImpl;
@useResult
$Res call({
 StaffDemoProofStatus status, List<String> photoPaths, String? signaturePath, String? errorMessage, String? lastProofId
});




}
/// @nodoc
class _$StaffDemoProofStateCopyWithImpl<$Res>
    implements $StaffDemoProofStateCopyWith<$Res> {
  _$StaffDemoProofStateCopyWithImpl(this._self, this._then);

  final StaffDemoProofState _self;
  final $Res Function(StaffDemoProofState) _then;

/// Create a copy of StaffDemoProofState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? photoPaths = null,Object? signaturePath = freezed,Object? errorMessage = freezed,Object? lastProofId = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoProofStatus,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastProofId: freezed == lastProofId ? _self.lastProofId : lastProofId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffDemoProofState].
extension StaffDemoProofStatePatterns on StaffDemoProofState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffDemoProofState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffDemoProofState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffDemoProofState value)  $default,){
final _that = this;
switch (_that) {
case _StaffDemoProofState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffDemoProofState value)?  $default,){
final _that = this;
switch (_that) {
case _StaffDemoProofState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffDemoProofStatus status,  List<String> photoPaths,  String? signaturePath,  String? errorMessage,  String? lastProofId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffDemoProofState() when $default != null:
return $default(_that.status,_that.photoPaths,_that.signaturePath,_that.errorMessage,_that.lastProofId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffDemoProofStatus status,  List<String> photoPaths,  String? signaturePath,  String? errorMessage,  String? lastProofId)  $default,) {final _that = this;
switch (_that) {
case _StaffDemoProofState():
return $default(_that.status,_that.photoPaths,_that.signaturePath,_that.errorMessage,_that.lastProofId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffDemoProofStatus status,  List<String> photoPaths,  String? signaturePath,  String? errorMessage,  String? lastProofId)?  $default,) {final _that = this;
switch (_that) {
case _StaffDemoProofState() when $default != null:
return $default(_that.status,_that.photoPaths,_that.signaturePath,_that.errorMessage,_that.lastProofId);case _:
  return null;

}
}

}

/// @nodoc


class _StaffDemoProofState implements StaffDemoProofState {
  const _StaffDemoProofState({this.status = StaffDemoProofStatus.initial, final  List<String> photoPaths = const <String>[], this.signaturePath, this.errorMessage, this.lastProofId}): _photoPaths = photoPaths;
  

@override@JsonKey() final  StaffDemoProofStatus status;
 final  List<String> _photoPaths;
@override@JsonKey() List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}

@override final  String? signaturePath;
@override final  String? errorMessage;
@override final  String? lastProofId;

/// Create a copy of StaffDemoProofState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffDemoProofStateCopyWith<_StaffDemoProofState> get copyWith => __$StaffDemoProofStateCopyWithImpl<_StaffDemoProofState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffDemoProofState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._photoPaths, _photoPaths)&&(identical(other.signaturePath, signaturePath) || other.signaturePath == signaturePath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.lastProofId, lastProofId) || other.lastProofId == lastProofId));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_photoPaths),signaturePath,errorMessage,lastProofId);

@override
String toString() {
  return 'StaffDemoProofState(status: $status, photoPaths: $photoPaths, signaturePath: $signaturePath, errorMessage: $errorMessage, lastProofId: $lastProofId)';
}


}

/// @nodoc
abstract mixin class _$StaffDemoProofStateCopyWith<$Res> implements $StaffDemoProofStateCopyWith<$Res> {
  factory _$StaffDemoProofStateCopyWith(_StaffDemoProofState value, $Res Function(_StaffDemoProofState) _then) = __$StaffDemoProofStateCopyWithImpl;
@override @useResult
$Res call({
 StaffDemoProofStatus status, List<String> photoPaths, String? signaturePath, String? errorMessage, String? lastProofId
});




}
/// @nodoc
class __$StaffDemoProofStateCopyWithImpl<$Res>
    implements _$StaffDemoProofStateCopyWith<$Res> {
  __$StaffDemoProofStateCopyWithImpl(this._self, this._then);

  final _StaffDemoProofState _self;
  final $Res Function(_StaffDemoProofState) _then;

/// Create a copy of StaffDemoProofState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? photoPaths = null,Object? signaturePath = freezed,Object? errorMessage = freezed,Object? lastProofId = freezed,}) {
  return _then(_StaffDemoProofState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StaffDemoProofStatus,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,signaturePath: freezed == signaturePath ? _self.signaturePath : signaturePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,lastProofId: freezed == lastProofId ? _self.lastProofId : lastProofId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
