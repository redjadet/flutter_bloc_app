import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/widgets/common_max_width.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    required this.repository,
    required this.chatRepository,
    required this.historyRepository,
    required this.errorNotificationService,
    required this.pendingSyncRepository,
    this.renderOrchestrationHfTokenProvider,
    this.firebaseAuthRepository,
    this.supabaseAuthRepository,
    super.key,
  });

  final ChatListRepository repository;
  final ChatRepository chatRepository;
  final ChatHistoryRepository historyRepository;
  final ErrorNotificationService errorNotificationService;
  final PendingSyncRepository pendingSyncRepository;
  final RenderOrchestrationHfTokenProvider? renderOrchestrationHfTokenProvider;
  final core_auth.AuthRepository? firebaseAuthRepository;
  final SupabaseAuthRepository? supabaseAuthRepository;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final ChatListCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ChatListCubit(repository: widget.repository);
    unawaited(_cubit.loadChatContacts());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color foregroundColor = theme.colorScheme.onSurface;
    final TextStyle appBarTitleStyle = _appBarTitleStyle(
      context,
      foregroundColor,
    );

    return CommonPageLayout(
      title: context.l10n.chatHistoryPanelTitle,
      appBarBackgroundColor: backgroundColor,
      appBarForegroundColor: foregroundColor,
      titleTextStyle: appBarTitleStyle,
      cupertinoTitleStyle: appBarTitleStyle,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      useResponsiveBody: false,
      body: CommonMaxWidth(
        child: SizedBox.expand(
          child: BlocProvider.value(
            value: _cubit,
            child: ChatListView(
              chatRepository: widget.chatRepository,
              historyRepository: widget.historyRepository,
              renderOrchestrationHfTokenProvider:
                  widget.renderOrchestrationHfTokenProvider,
              firebaseAuthRepository: widget.firebaseAuthRepository,
              supabaseAuthRepository: widget.supabaseAuthRepository,
              errorNotificationService: widget.errorNotificationService,
              pendingSyncRepository: widget.pendingSyncRepository,
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _appBarTitleStyle(final BuildContext context, final Color color) {
    final TextStyle baseStyle =
        (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        );
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return baseStyle.copyWith(fontFamily: 'SF Pro Text');
    }
    return baseStyle.copyWith(fontFamily: 'Roboto');
  }
}
