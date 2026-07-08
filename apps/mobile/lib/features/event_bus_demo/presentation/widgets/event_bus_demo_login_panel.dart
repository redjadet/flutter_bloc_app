import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/presentation/widgets/event_bus_demo_listener_card.dart';

class EventBusDemoLoginPanel extends StatelessWidget {
  const EventBusDemoLoginPanel({
    required this.userIdController,
    required this.canFireLogin,
    required this.activeUserId,
    required this.onLogin,
    required this.onLogout,
    super.key,
  });

  static const Key loginButtonKey = Key('event-bus-demo-login-button');
  static const Key logoutButtonKey = Key('event-bus-demo-logout-button');

  final TextEditingController userIdController;
  final bool canFireLogin;
  final String? activeUserId;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return EventBusDemoListenerCard(
      title: l10n.eventBusDemoLoginPanelTitle,
      icon: Icons.login,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: userIdController,
            decoration: InputDecoration(
              labelText: l10n.eventBusDemoUserIdLabel,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
          ),
          SizedBox(height: context.responsiveGapM),
          PlatformAdaptive.filledButton(
            context: context,
            key: loginButtonKey,
            onPressed: canFireLogin ? onLogin : null,
            child: Text(l10n.eventBusDemoLoginButton),
          ),
          if (activeUserId != null) ...[
            SizedBox(height: context.responsiveGapS),
            KeyedSubtree(
              key: logoutButtonKey,
              child: PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: onLogout,
                child: Text(l10n.eventBusDemoLogoutButton),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
