/// Domain-level failure taxonomy for plugin and I/O boundaries.
///
/// Keep free of Flutter/plugins; map to presentation errors at the UI layer.
sealed class Failure {
  const Failure({this.cause});

  final Object? cause;
}

enum PermissionFailureReason { denied, permanentlyDenied, restricted, limited }

final class PermissionFailure extends Failure {
  const PermissionFailure(this.reason, {super.cause});

  final PermissionFailureReason reason;
}

enum PlatformFailureReason { unavailable }

final class PlatformFailure extends Failure {
  const PlatformFailure(this.reason, {super.cause});

  final PlatformFailureReason reason;
}

enum StorageFailureKind { read, write, delete }

final class StorageFailure extends Failure {
  const StorageFailure({required this.kind, this.key, super.cause});

  final StorageFailureKind kind;
  final String? key;
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.cause});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(this.code, {super.cause});

  final String code;
}

final class UnknownFailure extends Failure {
  const UnknownFailure({this.message, super.cause});

  final String? message;
}
