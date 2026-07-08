import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';

part 'online_therapy_messaging_view_content.part.dart';

class OnlineTherapyMessagingView extends StatefulWidget {
  const OnlineTherapyMessagingView({super.key});

  @override
  State<OnlineTherapyMessagingView> createState() =>
      _OnlineTherapyMessagingViewState();
}

class _OnlineTherapyMessagingViewState
    extends State<OnlineTherapyMessagingView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final draft = context.cubit<MessagingCubit>().state.draft ?? '';
      if (_controller.text != draft) {
        _controller.text = draft;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      buildMessagingContentImpl(context);
}
