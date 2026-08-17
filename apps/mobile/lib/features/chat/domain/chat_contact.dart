import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_contact.freezed.dart';

@freezed
abstract class ChatContact with _$ChatContact {
  const factory ChatContact({
    required String id,
    required String name,
    required String lastMessage,
    required String profileImageUrl,
    required DateTime lastMessageTime,
    @Default(false) bool isOnline,
    @Default(0) int unreadCount,
  }) = _ChatContact;
}
