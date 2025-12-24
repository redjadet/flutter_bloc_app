import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/common_app_bar.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key, this.repository});

  final ChatListRepository? repository;

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
      body: BlocProvider(
        create: (final context) {
          final cubit = ChatListCubit(
            repository: repository ?? getIt<ChatListRepository>(),
          );
          unawaited(cubit.loadChatContacts());
          return cubit;
        },
        child: const ChatListView(),
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
