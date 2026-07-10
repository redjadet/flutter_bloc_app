import 'dart:async';

import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/app/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/app/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_render_orchestration_diagnostics_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';

part 'chat_list_view_navigation.part.dart';
part 'chat_list_view_parts.part.dart';
part 'chat_list_view_widgets.part.dart';

/// Chat list UI: contact list, selection, and navigation to conversation.
class ChatListView extends StatelessWidget {
  const ChatListView({
    required this.chatRepository,
    required this.historyRepository,
    required this.errorNotificationService,
    required this.backendAvailability,
    this.renderOrchestrationHfTokenProvider,
    this.authSessionPort,
    this.renderOrchestrationDiagnostics,
    super.key,
  });

  final ChatRepository chatRepository;
  final ChatHistoryRepository historyRepository;
  final ErrorNotificationService errorNotificationService;
  final BackendAvailability backendAvailability;
  final RenderOrchestrationHfTokenProvider? renderOrchestrationHfTokenProvider;
  final ChatAuthSessionPort? authSessionPort;
  final ChatRenderOrchestrationDiagnosticsPort? renderOrchestrationDiagnostics;

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
