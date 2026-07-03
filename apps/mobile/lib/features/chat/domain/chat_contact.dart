import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_contact.freezed.dart';

@freezed
abstract class ChatContact with _$ChatContact {
  const factory ChatContact({
    required final String id,
    required final String name,
    required final String lastMessage,
    required final String profileImageUrl,
    required final DateTime lastMessageTime,
    @Default(false) final bool isOnline,
    @Default(0) final int unreadCount,
  }) = _ChatContact;
}
