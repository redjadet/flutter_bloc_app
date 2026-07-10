import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_failure.freezed.dart';

/// Typed chat presentation failure (message + optional ARB l10n code).
@freezed
sealed class ChatFailure with _$ChatFailure {
  const factory ChatFailure({
    required final String message,
    final String? l10nCode,
  }) = _ChatFailure;
}
