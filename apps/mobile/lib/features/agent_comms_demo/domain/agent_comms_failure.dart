/// Failures from the out-of-process agent communication layer.
sealed class AgentCommsFailure implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AgentCommsUnavailableFailure extends AgentCommsFailure {
  const new([super.message = 'Agent engine unavailable']);
}

final class AgentCommsTransportFailure extends AgentCommsFailure {
  const new([super.message = 'Agent transport error']);
}

final class AgentCommsRpcFailure extends AgentCommsFailure {
  const new(super.message, {this.code});

  final int? code;
}

final class AgentCommsNotConnectedFailure extends AgentCommsFailure {
  const new([super.message = 'Not connected to agent engine']);
}
