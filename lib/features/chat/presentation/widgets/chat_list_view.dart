import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
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
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

part 'chat_list_view_navigation.part.dart';
part 'chat_list_view_parts.part.dart';
part 'chat_list_view_widgets.part.dart';

/// Chat list UI: contact list, selection, and navigation to conversation.
class ChatListView extends StatelessWidget {
  const ChatListView({
    required this.chatRepository,
    required this.historyRepository,
    required this.errorNotificationService,
    required this.pendingSyncRepository,
    this.renderOrchestrationHfTokenProvider,
    this.firebaseAuthRepository,
    this.supabaseAuthRepository,
    super.key,
  });

  final ChatRepository chatRepository;
  final ChatHistoryRepository historyRepository;
  final ErrorNotificationService errorNotificationService;
  final PendingSyncRepository pendingSyncRepository;
  final RenderOrchestrationHfTokenProvider? renderOrchestrationHfTokenProvider;
  final core_auth.AuthRepository? firebaseAuthRepository;
  final SupabaseAuthRepository? supabaseAuthRepository;

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
            return _ChatListErrorState(
              message: errorMessage,
              onRetry: context.cubit<ChatListCubit>().loadChatContacts,
            );
          }
          if (data.contacts case final contacts?) {
            return _ChatLoadedList(
              contacts: contacts,
              onContactTap: (final contact) => navigateToChat(context, contact),
              onContactLongPress: (final contact) =>
                  showDeleteDialog(context, contact),
            );
          }
          return const SizedBox.shrink();
        },
      );
}
