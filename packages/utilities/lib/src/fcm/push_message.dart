import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_message.freezed.dart';

/// Domain model for a push / FCM message payload.
@freezed
abstract class PushMessage with _$PushMessage {
  const factory PushMessage({
    required String messageId,
    required String? title,
    required String? body,
    required DateTime? sentTime,
    required Map<String, String> data,
    @Default(PushMessageSource.foreground) PushMessageSource source,
  }) = _PushMessage;
}

/// Source of the message for demo diagnostics.
enum PushMessageSource { foreground, opened, initial, background }
