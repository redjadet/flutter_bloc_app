import 'package:equatable/equatable.dart';

class ChatContact extends Equatable {
  const ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.profileImageUrl,
    required this.lastMessageTime,
    this.isOnline = false,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String profileImageUrl;
  final DateTime lastMessageTime;
  final bool isOnline;
  final int unreadCount;

  ChatContact copyWith({
    final String? id,
    final String? name,
    final String? lastMessage,
    final String? profileImageUrl,
    final DateTime? lastMessageTime,
    final bool? isOnline,
    final int? unreadCount,
  }) => ChatContact(
    id: id ?? this.id,
    name: name ?? this.name,
    lastMessage: lastMessage ?? this.lastMessage,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    isOnline: isOnline ?? this.isOnline,
    unreadCount: unreadCount ?? this.unreadCount,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    lastMessage,
    profileImageUrl,
    lastMessageTime,
    isOnline,
    unreadCount,
  ];
}
