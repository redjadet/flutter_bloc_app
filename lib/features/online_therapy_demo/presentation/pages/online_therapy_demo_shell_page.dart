import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_network_mode.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/appointment_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/audit_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapist_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_admin_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_call_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/admin_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/call_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/client_booking_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/therapist_home_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/date_time_formatting.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

part 'online_therapy_demo_shell_client_part.dart';
part 'online_therapy_demo_shell_messaging_call_part.dart';
part 'online_therapy_demo_shell_therapist_admin_part.dart';

class OnlineTherapyDemoShellPage extends StatelessWidget {
  const OnlineTherapyDemoShellPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider>[
        BlocProvider<OnlineTherapyDemoSessionCubit>(
          create: (_) => OnlineTherapyDemoSessionCubit(
            auth: getIt<TherapyAuthRepository>(),
            api: getIt<OnlineTherapyFakeApi>(),
          ),
        ),
        BlocProvider<ClientBookingCubit>(
          create: (_) => ClientBookingCubit(
            therapists: getIt<TherapistRepository>(),
            appointments: getIt<AppointmentRepository>(),
          ),
        ),
        BlocProvider<TherapistHomeCubit>(
          create: (_) => TherapistHomeCubit(
            appointments: getIt<AppointmentRepository>(),
          ),
        ),
        BlocProvider<AdminCubit>(
          create: (_) => AdminCubit(
            admin: getIt<TherapyAdminRepository>(),
            audit: getIt<AuditRepository>(),
          ),
        ),
        BlocProvider<MessagingCubit>(
          create: (_) => MessagingCubit(
            messaging: getIt<TherapyMessagingRepository>(),
          ),
        ),
        BlocProvider<CallCubit>(
          create: (_) => CallCubit(
            appointments: getIt<AppointmentRepository>(),
            calls: getIt<TherapyCallRepository>(),
          ),
        ),
      ],
      child: BlocListener<OnlineTherapyDemoSessionCubit, OnlineTherapyDemoSessionState>(
        listenWhen: (prev, next) =>
            prev.user != next.user || prev.role != next.role,
        listener: (context, state) {
          if (state.user != null && state.role == TherapyRole.client) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<ClientBookingCubit>().refresh());
          }
          if (state.user != null && state.role == TherapyRole.therapist) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<TherapistHomeCubit>().refresh());
          }
          if (state.user != null && state.role == TherapyRole.admin) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<AdminCubit>().refresh());
          }
          if (state.user != null) {
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<MessagingCubit>().refresh());
            // check-ignore: side_effects_build - BlocListener listener is event-driven.
            unawaited(context.cubit<CallCubit>().refresh());
          }
        },
        child: const _OnlineTherapyDemoBody(),
      ),
    );
  }
}
// eof
// end

class _OnlineTherapyDemoBody extends StatelessWidget {
  const _OnlineTherapyDemoBody();

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>();
    final state = session.state;

    return CommonPageLayout(
      title: 'Online Therapy Demo',
      body: Column(
        children: <Widget>[
          _TopControls(state: state),
          if (state.errorMessage case final String errorMessage?)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: state.user == null
                ? const _LoginPanel()
                : switch (state.role) {
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

class _TopControls extends StatelessWidget {
  const _TopControls({required this.state});

  final OnlineTherapyDemoSessionState state;

  @override
  Widget build(final BuildContext context) {
    final cubit = context.cubit<OnlineTherapyDemoSessionCubit>();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: DropdownButton<TherapyRole>(
              isExpanded: true,
              value: state.role,
              onChanged: state.isBusy
                  ? null
                  : (final v) {
                      if (v == null) return;
                      unawaited(cubit.setRole(v));
                    },
              items: TherapyRole.values
                  .map(
                    (r) => DropdownMenuItem<TherapyRole>(
                      value: r,
                      child: Text(
                        'Role: ${r.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: DropdownButton<OnlineTherapyNetworkMode>(
              isExpanded: true,
              value: state.networkMode,
              onChanged: state.isBusy
                  ? null
                  : (final v) => v == null ? null : cubit.setNetworkMode(v),
              items: OnlineTherapyNetworkMode.values
                  .map(
                    (m) => DropdownMenuItem<OnlineTherapyNetworkMode>(
                      value: m,
                      child: Text(
                        'Network: ${m.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          if (state.user != null)
            Text(
              'User: ${state.user?.displayName} (${state.user?.maskedEmail})',
            ),
          if (state.user != null)
            ElevatedButton(
              onPressed: state.isBusy ? null : () => cubit.logout(),
              child: const Text('Logout'),
            ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatefulWidget {
  const _LoginPanel();

  @override
  State<_LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends State<_LoginPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnlineTherapyDemoSessionCubit>().state;
    _controller = TextEditingController(text: state.emailDraft ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final cubit = context.cubit<OnlineTherapyDemoSessionCubit>();

    final nextText = state.emailDraft ?? '';
    if (_controller.text != nextText) {
      _controller.value = _controller.value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login (demo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !state.isBusy,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'demo@example.com',
              ),
              onChanged: cubit.setEmailDraft,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isBusy ? null : () => cubit.login(),
                child: Text(state.isBusy ? 'Signing in…' : 'Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
