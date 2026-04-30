part of 'online_therapy_fake_api.dart';

class OnlineTherapyFakeApi {
  OnlineTherapyFakeApi({
    OnlineTherapyNetworkMode initialMode = OnlineTherapyNetworkMode.normal,
    TimerService? timerService,
    DateTime Function()? now,
  }) : mode = initialMode,
       _timerService = timerService ?? DefaultTimerService(),
       _nowFn = (now ?? (() => DateTime.now().toUtc())) {
    _seed();
  }

  OnlineTherapyNetworkMode mode;
  final TimerService _timerService;
  final DateTime Function() _nowFn;

  TherapyUser? get currentUser => _currentUser;
  TherapyUser? _currentUser;

  final List<TherapyUser> _users = <TherapyUser>[];
  final List<TherapistProfile> _therapists = <TherapistProfile>[];
  final List<AvailabilitySlot> _slots = <AvailabilitySlot>[];
  final List<Appointment> _appointments = <Appointment>[];
  final List<Conversation> _conversations = <Conversation>[];
  final List<Message> _messages = <Message>[];
  final List<CallSession> _calls = <CallSession>[];
  final List<AuditEvent> _audit = <AuditEvent>[];

  final Map<String, int> _messageSendAttemptsByConversationId = <String, int>{};

  Future<TherapyUser> login({
    required final String email,
    required final TherapyRole role,
  }) async {
    await _simulateNetwork();
    final user = _userForRole(role, email: email);
    _currentUser = user;
    _appendAudit('login', targetId: user.id);
    return user;
  }

  Future<void> logout() async {
    await _simulateNetwork();
    final user = _currentUser;
    if (user != null) {
      _appendAudit('logout', targetId: user.id);
    }
    _currentUser = null;
  }

  Future<List<TherapistProfile>> listTherapists({
    final String? query,
    final String? specialty,
    final String? language,
  }) async {
    await _simulateNetwork();
    _requireCurrentUser();

    Iterable<TherapistProfile> results = _therapists.where((t) => t.isVerified);
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.bio.toLowerCase().contains(q),
      );
    }
    if (specialty != null && specialty.trim().isNotEmpty) {
      final s = specialty.trim().toLowerCase();
      results = results.where(
        (t) => t.specialties.any((x) => x.toLowerCase() == s),
      );
    }
    if (language != null && language.trim().isNotEmpty) {
      final l = language.trim().toLowerCase();
      results = results.where(
        (t) => t.languages.any((x) => x.toLowerCase() == l),
      );
    }
    return results.toList(growable: false);
  }

  Future<TherapistProfile> getTherapist({
    required final String therapistId,
  }) async {
    await _simulateNetwork();
    _requireCurrentUser();
    return _therapists.firstWhere((t) => t.id == therapistId);
  }

  Future<List<AvailabilitySlot>> listAvailability({
    required final String therapistId,
    required final DateTime date,
  }) async {
    await _simulateNetwork();
    _requireCurrentUser();
    final dayStart = DateTime.utc(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _slots
        .where((s) => s.therapistId == therapistId)
        .where(
          (s) => !s.startAt.isBefore(dayStart) && s.startAt.isBefore(dayEnd),
        )
        .toList(growable: false);
  }

  Future<Appointment> createAppointment({
    required final String therapistId,
    required final DateTime startAt,
    required final DateTime endAt,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    _requireRole(user, allowed: <TherapyRole>[TherapyRole.client]);

    final therapist = _therapists.firstWhere((t) => t.id == therapistId);
    if (!therapist.isVerified) {
      throw StateError('Therapist is not verified');
    }

    final slot = _slots.firstWhere(
      (s) =>
          s.therapistId == therapistId &&
          s.startAt == startAt &&
          s.endAt == endAt,
    );
    if (slot.status != AvailabilitySlotStatus.available) {
      throw StateError('Slot is not available');
    }
    final updatedSlot = AvailabilitySlot(
      id: slot.id,
      therapistId: slot.therapistId,
      startAt: slot.startAt,
      endAt: slot.endAt,
      status: AvailabilitySlotStatus.booked,
    );
    _replaceSlot(updatedSlot);

    final appointment = Appointment(
      id: 'appt_${_appointments.length + 1}',
      therapistId: therapistId,
      clientId: user.id,
      startAt: startAt,
      endAt: endAt,
      status: AppointmentStatus.confirmed,
      createdAt: _now(),
    );
    _appointments.add(appointment);
    _appendAudit('appointment_created', targetId: appointment.id);

    _ensureConversationForAppointment(appointment);
    return appointment;
  }

  Future<List<Appointment>> listAppointmentsForCurrentRole() async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    if (user.role == TherapyRole.client) {
      return _appointments
          .where((a) => a.clientId == user.id)
          .toList(growable: false);
    }
    if (user.role == TherapyRole.therapist) {
      final therapist = _therapists.firstWhere((t) => t.userId == user.id);
      return _appointments
          .where((a) => a.therapistId == therapist.id)
          .toList(growable: false);
    }
    return _appointments.toList(growable: false);
  }

  Future<Appointment> cancelAppointment({
    required final String appointmentId,
    required final String reason,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final idx = _appointments.indexWhere((a) => a.id == appointmentId);
    if (idx < 0) throw StateError('Appointment not found');

    final current = _appointments[idx];
    final canCancel =
        user.role == TherapyRole.admin ||
        (user.role == TherapyRole.client && current.clientId == user.id) ||
        (user.role == TherapyRole.therapist &&
            _isTherapistOwner(
              userId: user.id,
              therapistId: current.therapistId,
            ));
    if (!canCancel) throw StateError('Not allowed to cancel');

    final updated = Appointment(
      id: current.id,
      therapistId: current.therapistId,
      clientId: current.clientId,
      startAt: current.startAt,
      endAt: current.endAt,
      status: AppointmentStatus.cancelled,
      createdAt: current.createdAt,
      cancelReason: reason,
    );
    _appointments[idx] = updated;
    final slotIdx = _slots.indexWhere(
      (s) =>
          s.therapistId == current.therapistId &&
          s.startAt == current.startAt &&
          s.endAt == current.endAt,
    );
    if (slotIdx >= 0) {
      final slot = _slots[slotIdx];
      _slots[slotIdx] = AvailabilitySlot(
        id: slot.id,
        therapistId: slot.therapistId,
        startAt: slot.startAt,
        endAt: slot.endAt,
        status: AvailabilitySlotStatus.available,
      );
    }
    _appendAudit('appointment_cancelled', targetId: updated.id);
    return updated;
  }

  Future<List<Conversation>> listConversations() async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    return _conversations
        .where((c) => c.participantIds.contains(user.id))
        .toList(growable: false);
  }

  Future<List<Message>> listMessages({
    required final String conversationId,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final conv = _conversations.firstWhere((c) => c.id == conversationId);
    if (!conv.participantIds.contains(user.id)) throw StateError('Not allowed');
    return _messages
        .where((m) => m.conversationId == conversationId)
        .toList(growable: false);
  }

  Future<Message> sendMessage({
    required final String conversationId,
    required final String body,
  }) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final conv = _conversations.firstWhere((c) => c.id == conversationId);
    if (!conv.participantIds.contains(user.id)) throw StateError('Not allowed');

    final attempt =
        (_messageSendAttemptsByConversationId[conversationId] ?? 0) + 1;
    _messageSendAttemptsByConversationId[conversationId] = attempt;

    final shouldFail =
        mode == OnlineTherapyNetworkMode.messageFailure && attempt == 1;
    final message = Message(
      id: 'msg_${_messages.length + 1}',
      conversationId: conversationId,
      senderId: user.id,
      body: body,
      sentAt: _now(),
      deliveryStatus: shouldFail
          ? MessageDeliveryStatus.failed
          : MessageDeliveryStatus.sent,
      retryCount: shouldFail ? 1 : 0,
    );
    _messages.add(message);
    _touchConversation(conversationId);
    _appendAudit(
      shouldFail ? 'message_failed' : 'message_sent',
      targetId: message.id,
    );
    return message;
  }

  Future<Message> retryMessage({required final String messageId}) async {
    await _simulateNetwork();
    final user = _requireCurrentUser();
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx < 0) throw StateError('Message not found');
    final current = _messages[idx];
    final conv = _conversations.firstWhere(
      (c) => c.id == current.conversationId,
    );
    if (!conv.participantIds.contains(user.id)) throw StateError('Not allowed');
    if (current.deliveryStatus != MessageDeliveryStatus.failed) {
      return current;
    }

    final retried = Message(
      id: current.id,
      conversationId: current.conversationId,
      senderId: current.senderId,
      body: current.body,
      sentAt: _now(),
      deliveryStatus: MessageDeliveryStatus.sent,
      retryCount: current.retryCount + 1,
    );
    _messages[idx] = retried;
    _touchConversation(retried.conversationId);
    _appendAudit('message_retried', targetId: retried.id);
    return retried;
  }
}
