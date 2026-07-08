import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.cubit<AdminCubit>().refresh());
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final isLoggedIn = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          bool
        >(
          selector: (final state) => state.isLoggedIn,
        );
    final isBusy = context.selectState<AdminCubit, AdminState, bool>(
      selector: (final state) => state.isBusy,
    );
    final errorMessage = context.selectState<AdminCubit, AdminState, String?>(
      selector: (final state) => state.errorMessage,
    );
    final pendingTherapists = context
        .selectState<AdminCubit, AdminState, List<TherapistProfile>>(
          selector: (final state) => state.pendingTherapists,
        );
    final cubit = context.cubit<AdminCubit>();
    final List<Widget> items = <Widget>[
      if (!isLoggedIn) const OnlineTherapyLoggedOutPrompt(),
      if (!isLoggedIn) const SizedBox(height: 12),
      if (errorMessage case final String message?)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      if (pendingTherapists.isEmpty)
        const ListTile(title: Text('No pending therapists.'))
      else
        ...pendingTherapists.map(
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
                onPressed: isBusy ? null : () => cubit.approve(t.id),
                child: Text(l10n.approveButtonLabel),
              ),
            ),
          ),
        ),
    ];

    return CommonPageLayout(
      title: l10n.onlineTherapyDemoNavTherapistVerification,
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
