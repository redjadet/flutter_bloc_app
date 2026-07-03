/// Typed events for the Event Bus demo (decoupled app-wide signals).
///
/// Use sparingly for cross-layer broadcasts — not for primary UI state (prefer
/// Cubit/BLoC). See the Event Bus demo page intro for a walkthrough.
sealed class EventBusDemoEvent {
  const EventBusDemoEvent();
}

/// Fired when the user signs in; listeners refresh UI or connect services.
final class UserLoggedInEvent extends EventBusDemoEvent {
  const UserLoggedInEvent(this.userId);

  final String userId;
}

/// Clears demo listener state when the user signs out.
final class UserLoggedOutEvent extends EventBusDemoEvent {
  const UserLoggedOutEvent();
}
