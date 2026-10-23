import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_comms_failure.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/domain/agent_engine_info.dart';

enum AgentCommsStatus { disconnected, connecting, connected, busy, failure }

final class AgentCommsState {
  const new({
    this.status = AgentCommsStatus.disconnected,
    this.launcherDescription,
    this.engineInfo,
    this.trustedHelperIdentity,
    this.eventLog = const <String>[],
    this.failure,
  });

  final AgentCommsStatus status;
  final String? launcherDescription;
  final AgentEngineInfo? engineInfo;
  final String? trustedHelperIdentity;
  final List<String> eventLog;
  final AgentCommsFailure? failure;

  AgentCommsState copyWith({
    AgentCommsStatus? status,
    String? launcherDescription,
    AgentEngineInfo? engineInfo,
    String? trustedHelperIdentity,
    List<String>? eventLog,
    AgentCommsFailure? failure,
    bool clearFailure = false,
    bool clearEngineInfo = false,
  }) {
    return AgentCommsState(
      status: status ?? this.status,
      launcherDescription: launcherDescription ?? this.launcherDescription,
      engineInfo: clearEngineInfo ? null : (engineInfo ?? this.engineInfo),
      trustedHelperIdentity:
          trustedHelperIdentity ?? this.trustedHelperIdentity,
      eventLog: eventLog ?? this.eventLog,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
