import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/context_utils.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

const ListEquality<ChatContact> _chatContactListEquality =
    ListEquality<ChatContact>();

class ChatListView extends StatelessWidget {
  const ChatListView({
    required this.chatRepository,
    required this.historyRepository,
    required this.errorNotificationService,
    required this.pendingSyncRepository,
    super.key,
  });

  final ChatRepository chatRepository;
  final ChatHistoryRepository historyRepository;
  final ErrorNotificationService errorNotificationService;
  final PendingSyncRepository pendingSyncRepository;

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocSelector<ChatListCubit, ChatListState, _ChatListSelectorData>(
        selector: (final state) => _ChatListSelectorData(
          isLoading: state is ChatListLoading,
          contacts: state is ChatListLoaded ? state.contacts : null,
          errorMessage: state is ChatListError ? state.message : null,
        ),
        builder: (final context, final data) {
          if (data.isLoading) {
            return const CommonLoadingWidget();
          }
          if (data.errorMessage case final errorMessage?) {
            return _buildErrorState(context, errorMessage);
          }
          if (data.contacts case final contacts?) {
            return _buildLoadedList(context, contacts);
          }
          return const SizedBox.shrink();
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
      child: CommonMaxWidth(
        child: ListView.separated(
          padding: safeListPadding,
          cacheExtent: 500,
          itemCount: contacts.length,
          separatorBuilder: (final context, final index) =>
              const _ChatDivider(),
          itemBuilder: (final context, final index) {
            final contact = contacts[index];
            final isFirst = index == 0;
            final isLast = index == contacts.length - 1;

            return RepaintBoundary(
              key: ValueKey<String>('chat-contact-${contact.id}'),
              child: Column(
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
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(final BuildContext context, final String message) =>
      CommonErrorView(
        message: message,
        onRetry: () => context.cubit<ChatListCubit>().loadChatContacts(),
      );

  void _navigateToChat(final BuildContext context, final ChatContact contact) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ChatListView._navigateToChat');
      return;
    }
    // Mark as read when opening chat
    unawaited(context.cubit<ChatListCubit>().markAsRead(contact.id));

    // Navigate to chat page
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (final context) => BlocProvider(
            create: (final context) {
              final cubit = ChatCubit(
                repository: chatRepository,
                historyRepository: historyRepository,
                initialModel: SecretConfig.huggingfaceModel,
              );
              unawaited(cubit.loadHistory());
              return cubit;
            },
            child: ChatPage(
              errorNotificationService: errorNotificationService,
              pendingSyncRepository: pendingSyncRepository,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    final BuildContext context,
    final ChatContact contact,
  ) {
    final chatListCubit = context.cubit<ChatListCubit>();
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

/// Narrow selector data to reduce rebuilds when only unrelated state changes.
@immutable
class _ChatListSelectorData {
  const _ChatListSelectorData({
    required this.isLoading,
    this.contacts,
    this.errorMessage,
  });

  final bool isLoading;
  final List<ChatContact>? contacts;
  final String? errorMessage;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is _ChatListSelectorData &&
          isLoading == other.isLoading &&
          _chatContactListEquality.equals(contacts, other.contacts) &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    isLoading,
    switch (contacts) {
      final contacts? => _chatContactListEquality.hash(contacts),
      null => null,
    },
    errorMessage,
  );
}

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(final BuildContext context) => Divider(
    height: 0.5,
    thickness: 0.5,
    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
  );
}
