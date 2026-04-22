import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_messaging_view.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

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
    unawaited(context.cubit<MessagingCubit>().refresh());
  }

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<MessagingCubit>().state;
    final cubit = context.cubit<MessagingCubit>();

    return CommonPageLayout(
      title: 'Messaging',
      actions: <Widget>[
        IconButton(
          onPressed: state.isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: session.user == null
            ? const OnlineTherapyLoggedOutPrompt()
            : const OnlineTherapyMessagingView(),
      ),
    );
  }
}

// eof
// end
//
