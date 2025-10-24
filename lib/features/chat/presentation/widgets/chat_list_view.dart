import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) => switch (state) {
          ChatListInitial() => const SizedBox.shrink(),
          ChatListLoading() => Center(
            child: CircularProgressIndicator(
              strokeWidth: context.isTabletOrLarger ? 3.0 : 2.0,
            ),
          ),
          ChatListLoaded(:final contacts) => ListView.separated(
            padding: context.responsiveListPadding,
            itemCount: contacts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: const Color(0xFFE5E5E5),
              indent: context.isDesktop
                  ? 100.0
                  : context.isTabletOrLarger
                  ? 90.0
                  : 80.0,
            ),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ChatContactTile(
                contact: contact,
                onTap: () => _navigateToChat(context, contact),
                onLongPress: () => _showDeleteDialog(context, contact),
              );
            },
          ),
          ChatListError(:final message) => _buildErrorState(context, message),
          _ => const SizedBox.shrink(),
        },
      );

  Widget _buildErrorState(BuildContext context, String message) => Center(
    child: Padding(
      padding: EdgeInsets.all(context.isTabletOrLarger ? 48.0 : 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.isTabletOrLarger ? 80.0 : 64.0,
            color: Colors.grey,
          ),
          SizedBox(height: context.responsiveGap * 2),
          Text(
            'Error loading chats',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: context.responsiveTitleSize,
            ),
          ),
          SizedBox(height: context.responsiveGap),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontSize: context.responsiveBodySize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveGap * 2),
          ElevatedButton(
            onPressed: () => unawaited(
              context.read<ChatListCubit>().loadChatContacts(),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveButtonPadding,
                vertical: context.responsiveGap,
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: context.responsiveBodySize,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _navigateToChat(BuildContext context, ChatContact contact) {
    // Mark as read when opening chat
    unawaited(context.read<ChatListCubit>().markAsRead(contact.id));

    // Navigate to chat page
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => BlocProvider(
            create: (context) {
              final cubit = ChatCubit(
                repository: getIt<ChatRepository>(),
                historyRepository: getIt<ChatHistoryRepository>(),
              );
              unawaited(cubit.loadHistory());
              return cubit;
            },
            child: const ChatPage(),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatContact contact) {
    final chatListCubit = context.read<ChatListCubit>();
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Chat'),
          content: Text(
            'Are you sure you want to delete the chat with ${contact.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                unawaited(chatListCubit.deleteContact(contact.id));
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
