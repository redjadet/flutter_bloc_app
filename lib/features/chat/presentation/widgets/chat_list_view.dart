import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<ChatListCubit, ChatListState>(
        builder: (final context, final state) => switch (state) {
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
    final BuildContext context,
    final List<ChatContact> contacts,
  ) {
    final listPadding = context.responsiveListPadding;
    final safeListPadding = listPadding.add(
      EdgeInsets.only(
        bottom: context.bottomInset + context.responsiveGap,
      ),
    );
    if (contacts.isEmpty) {
      return CommonEmptyState(
        message: context.l10n.chatHistoryEmpty,
      );
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView.separated(
            padding: safeListPadding,
            itemCount: contacts.length,
            separatorBuilder: (final context, final index) =>
                const _ChatDivider(),
            itemBuilder: (final context, final index) {
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
      ),
    );
  }

  Widget _buildErrorState(final BuildContext context, final String message) =>
      CommonErrorView(
        message: message,
        onRetry: () => context.read<ChatListCubit>().loadChatContacts(),
      );

  void _navigateToChat(final BuildContext context, final ChatContact contact) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ChatListView._navigateToChat');
      return;
    }
    // Mark as read when opening chat
    unawaited(context.read<ChatListCubit>().markAsRead(contact.id));

    // Navigate to chat page
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (final context) => BlocProvider(
            create: (final context) {
              final cubit = ChatCubit(
                repository: getIt<ChatRepository>(),
                historyRepository: getIt<ChatHistoryRepository>(),
                initialModel: SecretConfig.huggingfaceModel,
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

  void _showDeleteDialog(
    final BuildContext context,
    final ChatContact contact,
  ) {
    final chatListCubit = context.read<ChatListCubit>();
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    final l10n = context.l10n;
    unawaited(
      showAdaptiveDialog<void>(
        context: context,
        builder: (final dialogContext) {
          if (isCupertino) {
            return CupertinoAlertDialog(
              title: Text(l10n.chatHistoryDeleteConversation),
              content: Text(
                l10n.chatHistoryDeleteConversationWarning(contact.name),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => NavigationUtils.maybePop(dialogContext),
                  child: Text(l10n.cancelButtonLabel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    NavigationUtils.maybePop(dialogContext);
                    unawaited(chatListCubit.deleteContact(contact.id));
                  },
                  child: Text(l10n.deleteButtonLabel),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.chatHistoryDeleteConversation),
            content: Text(
              l10n.chatHistoryDeleteConversationWarning(contact.name),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.cancelButtonLabel,
                onPressed: () => NavigationUtils.maybePop(dialogContext),
              ),
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.deleteButtonLabel,
                isDestructive: true,
                onPressed: () {
                  NavigationUtils.maybePop(dialogContext);
                  unawaited(chatListCubit.deleteContact(contact.id));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(final BuildContext context) => const Divider(
    height: 0.5,
    thickness: 0.5,
    color: Color(0x4D000000),
  );
}
