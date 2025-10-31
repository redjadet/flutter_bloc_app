import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key, this.repository});

  final ChatListRepository? repository;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: _buildAppBar(context),
    body: BlocProvider(
      create: (context) {
        final cubit = ChatListCubit(
          repository: repository ?? getIt<ChatListRepository>(),
        );
        unawaited(cubit.loadChatContacts());
        return cubit;
      },
      child: const ChatListView(),
    ),
    bottomNavigationBar: const ChatBottomNavigationBar(),
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(
      'Chats',
      style: _appBarTitleStyle(context),
    ),
    centerTitle: true,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  TextStyle _appBarTitleStyle(BuildContext context) {
    const baseStyle = TextStyle(
      color: Colors.black,
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
