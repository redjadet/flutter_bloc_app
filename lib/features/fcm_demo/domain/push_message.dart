import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message.freezed.dart';

/// Domain model for a push / FCM message payload.
@freezed
abstract class PushMessage with _$PushMessage {
  const factory PushMessage({
    required final String messageId,
    required final String? title,
    required final String? body,
    required final DateTime? sentTime,
    required final Map<String, String> data,
    @Default(PushMessageSource.foreground) final PushMessageSource source,
  }) = _PushMessage;
}

/// Source of the message for demo diagnostics.
enum PushMessageSource {
  foreground,
  opened,
  initial,
  background,
}
