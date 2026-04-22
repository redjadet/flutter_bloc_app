import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyDemoClientHubPage extends StatelessWidget {
  const OnlineTherapyDemoClientHubPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final List<Widget> items = <Widget>[
      if (session.user == null)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (session.user == null) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.person_search_outlined),
        title: const Text('Therapists'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClientTherapists),
      ),
      ListTile(
        leading: const Icon(Icons.event_outlined),
        title: const Text('My appointments'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClientAppointments),
      ),
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: const Text('Messaging'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClientMessaging),
      ),
      ListTile(
        leading: const Icon(Icons.videocam_outlined),
        title: const Text('Call'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClientCall),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: const Text('Controls'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: 'Client — Therapy demo',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class OnlineTherapyDemoTherapistHubPage extends StatelessWidget {
  const OnlineTherapyDemoTherapistHubPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final List<Widget> items = <Widget>[
      if (session.user == null)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (session.user == null) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.event_available_outlined),
        title: const Text('Appointments'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoTherapistAppointments),
      ),
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: const Text('Messaging'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoTherapistMessaging),
      ),
      ListTile(
        leading: const Icon(Icons.videocam_outlined),
        title: const Text('Call'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoTherapistCall),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: const Text('Controls'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: 'Therapist — Therapy demo',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class OnlineTherapyDemoAdminHubPage extends StatelessWidget {
  const OnlineTherapyDemoAdminHubPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final session = context.watchBloc<OnlineTherapyDemoSessionCubit>().state;
    final List<Widget> items = <Widget>[
      if (session.user == null)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (session.user == null) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: const Text('Therapist verification'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoAdminVerification),
      ),
      ListTile(
        leading: const Icon(Icons.security_outlined),
        title: const Text('Audit feed'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoAdminAudit),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: const Text('Controls'),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: 'Admin — Therapy demo',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

class _LoggedOutPrompt extends StatelessWidget {
  const _LoggedOutPrompt({required this.onGoToLanding});

  final VoidCallback onGoToLanding;

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'You are logged out.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Go back to the landing screen to sign in.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onGoToLanding,
            child: const Text('Go to landing'),
          ),
        ],
      ),
    ),
  );
}

// eof
// end
//
