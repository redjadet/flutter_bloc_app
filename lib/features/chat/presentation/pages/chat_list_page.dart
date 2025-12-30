import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    required this.repository,
    required this.chatRepository,
    required this.historyRepository,
    required this.errorNotificationService,
    required this.pendingSyncRepository,
    super.key,
  });

  final ChatListRepository repository;
  final ChatRepository chatRepository;
  final ChatHistoryRepository historyRepository;
  final ErrorNotificationService errorNotificationService;
  final PendingSyncRepository pendingSyncRepository;

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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CommonAppBar(
        title: context.l10n.chatHistoryPanelTitle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        titleTextStyle: _appBarTitleStyle(context, foregroundColor),
        cupertinoBackgroundColor: backgroundColor,
        cupertinoTitleStyle: _appBarTitleStyle(context, foregroundColor),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      body: BlocProvider.value(
        value: _cubit,
        child: ChatListView(
          chatRepository: widget.chatRepository,
          historyRepository: widget.historyRepository,
          errorNotificationService: widget.errorNotificationService,
          pendingSyncRepository: widget.pendingSyncRepository,
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
