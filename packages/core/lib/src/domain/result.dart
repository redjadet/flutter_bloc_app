import 'failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? getOrNull() => switch (this) {
    Success<T>(:final value) => value,
    FailureResult<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    FailureResult<T>(:final failure) => failure,
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final value) => Success<R>(transform(value)),
    FailureResult<T>(:final failure) => FailureResult<R>(failure),
  };

  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Success<T>(:final value) => transform(value),
    FailureResult<T>(:final failure) => FailureResult<R>(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
