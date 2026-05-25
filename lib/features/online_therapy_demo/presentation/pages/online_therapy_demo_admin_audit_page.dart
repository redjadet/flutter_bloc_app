import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/widgets/online_therapy_logged_out_prompt.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

class OnlineTherapyDemoAdminAuditPage extends StatefulWidget {
  const OnlineTherapyDemoAdminAuditPage({super.key});

  @override
  State<OnlineTherapyDemoAdminAuditPage> createState() =>
      _OnlineTherapyDemoAdminAuditPageState();
}

class _OnlineTherapyDemoAdminAuditPageState
    extends State<OnlineTherapyDemoAdminAuditPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.cubit<AdminCubit>().refresh());
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
    final isBusy = context.selectState<AdminCubit, AdminState, bool>(
      selector: (final state) => state.isBusy,
    );
    final errorMessage = context.selectState<AdminCubit, AdminState, String?>(
      selector: (final state) => state.errorMessage,
    );
    final selectedEvents = context
        .selectState<AdminCubit, AdminState, List<AuditEvent>>(
          selector: (final state) => state.auditEvents,
        );
    final cubit = context.cubit<AdminCubit>();

    final events = selectedEvents.reversed.toList(growable: false);

    return CommonPageLayout(
      title: 'Audit feed',
      actions: <Widget>[
        IconButton(
          onPressed: isBusy ? null : () => cubit.refresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: events.length + 1,
        separatorBuilder: (final context, final index) =>
            const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == 0) {
            if (!isLoggedIn) {
              return const KeyedSubtree(
                key: ValueKey('online-therapy-admin-audit-header-logged-out'),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: OnlineTherapyLoggedOutPrompt(),
                ),
              );
            }
            if (errorMessage case final String message?) {
              return KeyedSubtree(
                key: const ValueKey('online-therapy-admin-audit-header-error'),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return const KeyedSubtree(
              key: ValueKey('online-therapy-admin-audit-header-ok'),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Recent security-relevant events (demo).'),
              ),
            );
          }
          final e = events[index - 1];
          return ListTile(
            key: ValueKey<String>('audit-event-${e.id}'),
            dense: true,
            title: Text(
              e.action,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'actor=${e.actorId} target=${e.targetId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}

// eof
// end
//
