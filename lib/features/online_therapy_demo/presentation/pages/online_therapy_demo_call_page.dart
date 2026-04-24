import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_call_view.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoCallPage extends StatefulWidget {
  const OnlineTherapyDemoCallPage({super.key});

  @override
  State<OnlineTherapyDemoCallPage> createState() =>
      _OnlineTherapyDemoCallPageState();
}

class _OnlineTherapyDemoCallPageState extends State<OnlineTherapyDemoCallPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.cubit<CallCubit>().refresh());
  }

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<CallCubit>().state;
    final cubit = context.cubit<CallCubit>();
    final List<Widget> items = <Widget>[
      if (session.user == null) const OnlineTherapyLoggedOutPrompt(),
      if (session.user != null) const OnlineTherapyCallView(),
    ];

    return CommonPageLayout(
      title: 'Call',
      actions: <Widget>[
        IconButton(
          onPressed: state.isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }
}

// eof
// end
//
