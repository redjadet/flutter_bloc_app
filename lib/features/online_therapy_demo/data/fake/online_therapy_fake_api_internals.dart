part of 'online_therapy_fake_api.dart';

extension OnlineTherapyFakeApiInternals on OnlineTherapyFakeApi {
  Future<void> _simulateNetwork() async {
    if (mode == OnlineTherapyNetworkMode.offline) {
      throw StateError('Offline');
    }
    final Duration delay = switch (mode) {
      OnlineTherapyNetworkMode.normal => const Duration(milliseconds: 220),
      OnlineTherapyNetworkMode.slow => const Duration(milliseconds: 1200),
      OnlineTherapyNetworkMode.offline => Duration.zero,
      OnlineTherapyNetworkMode.messageFailure => const Duration(
        milliseconds: 220,
      ),
      OnlineTherapyNetworkMode.callFailure => const Duration(milliseconds: 220),
    };
    if (delay > Duration.zero) {
      await _sleep(delay);
    }
  }

  Future<void> _sleep(final Duration delay) {
    final completer = Completer<void>();
    _timerService.runOnce(delay, () => completer.complete());
    return completer.future;
  }

  TherapyUser _userForRole(
    final TherapyRole role, {
    required final String email,
  }) {
    final String normalized = email.trim().isEmpty
        ? 'user@example.com'
        : email.trim();
    final String masked = _maskEmail(normalized);
    final existing = _users.where((u) => u.role == role).toList();
    if (existing.isNotEmpty) {
      final base = existing.first;
      return TherapyUser(
        id: base.id,
        role: base.role,
        displayName: base.displayName,
        maskedEmail: masked,
        createdAt: base.createdAt,
      );
    }
    return TherapyUser(
      id: 'user_${role.name}',
      role: role,
      displayName: role == TherapyRole.client
          ? 'Demo Client'
          : role == TherapyRole.therapist
          ? 'Demo Therapist'
          : 'Demo Admin',
      maskedEmail: masked,
      createdAt: DateTime.utc(2026, 1, 1, 9),
    );
  }

  TherapyUser _requireCurrentUser() =>
      _currentUser ?? (throw StateError('Not authenticated'));

  void _requireRole(
    final TherapyUser user, {
    required final List<TherapyRole> allowed,
  }) {
    if (!allowed.contains(user.role)) {
      throw StateError('Not allowed');
    }
  }

  bool _isTherapistOwner({
    required final String userId,
    required final String therapistId,
  }) {
    final therapist = _therapists.firstWhere((t) => t.id == therapistId);
    return therapist.userId == userId;
  }

  void _replaceSlot(final AvailabilitySlot slot) {
    final idx = _slots.indexWhere((s) => s.id == slot.id);
    if (idx < 0) return;
    _slots[idx] = slot;
  }

  void _touchConversation(final String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx < 0) return;
    final current = _conversations[idx];
    _conversations[idx] = Conversation(
      id: current.id,
      appointmentId: current.appointmentId,
      participantIds: current.participantIds,
      lastMessageAt: _now(),
    );
  }

  void _ensureConversationForAppointment(final Appointment appointment) {
    final therapist = _therapists.firstWhere(
      (t) => t.id == appointment.therapistId,
    );
    final id = 'conv_${appointment.id}';
    if (_conversations.any((c) => c.id == id)) return;
    _conversations.add(
      Conversation(
        id: id,
        appointmentId: appointment.id,
        participantIds: <String>[appointment.clientId, therapist.userId],
        lastMessageAt: appointment.createdAt,
      ),
    );
  }

  void _appendAudit(final String action, {required final String targetId}) {
    final actor = _currentUser?.id ?? 'system';
    _audit.add(
      AuditEvent(
        id: 'audit_${_audit.length + 1}',
        actorId: actor,
        action: action,
        targetId: targetId,
        createdAt: _now(),
      ),
    );
  }

  DateTime _now() => _nowFn();

  String _maskEmail(final String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final user = parts[0];
    final domain = parts[1];
    if (user.length <= 2) return '**@$domain';
    return '${user.substring(0, 2)}***@$domain';
  }

  void _seed() {
    final created = DateTime.utc(2026, 1, 1, 9);
    _users.addAll(<TherapyUser>[
      TherapyUser(
        id: 'u_client_1',
        role: TherapyRole.client,
        displayName: 'Demo Client',
        maskedEmail: 'de***@example.com',
        createdAt: created,
      ),
      TherapyUser(
        id: 'u_ther_1',
        role: TherapyRole.therapist,
        displayName: 'Dr. Demo Therapist',
        maskedEmail: 'dr***@example.com',
        createdAt: created,
      ),
      TherapyUser(
        id: 'u_admin_1',
        role: TherapyRole.admin,
        displayName: 'Demo Admin',
        maskedEmail: 'ad***@example.com',
        createdAt: created,
      ),
    ]);

    _therapists.addAll(<TherapistProfile>[
      const TherapistProfile(
        id: 't_1',
        userId: 'u_ther_1',
        title: 'Clinical Psychologist',
        specialties: <String>['Anxiety', 'Stress'],
        languages: <String>['Turkish', 'English'],
        bio: 'Focused on practical coping strategies and structured sessions.',
        rating: 4.8,
        isVerified: true,
      ),
      const TherapistProfile(
        id: 't_2',
        userId: 'u_ther_pending',
        title: 'Psychotherapist',
        specialties: <String>['Relationships', 'Trauma'],
        languages: <String>['Turkish'],
        bio: 'Pending verification (admin can approve in demo).',
        rating: 4.6,
        isVerified: false,
      ),
    ]);

    final baseDay = DateTime.utc(2026, 4, 22, 9);
    for (final therapist in _therapists) {
      for (int i = 0; i < 6; i++) {
        final start = baseDay.add(Duration(hours: i));
        final end = start.add(const Duration(minutes: 50));
        _slots.add(
          AvailabilitySlot(
            id: 'slot_${therapist.id}_$i',
            therapistId: therapist.id,
            startAt: start,
            endAt: end,
            status: AvailabilitySlotStatus.available,
          ),
        );
      }
    }
  }
}

// eof
