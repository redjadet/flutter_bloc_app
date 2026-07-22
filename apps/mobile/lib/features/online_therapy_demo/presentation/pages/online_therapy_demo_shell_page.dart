import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/therapist_home_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/online_therapy_demo_dependencies.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/online_therapy_demo_scope.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

part 'online_therapy_demo_shell_admin.part.dart';
part 'online_therapy_demo_shell_client_details.part.dart';
part 'online_therapy_demo_shell_client_part.dart';
part 'online_therapy_demo_shell_controls.part.dart';
part 'online_therapy_demo_shell_messaging_call.part.dart';
part 'online_therapy_demo_shell_therapist_admin_part.dart';

/// Sidebar width for wide online-therapy demo split layouts.
double _onlineTherapySidebarWidth(final double maxWidth) =>
    math.min(320, maxWidth * 0.35).clamp(240, 320).toDouble();

/// Height for embedded messaging/call panels inside scrollable demo shells.
double _onlineTherapyEmbeddedPanelHeight({
  required final double referenceHeight,
  required final double viewportFraction,
  final double minHeight = 220,
  final double maxHeight = 420,
}) {
  return (referenceHeight * viewportFraction).clamp(minHeight, maxHeight);
}

class OnlineTherapyDemoShellPage extends StatelessWidget {
  const OnlineTherapyDemoShellPage({required this.deps, super.key});

  final OnlineTherapyDemoDependencies deps;

  @override
  Widget build(final BuildContext context) {
    return OnlineTherapyDemoScope(
      deps: deps,
      child: const _OnlineTherapyDemoBody(),
    );
  }
}
// eof
// end

class _OnlineTherapyDemoBody extends StatelessWidget {
  const _OnlineTherapyDemoBody();

  @override
  Widget build(final BuildContext context) {
    final role = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          TherapyRole
        >(
          selector: (final state) => state.role,
        );
    final user = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          TherapyUser?
        >(
          selector: (final state) => state.user,
        );
    final errorMessage = context
        .selectState<
          OnlineTherapyDemoSessionCubit,
          OnlineTherapyDemoSessionState,
          String?
        >(
          selector: (final state) => state.errorMessage,
        );

    return CommonPageLayout(
      title: 'Online Therapy Demo',
      body: Column(
        children: <Widget>[
          const _TopControls(),
          if (errorMessage case final String message?)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: user == null
                ? const _LoginPanel()
                : switch (role) {
                    TherapyRole.client => const _ClientBookingPanel(),
                    TherapyRole.therapist => const _TherapistPanel(),
                    TherapyRole.admin => const _AdminPanel(),
                  },
          ),
        ],
      ),
    );
  }
}
