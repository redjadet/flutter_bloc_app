// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'iot_ble_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IotBleState {

 IotBleStatus get status; bool get useMockBle; bool get canToggleRealBle; bool get isScanning; Duration get scanTimeout; BleAdapterStatus? get adapterStatus; List<BleDiscoveredDevice> get devices; IotBleConnectionLifecycle get connectionLifecycle; List<BleService> get services; BleCharacteristicRef? get selectedCharacteristic; List<int>? get lastReadValue; bool get isSubscribed; List<BleLogEntry> get logs; List<ClassicBtDevice> get classicDevices; String? get selectedClassicDeviceId; List<ClassicBtMessage> get classicMessages; IotBleErrorCode? get errorCode; String? get errorDetail;
/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IotBleStateCopyWith<IotBleState> get copyWith => _$IotBleStateCopyWithImpl<IotBleState>(this as IotBleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IotBleState&&(identical(other.status, status) || other.status == status)&&(identical(other.useMockBle, useMockBle) || other.useMockBle == useMockBle)&&(identical(other.canToggleRealBle, canToggleRealBle) || other.canToggleRealBle == canToggleRealBle)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.scanTimeout, scanTimeout) || other.scanTimeout == scanTimeout)&&(identical(other.adapterStatus, adapterStatus) || other.adapterStatus == adapterStatus)&&const DeepCollectionEquality().equals(other.devices, devices)&&(identical(other.connectionLifecycle, connectionLifecycle) || other.connectionLifecycle == connectionLifecycle)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.selectedCharacteristic, selectedCharacteristic) || other.selectedCharacteristic == selectedCharacteristic)&&const DeepCollectionEquality().equals(other.lastReadValue, lastReadValue)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&const DeepCollectionEquality().equals(other.logs, logs)&&const DeepCollectionEquality().equals(other.classicDevices, classicDevices)&&(identical(other.selectedClassicDeviceId, selectedClassicDeviceId) || other.selectedClassicDeviceId == selectedClassicDeviceId)&&const DeepCollectionEquality().equals(other.classicMessages, classicMessages)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail));
}


@override
int get hashCode => Object.hash(runtimeType,status,useMockBle,canToggleRealBle,isScanning,scanTimeout,adapterStatus,const DeepCollectionEquality().hash(devices),connectionLifecycle,const DeepCollectionEquality().hash(services),selectedCharacteristic,const DeepCollectionEquality().hash(lastReadValue),isSubscribed,const DeepCollectionEquality().hash(logs),const DeepCollectionEquality().hash(classicDevices),selectedClassicDeviceId,const DeepCollectionEquality().hash(classicMessages),errorCode,errorDetail);

@override
String toString() {
  return 'IotBleState(status: $status, useMockBle: $useMockBle, canToggleRealBle: $canToggleRealBle, isScanning: $isScanning, scanTimeout: $scanTimeout, adapterStatus: $adapterStatus, devices: $devices, connectionLifecycle: $connectionLifecycle, services: $services, selectedCharacteristic: $selectedCharacteristic, lastReadValue: $lastReadValue, isSubscribed: $isSubscribed, logs: $logs, classicDevices: $classicDevices, selectedClassicDeviceId: $selectedClassicDeviceId, classicMessages: $classicMessages, errorCode: $errorCode, errorDetail: $errorDetail)';
}


}

/// @nodoc
abstract mixin class $IotBleStateCopyWith<$Res>  {
  factory $IotBleStateCopyWith(IotBleState value, $Res Function(IotBleState) _then) = _$IotBleStateCopyWithImpl;
@useResult
$Res call({
 IotBleStatus status, bool useMockBle, bool canToggleRealBle, bool isScanning, Duration scanTimeout, BleAdapterStatus? adapterStatus, List<BleDiscoveredDevice> devices, IotBleConnectionLifecycle connectionLifecycle, List<BleService> services, BleCharacteristicRef? selectedCharacteristic, List<int>? lastReadValue, bool isSubscribed, List<BleLogEntry> logs, List<ClassicBtDevice> classicDevices, String? selectedClassicDeviceId, List<ClassicBtMessage> classicMessages, IotBleErrorCode? errorCode, String? errorDetail
});


$IotBleConnectionLifecycleCopyWith<$Res> get connectionLifecycle;

}
/// @nodoc
class _$IotBleStateCopyWithImpl<$Res>
    implements $IotBleStateCopyWith<$Res> {
  _$IotBleStateCopyWithImpl(this._self, this._then);

  final IotBleState _self;
  final $Res Function(IotBleState) _then;

/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? useMockBle = null,Object? canToggleRealBle = null,Object? isScanning = null,Object? scanTimeout = null,Object? adapterStatus = freezed,Object? devices = null,Object? connectionLifecycle = null,Object? services = null,Object? selectedCharacteristic = freezed,Object? lastReadValue = freezed,Object? isSubscribed = null,Object? logs = null,Object? classicDevices = null,Object? selectedClassicDeviceId = freezed,Object? classicMessages = null,Object? errorCode = freezed,Object? errorDetail = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IotBleStatus,useMockBle: null == useMockBle ? _self.useMockBle : useMockBle // ignore: cast_nullable_to_non_nullable
as bool,canToggleRealBle: null == canToggleRealBle ? _self.canToggleRealBle : canToggleRealBle // ignore: cast_nullable_to_non_nullable
as bool,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,scanTimeout: null == scanTimeout ? _self.scanTimeout : scanTimeout // ignore: cast_nullable_to_non_nullable
as Duration,adapterStatus: freezed == adapterStatus ? _self.adapterStatus : adapterStatus // ignore: cast_nullable_to_non_nullable
as BleAdapterStatus?,devices: null == devices ? _self.devices : devices // ignore: cast_nullable_to_non_nullable
as List<BleDiscoveredDevice>,connectionLifecycle: null == connectionLifecycle ? _self.connectionLifecycle : connectionLifecycle // ignore: cast_nullable_to_non_nullable
as IotBleConnectionLifecycle,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<BleService>,selectedCharacteristic: freezed == selectedCharacteristic ? _self.selectedCharacteristic : selectedCharacteristic // ignore: cast_nullable_to_non_nullable
as BleCharacteristicRef?,lastReadValue: freezed == lastReadValue ? _self.lastReadValue : lastReadValue // ignore: cast_nullable_to_non_nullable
as List<int>?,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<BleLogEntry>,classicDevices: null == classicDevices ? _self.classicDevices : classicDevices // ignore: cast_nullable_to_non_nullable
as List<ClassicBtDevice>,selectedClassicDeviceId: freezed == selectedClassicDeviceId ? _self.selectedClassicDeviceId : selectedClassicDeviceId // ignore: cast_nullable_to_non_nullable
as String?,classicMessages: null == classicMessages ? _self.classicMessages : classicMessages // ignore: cast_nullable_to_non_nullable
as List<ClassicBtMessage>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as IotBleErrorCode?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IotBleConnectionLifecycleCopyWith<$Res> get connectionLifecycle {
  
  return $IotBleConnectionLifecycleCopyWith<$Res>(_self.connectionLifecycle, (value) {
    return _then(_self.copyWith(connectionLifecycle: value));
  });
}
}


/// Adds pattern-matching-related methods to [IotBleState].
extension IotBleStatePatterns on IotBleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IotBleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IotBleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IotBleState value)  $default,){
final _that = this;
switch (_that) {
case _IotBleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IotBleState value)?  $default,){
final _that = this;
switch (_that) {
case _IotBleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IotBleStatus status,  bool useMockBle,  bool canToggleRealBle,  bool isScanning,  Duration scanTimeout,  BleAdapterStatus? adapterStatus,  List<BleDiscoveredDevice> devices,  IotBleConnectionLifecycle connectionLifecycle,  List<BleService> services,  BleCharacteristicRef? selectedCharacteristic,  List<int>? lastReadValue,  bool isSubscribed,  List<BleLogEntry> logs,  List<ClassicBtDevice> classicDevices,  String? selectedClassicDeviceId,  List<ClassicBtMessage> classicMessages,  IotBleErrorCode? errorCode,  String? errorDetail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IotBleState() when $default != null:
return $default(_that.status,_that.useMockBle,_that.canToggleRealBle,_that.isScanning,_that.scanTimeout,_that.adapterStatus,_that.devices,_that.connectionLifecycle,_that.services,_that.selectedCharacteristic,_that.lastReadValue,_that.isSubscribed,_that.logs,_that.classicDevices,_that.selectedClassicDeviceId,_that.classicMessages,_that.errorCode,_that.errorDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IotBleStatus status,  bool useMockBle,  bool canToggleRealBle,  bool isScanning,  Duration scanTimeout,  BleAdapterStatus? adapterStatus,  List<BleDiscoveredDevice> devices,  IotBleConnectionLifecycle connectionLifecycle,  List<BleService> services,  BleCharacteristicRef? selectedCharacteristic,  List<int>? lastReadValue,  bool isSubscribed,  List<BleLogEntry> logs,  List<ClassicBtDevice> classicDevices,  String? selectedClassicDeviceId,  List<ClassicBtMessage> classicMessages,  IotBleErrorCode? errorCode,  String? errorDetail)  $default,) {final _that = this;
switch (_that) {
case _IotBleState():
return $default(_that.status,_that.useMockBle,_that.canToggleRealBle,_that.isScanning,_that.scanTimeout,_that.adapterStatus,_that.devices,_that.connectionLifecycle,_that.services,_that.selectedCharacteristic,_that.lastReadValue,_that.isSubscribed,_that.logs,_that.classicDevices,_that.selectedClassicDeviceId,_that.classicMessages,_that.errorCode,_that.errorDetail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IotBleStatus status,  bool useMockBle,  bool canToggleRealBle,  bool isScanning,  Duration scanTimeout,  BleAdapterStatus? adapterStatus,  List<BleDiscoveredDevice> devices,  IotBleConnectionLifecycle connectionLifecycle,  List<BleService> services,  BleCharacteristicRef? selectedCharacteristic,  List<int>? lastReadValue,  bool isSubscribed,  List<BleLogEntry> logs,  List<ClassicBtDevice> classicDevices,  String? selectedClassicDeviceId,  List<ClassicBtMessage> classicMessages,  IotBleErrorCode? errorCode,  String? errorDetail)?  $default,) {final _that = this;
switch (_that) {
case _IotBleState() when $default != null:
return $default(_that.status,_that.useMockBle,_that.canToggleRealBle,_that.isScanning,_that.scanTimeout,_that.adapterStatus,_that.devices,_that.connectionLifecycle,_that.services,_that.selectedCharacteristic,_that.lastReadValue,_that.isSubscribed,_that.logs,_that.classicDevices,_that.selectedClassicDeviceId,_that.classicMessages,_that.errorCode,_that.errorDetail);case _:
  return null;

}
}

}

/// @nodoc


class _IotBleState extends IotBleState {
  const _IotBleState({this.status = IotBleStatus.initial, this.useMockBle = true, this.canToggleRealBle = false, this.isScanning = false, this.scanTimeout = const Duration(seconds: 30), this.adapterStatus, final  List<BleDiscoveredDevice> devices = const <BleDiscoveredDevice>[], this.connectionLifecycle = const IotBleConnectionLifecycle.idle(), final  List<BleService> services = const <BleService>[], this.selectedCharacteristic, final  List<int>? lastReadValue, this.isSubscribed = false, final  List<BleLogEntry> logs = const <BleLogEntry>[], final  List<ClassicBtDevice> classicDevices = const <ClassicBtDevice>[], this.selectedClassicDeviceId, final  List<ClassicBtMessage> classicMessages = const <ClassicBtMessage>[], this.errorCode, this.errorDetail}): _devices = devices,_services = services,_lastReadValue = lastReadValue,_logs = logs,_classicDevices = classicDevices,_classicMessages = classicMessages,super._();
  

@override@JsonKey() final  IotBleStatus status;
@override@JsonKey() final  bool useMockBle;
@override@JsonKey() final  bool canToggleRealBle;
@override@JsonKey() final  bool isScanning;
@override@JsonKey() final  Duration scanTimeout;
@override final  BleAdapterStatus? adapterStatus;
 final  List<BleDiscoveredDevice> _devices;
@override@JsonKey() List<BleDiscoveredDevice> get devices {
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devices);
}

@override@JsonKey() final  IotBleConnectionLifecycle connectionLifecycle;
 final  List<BleService> _services;
@override@JsonKey() List<BleService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

@override final  BleCharacteristicRef? selectedCharacteristic;
 final  List<int>? _lastReadValue;
@override List<int>? get lastReadValue {
  final value = _lastReadValue;
  if (value == null) return null;
  if (_lastReadValue is EqualUnmodifiableListView) return _lastReadValue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isSubscribed;
 final  List<BleLogEntry> _logs;
@override@JsonKey() List<BleLogEntry> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

 final  List<ClassicBtDevice> _classicDevices;
@override@JsonKey() List<ClassicBtDevice> get classicDevices {
  if (_classicDevices is EqualUnmodifiableListView) return _classicDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classicDevices);
}

@override final  String? selectedClassicDeviceId;
 final  List<ClassicBtMessage> _classicMessages;
@override@JsonKey() List<ClassicBtMessage> get classicMessages {
  if (_classicMessages is EqualUnmodifiableListView) return _classicMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classicMessages);
}

@override final  IotBleErrorCode? errorCode;
@override final  String? errorDetail;

/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IotBleStateCopyWith<_IotBleState> get copyWith => __$IotBleStateCopyWithImpl<_IotBleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IotBleState&&(identical(other.status, status) || other.status == status)&&(identical(other.useMockBle, useMockBle) || other.useMockBle == useMockBle)&&(identical(other.canToggleRealBle, canToggleRealBle) || other.canToggleRealBle == canToggleRealBle)&&(identical(other.isScanning, isScanning) || other.isScanning == isScanning)&&(identical(other.scanTimeout, scanTimeout) || other.scanTimeout == scanTimeout)&&(identical(other.adapterStatus, adapterStatus) || other.adapterStatus == adapterStatus)&&const DeepCollectionEquality().equals(other._devices, _devices)&&(identical(other.connectionLifecycle, connectionLifecycle) || other.connectionLifecycle == connectionLifecycle)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.selectedCharacteristic, selectedCharacteristic) || other.selectedCharacteristic == selectedCharacteristic)&&const DeepCollectionEquality().equals(other._lastReadValue, _lastReadValue)&&(identical(other.isSubscribed, isSubscribed) || other.isSubscribed == isSubscribed)&&const DeepCollectionEquality().equals(other._logs, _logs)&&const DeepCollectionEquality().equals(other._classicDevices, _classicDevices)&&(identical(other.selectedClassicDeviceId, selectedClassicDeviceId) || other.selectedClassicDeviceId == selectedClassicDeviceId)&&const DeepCollectionEquality().equals(other._classicMessages, _classicMessages)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.errorDetail, errorDetail) || other.errorDetail == errorDetail));
}


@override
int get hashCode => Object.hash(runtimeType,status,useMockBle,canToggleRealBle,isScanning,scanTimeout,adapterStatus,const DeepCollectionEquality().hash(_devices),connectionLifecycle,const DeepCollectionEquality().hash(_services),selectedCharacteristic,const DeepCollectionEquality().hash(_lastReadValue),isSubscribed,const DeepCollectionEquality().hash(_logs),const DeepCollectionEquality().hash(_classicDevices),selectedClassicDeviceId,const DeepCollectionEquality().hash(_classicMessages),errorCode,errorDetail);

@override
String toString() {
  return 'IotBleState(status: $status, useMockBle: $useMockBle, canToggleRealBle: $canToggleRealBle, isScanning: $isScanning, scanTimeout: $scanTimeout, adapterStatus: $adapterStatus, devices: $devices, connectionLifecycle: $connectionLifecycle, services: $services, selectedCharacteristic: $selectedCharacteristic, lastReadValue: $lastReadValue, isSubscribed: $isSubscribed, logs: $logs, classicDevices: $classicDevices, selectedClassicDeviceId: $selectedClassicDeviceId, classicMessages: $classicMessages, errorCode: $errorCode, errorDetail: $errorDetail)';
}


}

/// @nodoc
abstract mixin class _$IotBleStateCopyWith<$Res> implements $IotBleStateCopyWith<$Res> {
  factory _$IotBleStateCopyWith(_IotBleState value, $Res Function(_IotBleState) _then) = __$IotBleStateCopyWithImpl;
@override @useResult
$Res call({
 IotBleStatus status, bool useMockBle, bool canToggleRealBle, bool isScanning, Duration scanTimeout, BleAdapterStatus? adapterStatus, List<BleDiscoveredDevice> devices, IotBleConnectionLifecycle connectionLifecycle, List<BleService> services, BleCharacteristicRef? selectedCharacteristic, List<int>? lastReadValue, bool isSubscribed, List<BleLogEntry> logs, List<ClassicBtDevice> classicDevices, String? selectedClassicDeviceId, List<ClassicBtMessage> classicMessages, IotBleErrorCode? errorCode, String? errorDetail
});


@override $IotBleConnectionLifecycleCopyWith<$Res> get connectionLifecycle;

}
/// @nodoc
class __$IotBleStateCopyWithImpl<$Res>
    implements _$IotBleStateCopyWith<$Res> {
  __$IotBleStateCopyWithImpl(this._self, this._then);

  final _IotBleState _self;
  final $Res Function(_IotBleState) _then;

/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? useMockBle = null,Object? canToggleRealBle = null,Object? isScanning = null,Object? scanTimeout = null,Object? adapterStatus = freezed,Object? devices = null,Object? connectionLifecycle = null,Object? services = null,Object? selectedCharacteristic = freezed,Object? lastReadValue = freezed,Object? isSubscribed = null,Object? logs = null,Object? classicDevices = null,Object? selectedClassicDeviceId = freezed,Object? classicMessages = null,Object? errorCode = freezed,Object? errorDetail = freezed,}) {
  return _then(_IotBleState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IotBleStatus,useMockBle: null == useMockBle ? _self.useMockBle : useMockBle // ignore: cast_nullable_to_non_nullable
as bool,canToggleRealBle: null == canToggleRealBle ? _self.canToggleRealBle : canToggleRealBle // ignore: cast_nullable_to_non_nullable
as bool,isScanning: null == isScanning ? _self.isScanning : isScanning // ignore: cast_nullable_to_non_nullable
as bool,scanTimeout: null == scanTimeout ? _self.scanTimeout : scanTimeout // ignore: cast_nullable_to_non_nullable
as Duration,adapterStatus: freezed == adapterStatus ? _self.adapterStatus : adapterStatus // ignore: cast_nullable_to_non_nullable
as BleAdapterStatus?,devices: null == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<BleDiscoveredDevice>,connectionLifecycle: null == connectionLifecycle ? _self.connectionLifecycle : connectionLifecycle // ignore: cast_nullable_to_non_nullable
as IotBleConnectionLifecycle,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<BleService>,selectedCharacteristic: freezed == selectedCharacteristic ? _self.selectedCharacteristic : selectedCharacteristic // ignore: cast_nullable_to_non_nullable
as BleCharacteristicRef?,lastReadValue: freezed == lastReadValue ? _self._lastReadValue : lastReadValue // ignore: cast_nullable_to_non_nullable
as List<int>?,isSubscribed: null == isSubscribed ? _self.isSubscribed : isSubscribed // ignore: cast_nullable_to_non_nullable
as bool,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<BleLogEntry>,classicDevices: null == classicDevices ? _self._classicDevices : classicDevices // ignore: cast_nullable_to_non_nullable
as List<ClassicBtDevice>,selectedClassicDeviceId: freezed == selectedClassicDeviceId ? _self.selectedClassicDeviceId : selectedClassicDeviceId // ignore: cast_nullable_to_non_nullable
as String?,classicMessages: null == classicMessages ? _self._classicMessages : classicMessages // ignore: cast_nullable_to_non_nullable
as List<ClassicBtMessage>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as IotBleErrorCode?,errorDetail: freezed == errorDetail ? _self.errorDetail : errorDetail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of IotBleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IotBleConnectionLifecycleCopyWith<$Res> get connectionLifecycle {
  
  return $IotBleConnectionLifecycleCopyWith<$Res>(_self.connectionLifecycle, (value) {
    return _then(_self.copyWith(connectionLifecycle: value));
  });
}
}

// dart format on
