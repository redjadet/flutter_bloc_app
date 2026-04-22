import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyDemoLandingPage extends StatelessWidget {
  const OnlineTherapyDemoLandingPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final state = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final session = context.cubit<OnlineTherapyDemoSessionCubit>();
    final List<Widget> items = <Widget>[
      const Text(
        'Interview demo (simulated backend). Not production compliance.',
      ),
      const SizedBox(height: 12),
      if (state.user == null) ...<Widget>[
        TextField(
          enabled: !state.isBusy,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'demo@example.com',
          ),
          onChanged: session.setEmailDraft,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: state.isBusy ? null : () => session.login(),
          child: Text(state.isBusy ? 'Signing in…' : 'Sign in'),
        ),
      ] else ...<Widget>[
        Text(
          'User: ${state.user?.displayName} (${state.user?.maskedEmail})',
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: state.isBusy ? null : () => session.logout(),
          child: const Text('Logout'),
        ),
      ],
      const Divider(height: 24),
      const Text(
        'Choose role',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      _RoleTile(
        role: TherapyRole.client,
        title: 'Client flow',
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClient),
      ),
      _RoleTile(
        role: TherapyRole.therapist,
        title: 'Therapist flow',
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoTherapist),
      ),
      _RoleTile(
        role: TherapyRole.admin,
        title: 'Admin flow',
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoAdmin),
      ),
      const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.tune),
        title: const Text('Controls (network/failure injection)'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: 'Online Therapy Demo',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.title,
    required this.onTap,
  });

  final TherapyRole role;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final session = context.cubit<OnlineTherapyDemoSessionCubit>();

    return ListTile(
      leading: const Icon(Icons.arrow_forward),
      title: Text(title),
      subtitle: Text('Role: ${role.name}'),
      onTap: () async {
        // Ensure role is selected. If logged out, user can still navigate; pages handle it.
        await session.setRole(role);
        if (!context.mounted) return;
        onTap();
      },
    );
  }
}

// eof
// end
//
