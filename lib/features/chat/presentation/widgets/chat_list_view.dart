import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) => switch (state) {
          ChatListInitial() => const SizedBox.shrink(),
          ChatListLoading() => const CommonLoadingWidget(),
          ChatListLoaded(:final contacts) => _buildLoadedList(
            context,
            contacts,
          ),
          ChatListError(:final message) => _buildErrorState(context, message),
          _ => const SizedBox.shrink(),
        },
      );

  Widget _buildLoadedList(
    BuildContext context,
    List<ChatContact> contacts,
  ) {
    final listPadding = context.responsiveListPadding;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
        child: ListView.separated(
          padding: EdgeInsets.only(
            bottom: listPadding.bottom + context.responsiveGap,
          ),
          itemCount: contacts.length,
          separatorBuilder: (context, index) => const _ChatDivider(),
          itemBuilder: (context, index) {
            final contact = contacts[index];
            final isFirst = index == 0;
            final isLast = index == contacts.length - 1;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFirst) const _ChatDivider(),
                ChatContactTile(
                  contact: contact,
                  onTap: () => _navigateToChat(context, contact),
                  onLongPress: () => _showDeleteDialog(context, contact),
                ),
                if (isLast) const _ChatDivider(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) =>
      CommonErrorView(
        message: message,
        onRetry: () => context.read<ChatListCubit>().loadChatContacts(),
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

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 0.5,
    thickness: 0.5,
    color: Color(0x4D000000),
  );
}
