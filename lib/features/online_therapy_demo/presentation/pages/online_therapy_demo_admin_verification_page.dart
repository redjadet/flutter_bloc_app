import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoAdminVerificationPage extends StatefulWidget {
  const OnlineTherapyDemoAdminVerificationPage({super.key});

  @override
  State<OnlineTherapyDemoAdminVerificationPage> createState() =>
      _OnlineTherapyDemoAdminVerificationPageState();
}

class _OnlineTherapyDemoAdminVerificationPageState
    extends State<OnlineTherapyDemoAdminVerificationPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.cubit<AdminCubit>().refresh());
  }

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final state = context.watchBloc<AdminCubit>().state;
    final cubit = context.cubit<AdminCubit>();

    return CommonPageLayout(
      title: 'Therapist verification',
      actions: <Widget>[
        IconButton(
          onPressed: state.isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (session.user == null) const OnlineTherapyLoggedOutPrompt(),
          if (session.user == null) const SizedBox(height: 12),
          if (state.errorMessage case final String errorMessage?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (state.pendingTherapists.isEmpty)
            const ListTile(title: Text('No pending therapists.'))
          else
            ...state.pendingTherapists.map(
              (t) => Card(
                child: ListTile(
                  title: Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    t.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
                    onPressed: state.isBusy ? null : () => cubit.approve(t.id),
                    child: const Text('Approve'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// eof
// end
//
