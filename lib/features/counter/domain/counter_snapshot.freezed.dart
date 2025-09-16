// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CounterSnapshot _$CounterSnapshotFromJson(Map<String, dynamic> json) {
  return _CounterSnapshot.fromJson(json);
}

/// @nodoc
mixin _$CounterSnapshot {
  int get count => throw _privateConstructorUsedError;
  DateTime? get lastChanged => throw _privateConstructorUsedError;

  /// Serializes this CounterSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CounterSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterSnapshotCopyWith<CounterSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterSnapshotCopyWith<$Res> {
  factory $CounterSnapshotCopyWith(
    CounterSnapshot value,
    $Res Function(CounterSnapshot) then,
  ) = _$CounterSnapshotCopyWithImpl<$Res, CounterSnapshot>;
  @useResult
  $Res call({int count, DateTime? lastChanged});
}

/// @nodoc
class _$CounterSnapshotCopyWithImpl<$Res, $Val extends CounterSnapshot>
    implements $CounterSnapshotCopyWith<$Res> {
  _$CounterSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? lastChanged = freezed}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CounterSnapshotImplCopyWith<$Res>
    implements $CounterSnapshotCopyWith<$Res> {
  factory _$$CounterSnapshotImplCopyWith(
    _$CounterSnapshotImpl value,
    $Res Function(_$CounterSnapshotImpl) then,
  ) = __$$CounterSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int count, DateTime? lastChanged});
}

/// @nodoc
class __$$CounterSnapshotImplCopyWithImpl<$Res>
    extends _$CounterSnapshotCopyWithImpl<$Res, _$CounterSnapshotImpl>
    implements _$$CounterSnapshotImplCopyWith<$Res> {
  __$$CounterSnapshotImplCopyWithImpl(
    _$CounterSnapshotImpl _value,
    $Res Function(_$CounterSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CounterSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? count = null, Object? lastChanged = freezed}) {
    return _then(
      _$CounterSnapshotImpl(
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        lastChanged: freezed == lastChanged
            ? _value.lastChanged
            : lastChanged // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CounterSnapshotImpl implements _CounterSnapshot {
  const _$CounterSnapshotImpl({required this.count, this.lastChanged});

  factory _$CounterSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounterSnapshotImplFromJson(json);

  @override
  final int count;
  @override
  final DateTime? lastChanged;

  @override
  String toString() {
    return 'CounterSnapshot(count: $count, lastChanged: $lastChanged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterSnapshotImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, count, lastChanged);

  /// Create a copy of CounterSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterSnapshotImplCopyWith<_$CounterSnapshotImpl> get copyWith =>
      __$$CounterSnapshotImplCopyWithImpl<_$CounterSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CounterSnapshotImplToJson(this);
  }
}

abstract class _CounterSnapshot implements CounterSnapshot {
  const factory _CounterSnapshot({
    required final int count,
    final DateTime? lastChanged,
  }) = _$CounterSnapshotImpl;

  factory _CounterSnapshot.fromJson(Map<String, dynamic> json) =
      _$CounterSnapshotImpl.fromJson;

  @override
  int get count;
  @override
  DateTime? get lastChanged;

  /// Create a copy of CounterSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterSnapshotImplCopyWith<_$CounterSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
