import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_comms_failure.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_info.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_session.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/trusted_native_helper.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/presentation/cubit/agent_comms_state.dart';

class AgentCommsCubit extends Cubit<AgentCommsState> {
  new({
    required this._session,
    this._trustedHelper = const NoOpTrustedNativeHelper(),
  }) : super(const AgentCommsState());

  final AgentEngineSession _session;
  final TrustedNativeHelper _trustedHelper;
  StreamSubscription<AgentEngineEvent>? _eventsSub;
  int _generation = 0;

  Future<void> connect() async {
    final int generation = ++_generation;
    emit(
      state.copyWith(status: AgentCommsStatus.connecting, clearFailure: true),
    );
    try {
      await _session.connect();
      if (!_isActive(generation)) {
        return;
      }
      await _eventsSub?.cancel();
      _eventsSub = _session.events.listen(_onEvent);
      final String identity = await _trustedHelper.identity();
      if (!_isActive(generation)) {
        return;
      }
      emit(
        state.copyWith(
          status: AgentCommsStatus.connected,
          launcherDescription: _session.launcherDescription,
          trustedHelperIdentity: identity,
          clearFailure: true,
        ),
      );
    } on AgentCommsFailure catch (failure) {
      if (!_isActive(generation)) {
        return;
      }
      emit(state.copyWith(status: AgentCommsStatus.failure, failure: failure));
    } on Object catch (e) {
      if (!_isActive(generation)) {
        return;
      }
      emit(
        state.copyWith(
          status: AgentCommsStatus.failure,
          failure: AgentCommsUnavailableFailure('$e'),
        ),
      );
    }
  }

  Future<void> ping() async {
    if (!_session.isConnected) {
      emit(
        state.copyWith(
          status: AgentCommsStatus.failure,
          failure: const AgentCommsNotConnectedFailure(),
        ),
      );
      return;
    }
    final int generation = ++_generation;
    emit(state.copyWith(status: AgentCommsStatus.busy, clearFailure: true));
    try {
      final AgentEngineInfo info = await _session.ping();
      if (!_isActive(generation)) {
        return;
      }
      emit(
        state.copyWith(
          status: AgentCommsStatus.connected,
          engineInfo: info,
          eventLog: <String>[
            ...state.eventLog,
            'ping ok engine=${info.engine} v=${info.version} pid=${info.pid}',
          ],
        ),
      );
    } on AgentCommsFailure catch (failure) {
      if (!_isActive(generation)) {
        return;
      }
      emit(state.copyWith(status: AgentCommsStatus.failure, failure: failure));
    }
  }

  Future<void> streamDemo() async {
    if (!_session.isConnected) {
      emit(
        state.copyWith(
          status: AgentCommsStatus.failure,
          failure: const AgentCommsNotConnectedFailure(),
        ),
      );
      return;
    }
    final int generation = ++_generation;
    emit(state.copyWith(status: AgentCommsStatus.busy, clearFailure: true));
    try {
      final int streamed = await _session.streamDemo();
      if (!_isActive(generation)) {
        return;
      }
      emit(
        state.copyWith(
          status: AgentCommsStatus.connected,
          eventLog: <String>[
            ...state.eventLog,
            'streamDemo completed streamed=$streamed',
          ],
        ),
      );
    } on AgentCommsFailure catch (failure) {
      if (!_isActive(generation)) {
        return;
      }
      emit(state.copyWith(status: AgentCommsStatus.failure, failure: failure));
    }
  }

  Future<void> disconnect() async {
    ++_generation;
    await _eventsSub?.cancel();
    _eventsSub = null;
    await _session.disconnect();
    emit(
      state.copyWith(
        status: AgentCommsStatus.disconnected,
        clearEngineInfo: true,
        clearFailure: true,
        eventLog: <String>[...state.eventLog, 'disconnected'],
      ),
    );
  }

  void clearLog() {
    emit(state.copyWith(eventLog: const <String>[]));
  }

  void _onEvent(AgentEngineEvent event) {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        eventLog: <String>[
          ...state.eventLog,
          'event ${event.type}: ${event.message}',
        ],
      ),
    );
  }

  bool _isActive(int generation) => !isClosed && generation == _generation;

  @override
  Future<void> close() async {
    ++_generation;
    await _eventsSub?.cancel();
    await _session.disconnect();
    await super.close();
  }
}
