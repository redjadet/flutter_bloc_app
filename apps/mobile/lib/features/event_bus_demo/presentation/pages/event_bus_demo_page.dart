import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/domain/event_bus_demo_events.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/presentation/widgets/event_bus_demo_listener_card.dart';
import 'package:flutter_bloc_app/features/event_bus_demo/presentation/widgets/event_bus_demo_login_panel.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Interactive demo of the Event Bus pattern (login → home + notification).
///
/// Mirrors the flow from
/// https://medium.com/@savaliya.ravi.rs/what-is-the-event-bus-pattern-in-flutter-c008c9e0813d
/// without coupling screens via direct references.
class EventBusDemoPage extends StatefulWidget {
  const EventBusDemoPage({required this.eventBus, super.key});

  final EventBus eventBus;

  @override
  State<EventBusDemoPage> createState() => _EventBusDemoPageState();
}

class _EventBusDemoPageState extends State<EventBusDemoPage> {
  final TextEditingController _userIdController = TextEditingController(
    text: '101',
  );

  late final EventBus _eventBus;
  StreamSubscription<UserLoggedInEvent>? _loginSubscription;
  StreamSubscription<UserLoggedOutEvent>? _logoutSubscription;

  String? _loggedInUserId;
  int _homeRefreshCount = 0;

  bool get _canFireLogin => _userIdController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _eventBus = widget.eventBus;
    _userIdController.addListener(_onUserIdChanged);
    _loginSubscription = _eventBus.on<UserLoggedInEvent>().listen(
      _onLoggedIn,
      onError: _onEventBusStreamError,
    );
    _logoutSubscription = _eventBus.on<UserLoggedOutEvent>().listen(
      _onLoggedOut,
      onError: _onEventBusStreamError,
    );
  }

  void _onUserIdChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onLoggedIn(final UserLoggedInEvent event) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedInUserId = event.userId;
      _homeRefreshCount++;
    });
  }

  void _onLoggedOut(final UserLoggedOutEvent _) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedInUserId = null;
      _homeRefreshCount = 0;
    });
  }

  void _onEventBusStreamError(
    final Object error,
    final StackTrace stackTrace,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'event_bus_demo',
      ),
    );
  }

  void _fireLogin() {
    final String userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      return;
    }
    _eventBus.fire(UserLoggedInEvent(userId));
  }

  void _fireLogout() {
    _eventBus.fire(const UserLoggedOutEvent());
  }

  @override
  void dispose() {
    _userIdController.removeListener(_onUserIdChanged);
    unawaited(_loginSubscription?.cancel());
    unawaited(_logoutSubscription?.cancel());
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String? activeUserId = _loggedInUserId;

    return CommonPageLayout(
      title: l10n.eventBusDemoTitle,
      body: ListView(
        padding: context.pagePadding,
        children: [
          Text(
            l10n.eventBusDemoIntro,
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: context.responsiveGapL),
          EventBusDemoLoginPanel(
            userIdController: _userIdController,
            canFireLogin: _canFireLogin,
            activeUserId: activeUserId,
            onLogin: _fireLogin,
            onLogout: _fireLogout,
          ),
          SizedBox(height: context.responsiveGapM),
          EventBusDemoListenerCard(
            title: l10n.eventBusDemoHomePanelTitle,
            icon: Icons.home_outlined,
            child: Text(
              activeUserId == null
                  ? l10n.eventBusDemoHomeWaiting
                  : l10n.eventBusDemoHomeActive(
                      activeUserId,
                      _homeRefreshCount,
                    ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          SizedBox(height: context.responsiveGapM),
          EventBusDemoListenerCard(
            title: l10n.eventBusDemoNotificationPanelTitle,
            icon: Icons.notifications_active_outlined,
            child: Text(
              activeUserId == null
                  ? l10n.eventBusDemoNotificationIdle
                  : l10n.eventBusDemoNotificationConnected(activeUserId),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: activeUserId == null
                    ? colors.onSurfaceVariant
                    : colors.primary,
              ),
            ),
          ),
          SizedBox(height: context.responsiveGapL),
          Text(
            l10n.eventBusDemoGuidance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
