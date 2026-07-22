import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_call_view.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<CallCubit>().refresh());
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
    final isBusy = context.selectState<CallCubit, CallState, bool>(
      selector: (final state) => state.isBusy,
    );
    final cubit = context.cubit<CallCubit>();
    final List<Widget> items = <Widget>[
      if (!isLoggedIn) const OnlineTherapyLoggedOutPrompt(),
      if (isLoggedIn) const OnlineTherapyCallView(),
    ];

    return CommonPageLayout(
      title: 'Call',
      actions: <Widget>[
        IconButton(
          onPressed: isBusy ? null : () => cubit.refresh(),
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
