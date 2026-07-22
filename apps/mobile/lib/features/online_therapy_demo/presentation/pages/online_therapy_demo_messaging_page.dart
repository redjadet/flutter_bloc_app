import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_messaging_view.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class OnlineTherapyDemoMessagingPage extends StatefulWidget {
  const OnlineTherapyDemoMessagingPage({super.key});

  @override
  State<OnlineTherapyDemoMessagingPage> createState() =>
      _OnlineTherapyDemoMessagingPageState();
}

class _OnlineTherapyDemoMessagingPageState
    extends State<OnlineTherapyDemoMessagingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<MessagingCubit>().refresh());
    });
  }

  @override
  Widget build(final BuildContext context) {
    final isLoggedIn = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          bool
        >(
          selector: (final state) => state.isLoggedIn,
        );
    final isBusy = context.selectState<MessagingCubit, MessagingState, bool>(
      selector: (final state) => state.isBusy,
    );
    final cubit = context.cubit<MessagingCubit>();

    return CommonPageLayout(
      title: 'Messaging',
      actions: <Widget>[
        IconButton(
          onPressed: isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: !isLoggedIn
            ? const OnlineTherapyLoggedOutPrompt()
            : const OnlineTherapyMessagingView(),
      ),
    );
  }
}

// eof
// end
//
