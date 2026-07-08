import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/online_therapy_demo_session_cubit.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyDemoClientHubPage extends StatelessWidget {
  const OnlineTherapyDemoClientHubPage({super.key});

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
    final List<Widget> items = <Widget>[
      if (!isLoggedIn)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (!isLoggedIn) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.person_search_outlined),
        title: Text(l10n.onlineTherapyDemoNavTherapists),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoClientTherapists),
      ),
      ListTile(
        leading: const Icon(Icons.event_outlined),
        title: Text(l10n.onlineTherapyDemoNavMyAppointments),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoClientAppointments),
      ),
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: Text(l10n.onlineTherapyDemoNavMessaging),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoClientMessaging),
      ),
      ListTile(
        leading: const Icon(Icons.videocam_outlined),
        title: Text(l10n.onlineTherapyDemoNavCall),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoClientCall),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: Text(l10n.onlineTherapyDemoNavControls),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: l10n.onlineTherapyDemoClientHubTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }
}

class OnlineTherapyDemoTherapistHubPage extends StatelessWidget {
  const OnlineTherapyDemoTherapistHubPage({super.key});

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
    final List<Widget> items = <Widget>[
      if (!isLoggedIn)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (!isLoggedIn) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.event_available_outlined),
        title: Text(l10n.onlineTherapyDemoNavAppointments),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoTherapistAppointments),
      ),
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: Text(l10n.onlineTherapyDemoNavMessaging),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoTherapistMessaging),
      ),
      ListTile(
        leading: const Icon(Icons.videocam_outlined),
        title: Text(l10n.onlineTherapyDemoNavCall),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoTherapistCall),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: Text(l10n.onlineTherapyDemoNavControls),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: l10n.onlineTherapyDemoTherapistHubTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }
}

class OnlineTherapyDemoAdminHubPage extends StatelessWidget {
  const OnlineTherapyDemoAdminHubPage({super.key});

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
    final List<Widget> items = <Widget>[
      if (!isLoggedIn)
        _LoggedOutPrompt(
          onGoToLanding: () => context.goNamed(AppRoutes.onlineTherapyDemo),
        ),
      if (!isLoggedIn) const SizedBox(height: 12),
      ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: Text(l10n.onlineTherapyDemoNavTherapistVerification),
        onTap: () =>
            context.pushNamed(AppRoutes.onlineTherapyDemoAdminVerification),
      ),
      ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text(l10n.onlineTherapyDemoNavAuditFeed),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoAdminAudit),
      ),
      const Divider(height: 24),
      ListTile(
        leading: const Icon(Icons.tune),
        title: Text(l10n.onlineTherapyDemoNavControls),
        onTap: () => context.pushNamed(AppRoutes.onlineTherapyDemoControls),
      ),
    ];

    return CommonPageLayout(
      title: l10n.onlineTherapyDemoAdminHubTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: items,
      ),
    );
  }
}

class _LoggedOutPrompt extends StatelessWidget {
  const _LoggedOutPrompt({required this.onGoToLanding});

  final VoidCallback onGoToLanding;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.onlineTherapyDemoLoggedOutTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(l10n.onlineTherapyDemoLoggedOutMessage),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onGoToLanding,
              child: Text(l10n.onlineTherapyDemoGoToLandingButton),
            ),
          ],
        ),
      ),
    );
  }
}

// eof
// end
//
