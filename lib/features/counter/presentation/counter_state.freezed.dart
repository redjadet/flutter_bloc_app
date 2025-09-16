// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CounterState {
  int get count => throw _privateConstructorUsedError;
  DateTime? get lastChanged => throw _privateConstructorUsedError;
  int get countdownSeconds => throw _privateConstructorUsedError;
  bool get isAutoDecrementActive => throw _privateConstructorUsedError;
  CounterError? get error => throw _privateConstructorUsedError;
  CounterStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of CounterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterStateCopyWith<CounterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterStateCopyWith<$Res> {
  factory $CounterStateCopyWith(
    CounterState value,
    $Res Function(CounterState) then,
  ) = _$CounterStateCopyWithImpl<$Res, CounterState>;
  @useResult
  $Res call({
    int count,
    DateTime? lastChanged,
    int countdownSeconds,
    bool isAutoDecrementActive,
    CounterError? error,
    CounterStatus status,
  });
}

/// @nodoc
class _$CounterStateCopyWithImpl<$Res, $Val extends CounterState>
    implements $CounterStateCopyWith<$Res> {
  _$CounterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? lastChanged = freezed,
    Object? countdownSeconds = null,
    Object? isAutoDecrementActive = null,
    Object? error = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            lastChanged: freezed == lastChanged
                ? _value.lastChanged
                : lastChanged // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            countdownSeconds: null == countdownSeconds
                ? _value.countdownSeconds
                : countdownSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            isAutoDecrementActive: null == isAutoDecrementActive
                ? _value.isAutoDecrementActive
                : isAutoDecrementActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as CounterError?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CounterStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CounterStateImplCopyWith<$Res>
    implements $CounterStateCopyWith<$Res> {
  factory _$$CounterStateImplCopyWith(
    _$CounterStateImpl value,
    $Res Function(_$CounterStateImpl) then,
  ) = __$$CounterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int count,
    DateTime? lastChanged,
    int countdownSeconds,
    bool isAutoDecrementActive,
    CounterError? error,
    CounterStatus status,
  });
}

/// @nodoc
class __$$CounterStateImplCopyWithImpl<$Res>
    extends _$CounterStateCopyWithImpl<$Res, _$CounterStateImpl>
    implements _$$CounterStateImplCopyWith<$Res> {
  __$$CounterStateImplCopyWithImpl(
    _$CounterStateImpl _value,
    $Res Function(_$CounterStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CounterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = null,
    Object? lastChanged = freezed,
    Object? countdownSeconds = null,
    Object? isAutoDecrementActive = null,
    Object? error = freezed,
    Object? status = null,
  }) {
    return _then(
      _$CounterStateImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        lastChanged: freezed == lastChanged
            ? _value.lastChanged
            : lastChanged // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        countdownSeconds: null == countdownSeconds
            ? _value.countdownSeconds
            : countdownSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        isAutoDecrementActive: null == isAutoDecrementActive
            ? _value.isAutoDecrementActive
            : isAutoDecrementActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as CounterError?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CounterStatus,
      ),
    );
  }
}

/// @nodoc

class _$CounterStateImpl extends _CounterState {
  const _$CounterStateImpl({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
    this.isAutoDecrementActive = true,
    this.error,
    this.status = CounterStatus.idle,
  }) : super._();

  @override
  final int count;
  @override
  final DateTime? lastChanged;
  @override
  @JsonKey()
  final int countdownSeconds;
  @override
  @JsonKey()
  final bool isAutoDecrementActive;
  @override
  final CounterError? error;
  @override
  @JsonKey()
  final CounterStatus status;

  @override
  String toString() {
    return 'CounterState(count: $count, lastChanged: $lastChanged, countdownSeconds: $countdownSeconds, isAutoDecrementActive: $isAutoDecrementActive, error: $error, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterStateImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged) &&
            (identical(other.countdownSeconds, countdownSeconds) ||
                other.countdownSeconds == countdownSeconds) &&
            (identical(other.isAutoDecrementActive, isAutoDecrementActive) ||
                other.isAutoDecrementActive == isAutoDecrementActive) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    count,
    lastChanged,
    countdownSeconds,
    isAutoDecrementActive,
    error,
    status,
  );

  /// Create a copy of CounterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterStateImplCopyWith<_$CounterStateImpl> get copyWith =>
      __$$CounterStateImplCopyWithImpl<_$CounterStateImpl>(this, _$identity);
}

abstract class _CounterState extends CounterState {
  const factory _CounterState({
    required final int count,
    final DateTime? lastChanged,
    final int countdownSeconds,
    final bool isAutoDecrementActive,
    final CounterError? error,
    final CounterStatus status,
  }) = _$CounterStateImpl;
  const _CounterState._() : super._();

  @override
  int get count;
  @override
  DateTime? get lastChanged;
  @override
  int get countdownSeconds;
  @override
  bool get isAutoDecrementActive;
  @override
  CounterError? get error;
  @override
  CounterStatus get status;

  /// Create a copy of CounterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterStateImplCopyWith<_$CounterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
